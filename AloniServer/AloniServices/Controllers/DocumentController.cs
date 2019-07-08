using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// ای پی آی مربوط به مدیریت اسناد
    /// </summary>
    [RoutePrefix("Document")]
    public class DocumentController : AdvancedApiController
    {
        /// <summary>
        /// سرویس اضافه کردن مشخصات فایل آپلود شده 
        /// این سرویس توسط سرور دی ام اس فراخوانی می شود 
        /// </summary>
        /// <param name="model">
        /// پارامتر سرچ در ورودی به صورت اختیاری ست شود
        /// </param>
        /// <returns></returns>
        [Route("add")]
        [Exception]
        [HttpPost]
        public IHttpActionResult Add(docListBindingModel model)
        {
            if (!ModelState.IsValid)
            {
                return new BadRequestActionResult("ModelState.Values");
            }

            using (var repo = new Repo(this, "SP_addDocument","DocumentController_add"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@file_Name",model.file_Name.getDbValue());
                repo.cmd.Parameters.AddWithValue("@caption", model.caption.getDbValue());
                repo.cmd.Parameters.AddWithValue("@fk_documentType_id", model.fk_documentType_id);
                repo.cmd.Parameters.AddWithValue("@description", model.description.getDbValue());
                repo.cmd.Parameters.AddWithValue("@isDefault", model.isDefault);
                repo.cmd.Parameters.AddWithValue("@fk_EntityId", model.fk_EntityId);
                repo.cmd.Parameters.AddWithValue("@uid", Guid.Parse(model.uid));
                repo.cmd.Parameters.AddWithValue("@link", model.dmsUrl);
                repo.ExecuteNonQuery();
                //if (repo.rCode != 1)
                //    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
          
        }
        /// <summary>
        /// سرویس دریافت لیست تصاویر یک فروشگاه،کالا و یا کاربر به صورت مرتب شده از جدید به قدیم
        /// </summary>
        /// <param name="model">
        /// docListBindingModel در این سرویس فقط نوع موجودیت و کد موجودیت ست شود
        /// </param>
        /// <returns></returns>
        [Route("docList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult GetDocumentList(docListBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<docListBindingModel> result = new List<docListBindingModel>();
            
            using (var repo = new Repo(this, "SP_getDocument", "DocumentController_docList",initAsReader: true))
            {
                //if (repo.unauthorized)
                //    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@fk_EntityId", model.fk_EntityId);
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@fk_TypeId", model.fk_documentType_id);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteReader();
                while (repo.sdr.Read())
                {
                    docListBindingModel item = new docListBindingModel();
                    item.downloadLink = Convert.ToString(repo.sdr["ImageUrl"]);
                    item.thumbImageUrl = Convert.ToString(repo.sdr["thumbImageUrl"]);
                    item.isDefault = Convert.ToBoolean(repo.sdr["isDefault"] is DBNull ? false : repo.sdr["isDefault"]);
                    item.uid = Convert.ToString(repo.sdr["id"]);
                    item.fk_documentType_id = Convert.ToInt32(repo.sdr["fk_documentType_id"]);
                    result.Add(item);
                }
            }
            return Ok(result);
        }
        /// <summary>
        /// سرویس حذف مستندات
        /// </summary>
        /// <param name="model">
        /// فقط آی دی مستندات وارد شود</param>
        /// <returns></returns>
        [Route("delete")]
        [Exception]
        [HttpPost]
        public IHttpActionResult delete(EntityDocumentModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult("ModelState.Values");
            using (var repo = new Repo(this, "SP_deleteDocument", "DocumentController_delete"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                DataTable docInfo = ClassToDatatableConvertor.CreateDataTable(model.docItemList);
                var param = repo.cmd.Parameters.AddWithValue("@DocInfoItem", docInfo);
                repo.cmd.Parameters.AddWithValue("@fk_entityId", model.fk_EntityId);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@fk_documentType_id", model.fk_documentType_id);
                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new {msg = repo.rMsg });
            }
           
        }
        /// <summary>
        /// سرویس دریافت مستندات فروشگاه
        /// </summary>
        /// <param name="model">
        /// شناسه فروشگاه در هدر ست شود</param>
        /// <returns></returns>
        [Route("getAllDocumentListAboutStore")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getAllDocumentListAboutStore(searchParameterModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getAllDocumentListAboutStore", "DocumentController_getAllDocumentListAboutStore", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.ExecuteAdapter();
                var result = repo.ds.Tables[0];
                return Ok(result.AsEnumerable().Select(row =>
                new
                {
                    downloadLink = Convert.ToString(row.Field<object>("ImageUrl")),
                    thumbImage = Convert.ToString(row.Field<object>("thumbImageUrl")),
                    fk_documentType_id = Convert.ToInt32(row.Field<object>("fk_documentType_id") is DBNull ? 0 : row.Field<object>("fk_documentType_id")),
                    uid = Convert.ToString(row.Field<object>("id")),
                    isDefault = Convert.ToBoolean(row.Field<object>("isDefault") is DBNull ? false : row.Field<object>("isDefault"))
                }).ToList());
            }
           
        }
        /// <summary>
        /// سرویس دریافت تصاویر فروشگاه
        /// شناسه فروشگاه در هدر ست شود
        /// </summary>
        /// <returns></returns>
        [Route("getStoreDocument")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStoreDocument()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getAllDocumentListAboutStore", "DocumentController_getAllDocumentListAboutStore", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@justStore",true);
                repo.ExecuteAdapter();
                var result = repo.ds.Tables[0];
                return Ok(result.AsEnumerable().Select(row =>
                new
                {
                    downloadLink = Convert.ToString(row.Field<object>("ImageUrl")),
                    thumbImage = Convert.ToString(row.Field<object>("thumbImageUrl")),
                    fk_documentType_id = Convert.ToInt32(row.Field<object>("fk_documentType_id") is DBNull ? 0 : row.Field<object>("fk_documentType_id")),
                    uid = Convert.ToString(row.Field<object>("id")),
                    isDefault = Convert.ToBoolean(row.Field<object>("isDefault") is DBNull ? false : row.Field<object>("isDefault"))
                }).ToList());
            }

        }
        /// <summary>
        /// سرویس ثبت مستندات بر اساس مستندات
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addEntityDocument")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addEntityDocument(EntityDocumentModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addEntityDocument", "DocumentController_addEntityDocument"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                DataTable docInfo = ClassToDatatableConvertor.CreateDataTable(model.docItemList);
                repo.cmd.Parameters.AddWithValue("@entityId", model.fk_EntityId);
                var param = repo.cmd.Parameters.AddWithValue("@DocInfoItem", docInfo);
                repo.cmd.Parameters.AddWithValue("@fk_documentType_id", model.fk_documentType_id);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس تعیین عکس شاخص یک موجودیت
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("setEntityDefualtDocument")]
        [Exception]
        [HttpPost]
        public IHttpActionResult setEntityDefualtDocument(docListBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_setEntityDefualtDocument", "DocumentController_setEntityDefualtDocument"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                
                repo.cmd.Parameters.AddWithValue("@entityId", model.fk_EntityId);
                repo.cmd.Parameters.AddWithValue("@uid", Guid.Parse(model.uid));
                repo.cmd.Parameters.AddWithValue("@fk_documentType_id", model.fk_documentType_id);
               
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { repo.rMsg });
            }
        }
        /// <summary>
        /// مدل پایه داکیومنت
        /// </summary>
        public class docListBindingModel:searchParameterModel
        {
            /// <summary>
            /// نام فایل
            /// </summary>
            public string file_Name { get; set; }
            /// <summary>
            /// عنوان
            /// </summary>
            public string caption { get; set; }
            /// <summary>
            /// نوع سند
            /// 1 = مجوزها
            /// 2 = تصوير کالا
            /// 3 = تصوير فروشگاه
            /// 4 = تصوير کاربر
            /// </summary>
            public int fk_documentType_id { get; set; }
            /// <summary>
            /// توضیحات
            /// </summary>
            public string description { get; set; }
            /// <summary>
            /// کد فروشگاه، کالا و یا کاربر
            /// </summary>
            public long fk_EntityId { get; set; }
            /// <summary>
            /// تصویر شاخص
            /// </summary>
            public bool isDefault { get; set; }
            /// <summary>
            /// جی یو ای دی هست . خود سیستم تولید میکند
            /// </summary>
            public string uid { get; set; }
            /// <summary>
            /// آدرس سرور دی ام اس
            /// </summary>
            public string dmsUrl { get; set; }
            /// <summary>
            /// لینک دانلود فایل
            /// </summary>
            public string downloadLink { get; set; }
            /// <summary>
            /// لینک تصویر سایز کوچیک
            /// </summary>
            public string thumbImageUrl { get; set; }

        }
        /// <summary>
        /// مدل پایه سرویس  مستندات بر اساس موجودیت 
        /// </summary>
        public class EntityDocumentModel
        {
            /// <summary>
            /// شناسه موجودیت این موجودیت می تواند کالا،پرسنل،شغل و ... باشد
            /// </summary>
            public long fk_EntityId { get; set; }
            /// <summary>
            /// نوع داکیومنت که عبارت است از :
            /// 1	مجوزها 	
            /// 2	تصوير کالا	
            /// 3	تصوير فروشگاه	
            /// 4	تصوير کاربر	
            /// 5	لوگوي فروشگاه	
            /// 6	تصوير ارزيابي کالا	
            /// 7	تصوير گروه کالا	
            /// 8	تصوير پرسنل دمو	
            /// 9	تصوير ويترين فروشگاه	
            /// 10	تصوير درباره فروشگاه	
            /// 11	تصوير تبليغ	
            /// 12	تصوير نظرسنجي	
            /// 13	تصوير کامنت نظرسنجي	
            /// 14	تصوير پيشنهاد شده براي کالاي مرجع
            /// </summary>
            public int fk_documentType_id { get; set; }
            /// <summary>
            /// لیست تصاویر و یا داکیومنت های مربوط به یک موجودیت
            /// </summary>
            public List<DocumentItemTab> docItemList { get; set; }
        }
    }
}
