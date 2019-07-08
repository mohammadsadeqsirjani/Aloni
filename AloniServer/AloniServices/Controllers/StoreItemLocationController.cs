using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// سرویس های مربوط به لوکیشن پیشفرض موجودیت های سیستم
    /// </summary>
    [RoutePrefix("storeItemLocation")]
    public class StoreItemLocationController : AdvancedApiController
    {
        /// <summary>
        /// افزودن یا ویرایش موقعیت  جغرافیایی پیشفرض جدید
        /// شناسه فروشگاه در هدر ست شود
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addUpdate")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addUpdate(storeItemLocationAddUpdateBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);


            using (var repo = new Repo(this, "SP_storeItemLocationAdd", "SP_storeItemLocationAdd_addUpdate"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@title", model.title.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@lat", model.lat.dbNullCheckDouble());
                repo.cmd.Parameters.AddWithValue("@lng", model.lng.dbNullCheckDouble());
                repo.cmd.Parameters.AddWithValue("@address", model.address.dbNullCheckString());
                var param = repo.cmd.Parameters.AddWithValue("@id",model.id.dbNullCheckLong());
                param.Direction = System.Data.ParameterDirection.InputOutput;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new {id = param.Value, msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس حذف موقعیت جغرافیایی 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("delete")]
        [Exception]
        [HttpPost]
        public IHttpActionResult delete(deleteStoreFavoriteLocationBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);


            using (var repo = new Repo(this, "SP_storeItemLocationDelete", "SP_storeItemLocationDelete_delete"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
              
                repo.cmd.Parameters.AddWithValue("@id", model.id.dbNullCheckLong());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg});
            }
        }

        /// <summary>
        ///  سرویس دریافت لیست موقعیت جغرافیایی یک آیتم 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("get")]
        [Exception]
        [HttpPost]
        public IHttpActionResult get()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);


            using (var repo = new Repo(this, "SP_storeItemLocationGet", "SP_storeItemLocationGet_get",initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                repo.cmd.Parameters.AddWithValue("@storeId", storeId.dbNullCheckLong());
                
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(c =>
                    new storeItemLocationAddUpdateBindingModel
                    {
                        id = Convert.ToInt64(c.Field<object>("id")),
                        title = Convert.ToString(c.Field<object>("title")),
                        lat = Convert.ToSingle(c.Field<object>("lat")),
                        lng = Convert.ToSingle(c.Field<object>("lng")),
                        address = Convert.ToString(c.Field<object>("address"))
                    }).ToList());
            }
        }



    }
    /// <summary>
    /// مدل حذف لوکیشن نشان شده
    /// </summary>
    public class deleteStoreFavoriteLocationBindingModel
    {
        [Required]
        public long id { get; set; }
    }
    /// <summary>
    /// مدل پایه افزودن آدرس پیشفرض جدید
    /// </summary>
    public class storeItemLocationAddUpdateBindingModel
    {
        /// <summary>
        /// شناسه موقعیت جغرافیایی پیش فرض
        /// </summary>
        public long id { get; set; }
        /// <summary>
        /// عنوان دلخواه
        /// </summary>
        /// 
        [Required]
        public string title { get; set; }
        /// <summary>
        /// طول جغرافیای
        /// </summary>
        /// 
        [Required]
        public float lat { get; set; }
        /// <summary>
        /// عرض جغرافیایی
        /// </summary>
        /// 
        [Required]
        public float lng { get; set; }
        /// <summary>
        /// آدرس 
        /// </summary>
        /// 
        [Required]
        public string address { get; set; }
    }
}
