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
    /// ای پی آی مربوط به ثبت کالاهای دارای استثنا در روش تحویلی
    /// </summary>
    [RoutePrefix("DeliveryMethodException")]
    public class DeliveryMethodExceptionController : AdvancedApiController
    {
       /// <summary>
       /// سرویس اضافه کردن کالا/گروه کالا و روش ارسال غیر قابل استفاده 
       /// </summary>
       /// <param name="model"></param>
       /// <returns></returns>
        [Route("addUpdate")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addUpdate(DeliveryMethodExceptionBindingModel model)
        {
          
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SPA_DeliveryMethodExceptionAddUpdate", "DeliveryMethodExceptionController_addUpdate"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@deliveryMethod", model.deliveryMethod.id.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@itemGrpId", model.itemGrpId.dbNullCheckLong());
                var outParam = repo.cmd.Parameters.AddWithValue("@id", model.id.dbNullCheckInt());
                outParam.Direction = ParameterDirection.InputOutput;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { id = outParam.Value, msg = repo.rMsg });

            }
        }
        /// <summary>
        /// دریافت لیست کالاها یا گرو های کالایی که در روش ارسال محدودیت دارند
        /// </summary>
        /// <returns></returns>
        [Route("get")]
        [Exception]
        [HttpPost]
        public IHttpActionResult get(searchParameterModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SPA_getStoreDeliveryMethodException", "DeliveryMethodException_get", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@search", model.search.dbNullCheckString());
                repo.ExecuteAdapter();
                var result = repo.ds.Tables[0];
                return Ok(result.AsEnumerable().Select(
                    row => new DeliveryMethodExceptionBindingModel
                    {
                        id = Convert.ToInt32(row.Field<object>("id")),
                        itemId = Convert.ToInt64(row.Field<object>("fk_item_id")),
                        itemGrpId = Convert.ToInt64(row.Field<object>("fk_itemgrp_id")),
                        deliveryMethod =new IdTitleValue<short> { id = Convert.ToInt16(row.Field<object>("fk_deliveryMethod_id")),title = Convert.ToString(row.Field<object>("title")) },
                    }
                    ).ToList());
            }
        }
        /// <summary>
        /// سرویس دریافت لیست روش های ارسال 
        /// </summary>
        /// <returns></returns>
        [Route("getDeliveryMethodList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getDeliveryMethodList()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SPA_getDeliveryMethodList", "DeliveryMethodException_getDeliveryMethodList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
              
                repo.ExecuteAdapter();
                var result = repo.ds.Tables[0];
                return Ok(result.AsEnumerable().Select(
                    row => new 
                    {
                        id = Convert.ToInt16(row.Field<object>("id")),
                        title = Convert.ToString(row.Field<object>("title")) 
                    }
                    ).ToList());
            }
        }

    }
    /// <summary>
    /// مدل پایه برای سرویس های استثنا
    /// </summary>
    public class DeliveryMethodExceptionBindingModel
    {
        /// <summary>
        /// شناسه استثنا
        /// </summary>
        public int id { get; set; }
        /// <summary>
        /// شناسه کالا
        /// Nullable
        /// </summary>
        public long? itemId { get; set; }
        /// <summary>
        ///شناسه گروه کالایی
        ///Nullable
        /// </summary>
        public long? itemGrpId { get; set; }
        /// <summary>
        /// روش ارسال استثنا
        /// </summary>
        [Required(ErrorMessage ="انتخاب روش ارسال الزامی است")]
        public IdTitleValue<short> deliveryMethod { get; set; }
    }
}
