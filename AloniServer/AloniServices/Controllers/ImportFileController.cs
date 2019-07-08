using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// ای پی آی مربوط به انتقال اطلاعات از طریق اکسل
    /// </summary>
    [RoutePrefix("ImportFile")]
    public class ImportFileController : AdvancedApiController
    {
        /// <summary>
        /// سرویس ایجاد جدول موقت به منظور انتقال اطلاعات
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("Import")]
        [HttpPost]
        [Exception]
        public IHttpActionResult Import(ImportModel model)
        {
            SqlCommand cmd;
            SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["dbConStr"].ConnectionString);
            int isExist = 0;
            string sql = "SELECT count(*) as IsExists FROM dbo.sysobjects where id = object_id('[dbo].[TB_Temp_" + storeId.ToString() + "]')";
            cmd = new SqlCommand(sql, conn);
            conn.Open();
            isExist = (Int32)cmd.ExecuteScalar();
            if (isExist == 0)
            {
                var header = model.data.Columns.Cast<DataColumn>().Select(x => x.ColumnName.Trim()).ToList();
                string query = "";
                foreach (var item in header)
                {
                    query += $"M_{item} varchar(max),";
                }
                query = query.Substring(0, query.Count() - 1);
                query += ",id int identity,result varchar(max),isOk bit,itemId bigint";
                cmd = new SqlCommand($"create table TB_Temp_{storeId}({query})", conn);
                cmd.ExecuteNonQuery();

            }
            SqlBulkCopy bulkCopy = new SqlBulkCopy(conn);
            bulkCopy.DestinationTableName = $"TB_Temp_{storeId}";
            bulkCopy.WriteToServer(model.data);
            conn.Close();
            return Ok($"TB_Temp_{storeId}");
        }
        /// <summary>
        /// سرویس انتقال اطلاعات
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("pushData")]
        [HttpPost]
        [Exception]
        public IHttpActionResult pushData(ImportModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_ConvertFile", "ImportFileController_pushData"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@groupId", model.grpId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                repo.cmd.Parameters.AddWithValue("@techStr", model.techHead == "" ? null : model.techHead);
                repo.cmd.Parameters.AddWithValue("@title", model.mapModel.titleColumn.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@technicalTitle", model.mapModel.technicalTitleColumn.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@barcode", model.mapModel.barcodeColumn.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@sex", model.mapModel.sex.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@localBarcode", model.mapModel.localBarcode.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@categoryId", model.catId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@unitName", model.mapModel.unitName.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@provinceId", model.mapModel.provinceColumn.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@cityId", model.mapModel.CityColumn.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@tb_name", $"TB_Temp_{storeId}");
                
                repo.ExecuteAdapter();
                return Ok("ok");
            }
        }

        /// <summary>
        /// سرویس گزارش بروز در خطا در هنگام انتقال اطلاعات
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("CrashReport")]
        [HttpPost]
        [Exception]
        public IHttpActionResult CrashReport(ConvertFileModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_CrashReport", "ImportFileController_CrashReport"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", model.storeId);
                repo.cmd.Parameters.AddWithValue("@lockId", model.id.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@dsc", model.dsc.dbNullCheckString());
                repo.ExecuteNonQuery();
                return Ok("ok");
            }
        }

        /// <summary>
        /// سرویس دریافت گزارش انتقال اطلاعات
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getConvertResult")]
        [HttpPost]
        [Exception]
        public IHttpActionResult getConvertResult(ConvertFileModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getConvertResult", "ImportFileController_getConvertResult",initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@lockId", model.id.dbNullCheckLong());
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0]);
            }
        }
        /// <summary>
        /// سرویس ایجاد لاگ برای انتقال
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("createLog")]
        [HttpPost]
        [Exception]
        public IHttpActionResult createLog(ConvertFileModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addConvertFileLog", "ImportFileController_createLog"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@grpId", model.groupId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@totalRecord", model.totalRecord.dbNullCheckInt());
                repo.cmd.Parameters.AddWithValue("@file", model.documentPath.dbNullCheckString());
                var param = repo.cmd.Parameters.Add("@id", SqlDbType.BigInt);
                param.Direction = ParameterDirection.Output;
                repo.ExecuteNonQuery();

                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
               
                return Ok(new { id = param.Value });
            }
        }
        /// <summary>
          /// سرویس بررسی بارکدهای وارد شده و تطبیق آنها
          /// </summary>
          /// <param name="model"></param>
          /// <returns></returns>
        [Route("checkBarcode")]
        [HttpPost]
        [Exception]
        public IHttpActionResult checkBarcode(checkBarcodeModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_checkBarcode", "ImportFileController_checkBarcode",initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                DataTable dt = new DataTable();
                dt.Columns.Add("id");
                DataRow row;
                foreach (var item in model.barcodeList)
                {
                    row = dt.NewRow();
                    row["id"] = item;
                    dt.Rows.Add(row);
                }
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@barcodeList", dt);
                repo.ExecuteAdapter();
                return Ok(
                    repo.ds.Tables[0].AsEnumerable().Select(c =>
                    new
                    {
                        id = Convert.ToInt64(c.Field<object>("id")),
                        Title = Convert.ToString(c.Field<object>("title")),
                        barcode = Convert.ToString(c.Field<object>("barcode")),
                        status = Convert.ToString(c.Field<object>("status"))
                    }

                        ).ToList()
                    );
            }
        }
        /// <summary>
        /// سرویس ایجاد زیرساخت اپدیت موجودی و تخفیف
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("ImportForUpdate")]
        [HttpPost]
        [Exception]
        public IHttpActionResult ImportForUpdate(ImportModel model)
        {
            SqlCommand cmd;
            SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["dbConStr"].ConnectionString);
            int isExist = 0;
            string sql = "SELECT count(*) as IsExists FROM dbo.sysobjects where id = object_id('[dbo].[TB_Temp_Update_" + storeId.ToString() + "]')";
            cmd = new SqlCommand(sql, conn);
            conn.Open();
            isExist = (Int32)cmd.ExecuteScalar();
            if (isExist == 0)
            {
                var header = model.data.Columns.Cast<DataColumn>().Select(x => x.ColumnName.Trim()).ToList();
                string query = "";
                foreach (var item in header)
                {
                    query += $"M_{item} varchar(max),";
                }
                query = query.Substring(0, query.Count() - 1);
                query += ",id int identity,result varchar(max),isOk bit";
                cmd = new SqlCommand($"create table TB_Temp_Update_{storeId}({query})", conn);
                cmd.ExecuteNonQuery();
            }
            SqlBulkCopy bulkCopy = new SqlBulkCopy(conn);
            bulkCopy.DestinationTableName = $"TB_Temp_Update_{storeId}";
            bulkCopy.WriteToServer(model.data);
            conn.Close();
            return Ok($"TB_Temp_Update_{storeId}");
        }

        /// <summary>
        /// سرویس آپدیت موجودی و قیمت
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("updateData")]
        [HttpPost]
        [Exception]
        public IHttpActionResult updateData(ImportModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_UpdatePriceQtyFile", "ImportFileController_updateData"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@barcode", model.mapUpdateModel.barcodeColumn.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@price", model.mapUpdateModel.priceColumn.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@qty", model.mapUpdateModel.qtyColumn.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@tb_name", $"TB_Temp_Update_{storeId}");
                repo.ExecuteAdapter();
                return Ok("ok");
            }
        }

        /// <summary>
        /// سرویس دریافت بارکدهای مشابه 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getMathItemWithBarcode")]
        [HttpPost]
        [Exception]
        public IHttpActionResult getMathItemWithBarcode(getMathItemWithBarcodeBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getMathItemWithBarcode", "ImportFileController_getMathItemWithBarcode",initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                DataTable dt = new DataTable();
                DataRow row;
                dt.Columns.Add("id");
                foreach (var item in model.barcodeList)
                {
                    row = dt.NewRow();
                    row["id"] = item;
                    dt.Rows.Add(row);
                }
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                var param = repo.cmd.Parameters.AddWithValue("@barcodeList", dt);
                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(r => new
                {
                    id = r.Field<long>("id"),
                    title = r.Field<string>("title"),
                    barcode = r.Field<string>("barcode"),
                    status_dsc = r.Field<string>("status_dsc"),
                    status_id = Convert.ToInt16(r.Field<object>("status_id")),
                    dispalyDate = Convert.ToString(r.Field<object>("date_")),
                    date = Convert.ToDateTime(r.Field<object>("date__")),
                }).ToList());
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [Route("getUpdateResult")]
        [HttpPost]
        [Exception]
        public IHttpActionResult getUpdateResult()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getUpdateResult", "ImportFileController_getUpdateResult", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0]);
            }
        }
    }
    /// <summary>
    /// مدل پایه انتقال اطلاعات
    /// </summary>
    public class ImportFileMapModel
    {
        /// <summary>
        /// نام ستون مشخص کننده عنوان
        /// </summary>
        public string titleColumn { get; set; }
        /// <summary>
        /// نام ستون مشخص کننده مشخصه فنی
        /// </summary>
        public string technicalTitleColumn { get; set; }
        /// <summary>
        /// نام ستون مشخص کننده بارکد
        /// </summary>
        public string barcodeColumn { get; set; }
        /// <summary>
        /// نام ستون مشخص کننده شهر
        /// </summary>
        public string CityColumn { get; set; }
        /// <summary>
        /// نام ستون مشخص کننده استان
        /// </summary>
        public string provinceColumn { get; set; }
        /// <summary>
        /// نام ستون مشخص کننده بارکد محلی
        /// </summary>
        public string localBarcode { get; set; }
        /// <summary>
        /// نام ستون مشخص کننده جنسیت
        /// </summary>
        public string sex { get; set; }
        /// <summary>
        /// نام ستون مشخص کننده نام واحد
        /// </summary>
        public string unitName { get; set; }
    }
    /// <summary>
    /// مدل پایه بروزرسانی قیمت و موجودی
    /// </summary>
    public class UpdatePriceQtyFileMapModel
    {
        /// <summary>
        /// نام ستون مشخص کننده بارکد
        /// </summary>
        public string barcodeColumn { get; set; }
        /// <summary>
        /// نام ستون مشخص کننده قیمت
        /// </summary>
        public string priceColumn { get; set; }
        /// <summary>
        /// نام ستون مشخص کننده موجودی
        /// </summary>
        public string qtyColumn { get; set; }

    }
    /// <summary>
    /// مدل دریافت لیست بارکدهای مشابه
    /// </summary>
    public class getMathItemWithBarcodeBindingModel
    {
        /// <summary>
        /// لیستی از بارکدها
        /// </summary>
        public List<string> barcodeList { get; set; }
    }
    /// <summary>
    /// مدل پایه انتقال
    /// </summary>
    public class ImportModel
    {
        /// <summary>
        /// شناسه گروه
        /// </summary>
        public long grpId { get; set; }
        /// <summary>
        /// شناسه دسته بندی
        /// </summary>
        public long catId { get; set; }
        /// <summary>
        /// رشته مشخص کننده ستون های مشخصه فنی
        /// </summary>
        public string techHead { get; set; }
        /// <summary>
        /// شناسه وضعیت
        /// </summary>
        public int statusId { get; set; }
        /// <summary>
        /// نوع موجودیت
        /// </summary>
        public short type { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public ImportFileMapModel mapModel { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public UpdatePriceQtyFileMapModel mapUpdateModel { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public System.Data.DataTable data { get; set; }
    }
    /// <summary>
    /// مدل پایه گزارش انتقال
    /// </summary>
    public class ConvertFileModel
    {
        /// <summary>
        /// ردیف
        /// </summary>
        public long id { get; set; }
        /// <summary>
        /// شناسه پنل
        /// </summary>
        public long storeId { get; set; }
        /// <summary>
        /// شناسه گروه
        /// </summary>
        public long groupId { get; set; }
        /// <summary>
        /// مجموع ردیف ها
        /// </summary>
        public int totalRecord { get; set; }
        /// <summary>
        /// کامل/ناقص
        /// </summary>
        public bool isComplete { get; set; }
        /// <summary>
        /// مسیر فایل
        /// </summary>
        public string  documentPath { get; set; }
        /// <summary>
        /// توضیحات
        /// </summary>
        public string dsc { get; set; }
    }
    /// <summary>
    /// 
    /// </summary>
    public class checkBarcodeModel
    {

        public List<string> barcodeList { get; set; }
    }
}
