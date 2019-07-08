using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Data;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// ای پی آی مربوط ویترین فروشگاه
    /// </summary>
    /// 
    [RoutePrefix("Vitrin")]
    public class VitrinController : AdvancedApiController
    {
        /// <summary>
        /// سرویس اضافه کردن ویترین
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("add")]
        [Exception]
        [HttpPost]
        public IHttpActionResult add(vitrinModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addVitrin", "VitrinController_add"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");

                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                model.documents.ForEach(i => {
                    if (i.id == null | i.id == new Guid()) {
                        i.id = i.uid;
                    }
                });
                var documents = ClassToDatatableConvertor.CreateDataTable(model.documents ?? new List<DocumentItemTab>());
                repo.cmd.Parameters.AddWithValue("@title", model.title.getDbValue());
                repo.cmd.Parameters.AddWithValue("@dsc", model.dsc.getDbValue());
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.getLongDbValue());
                repo.cmd.Parameters.AddWithValue("@itemGrpId", model.itemGrpId.getLongDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);



                repo.cmd.Parameters.AddWithValue("@type", model.type.getDbValue());
                repo.cmd.Parameters.AddWithValue("@isHighlight", model.isHighlight.getDbValue());



                var param = repo.cmd.Parameters.AddWithValue("@documents", documents);
                param.SqlDbType = SqlDbType.Structured;
                var outParam = repo.cmd.Parameters.Add("@id", SqlDbType.BigInt);
                outParam.Direction = ParameterDirection.Output;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new {msg=repo.rMsg, id = Convert.ToInt64(outParam.Value)});
            }

        }
        /// <summary>
        /// سرویس آپدیت ویترین 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("update")]
        [Exception]
        [HttpPost]
        public IHttpActionResult update(vitrinModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updateVitrin", "VitrinController_update"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");

                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                var documents = ClassToDatatableConvertor.CreateDataTable(model.documents ?? new List<DocumentItemTab>());
                repo.cmd.Parameters.AddWithValue("@id", model.id);
                repo.cmd.Parameters.AddWithValue("@title", model.title.getDbValue());
                repo.cmd.Parameters.AddWithValue("@dsc", model.dsc.getDbValue());
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.getLongDbValue());
                repo.cmd.Parameters.AddWithValue("@itemGrpId", model.itemGrpId.getLongDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@type", model.type.getDbValue());
                repo.cmd.Parameters.AddWithValue("@isHighlight", model.isHighlight.getDbValue());
                var param = repo.cmd.Parameters.AddWithValue("@documents", documents);
                param.SqlDbType = SqlDbType.Structured;
               
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg});
            }

        }
        /// <summary>
        /// سرویس حذف ویترین فروشگاه
        /// id : شناسه ویترین
        /// شناسه فروشگاه در هدر ست شود
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("delete")]
        [Exception]
        [HttpPost]
        public IHttpActionResult delete(LongKeyModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_deleteVitrin", "VitrinController_delete"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");

                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@id",model.id);
                repo.ExecuteNonQuery();

                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg});
            }

        }
        /// <summary>
        /// سرویس دریافت لیست ویترین های فروشگاه
        /// </summary>
        /// <returns></returns>
        [Route("getStoreVitrinList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStoreVitrinList(getStoreVitrinListSearchModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getStoreVitrinList", "VitrinController_getStoreVitrinList",initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");

                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                if (model.search != null | model.search != "")
                    repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@type", model.type.getDbValue());
                repo.cmd.Parameters.AddWithValue("@isHighlight", model.isHighlight.getDbValue());
                var param = repo.cmd.Parameters.Add("@rcode", SqlDbType.Int);
                param.Direction = ParameterDirection.Output;
                repo.ExecuteAdapter();
                if (Convert.ToInt32(param.Value) == 0)
                    return new NotFoundActionResult("access denied");
                var vitrinInfo = repo.ds.Tables[0];
                var documents = repo.ds.Tables[1];
                return Ok(

                        vitrinInfo.AsEnumerable().Select(row => new
                        {
                            id = Convert.ToInt64(row.Field<object>("id")),
                            title = Convert.ToString(row.Field<object>("title")),
                            item =new IdTitleValue<long>() { id = Convert.ToInt64(row.Field<object>("fk_item_id") is DBNull ? 0 : row.Field<object>("fk_item_id")), title = Convert.ToString(row.Field<object>("itemTitle")) },
                            itemGrp = new IdTitleValue<long>() { id = Convert.ToInt64(row.Field<object>("fk_itemGrp_id") is DBNull ? 0 : row.Field<object>("fk_itemGrp_id")), title = Convert.ToString(row.Field<object>("itemGrpTitle")) },
                            dsc = Convert.ToString(row.Field<object>("description")),
                            documents = documents == null ? null :  documents.AsEnumerable().Where(c => c.Field<object>("id") != null &&  Convert.ToInt64(row.Field<object>("id")) == Convert.ToInt64(c.Field<object>("pk_fk_vitrin_id"))).Select(i => new DocumentItemTab
                            {
                                id = Guid.Parse(i.Field<object>("id").ToString()),
                                downloadLink = Convert.ToString(i.Field<object>("completeLink")),
                                thumbImageUrl = Convert.ToString(i.Field<object>("thumbcompeleteLink")),
                                isDefault = Convert.ToBoolean(i.Field<object>("isPrime"))
                            }).ToList(),
                            fromPrice = Convert.ToString(row.Field<object>("fromPrice")),
                            toPrice = Convert.ToString(row.Field<object>("toPrice")),
                            price = Convert.ToString(row.Field<object>("price_dsc")),
                            priceAfterDiscount = Convert.ToString(row.Field<object>("priceAfterDiscount_dsc")),
                            qty = row.Field<decimal?>("qty"),
                            discount = row.Field<decimal?>("discount_percent"),
                            isNotForSelling = row.Field<bool?>("isNotForSelling"),
                            type = row.Field<short?>("type"),
                            itemCntInCart = row.Field<decimal?>("itemInCart"),
                            vitrinType = row.Field<object>("vitrinType").dbNullCheckShort(),
                            isHighlight = row.Field<object>("isHighlight").dbNullCheckBoolean()

                        }).ToList()
                    );
            }

        }

    }



    public class getStoreVitrinListSearchModel : searchParameterModel
    {
        public bool? isHighlight { get; set; }
    }

    /// <summary>
    /// مدل پایه سرویس های ویترین
    /// </summary>
    public class vitrinModel
    {
        /// <summary>
        /// شناسه ویترین - در ویرایش استفاده می شود
        /// </summary>
        public long id { get; set; }
        /// <summary>
        /// شناسه کالا - می تواند نال باشد
        /// </summary>
        public long? itemId { get; set; }
        /// <summary>
        /// شناسه گروه کالا - می تواند نال باشد
        /// </summary>
        public long? itemGrpId { get; set; }
        /// <summary>
        /// عنوان ویترین
        /// </summary>
        public string title { get; set; }
        /// <summary>
        /// توضیحات ویترین
        /// </summary>
        public string dsc { get; set; }
        /// <summary>
        /// لیستی از تصاویر ویترین - حداکثر 5 عکس
        /// </summary>
        public List<DocumentItemTab> documents { get; set; }
        /// <summary>      
        ///TYPE of vitrin kala = 1 , personel = 2 , job = 3 , shey = 4
        /// </summary>
        public short type { get; set; }
        /// <summary>
        /// برجسته است؟
        /// </summary>
        public bool? isHighlight { get; set; }

    }
   
}
