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
    /// تنظیمات پروموشن فروشگاه 
    /// </summary>
    [RoutePrefix("StorePromotion")]
    public class StorePromotionController : AdvancedApiController
    {
        /// <summary>
        /// سرویس اعمال / ویرایش تنظیمات مربوط به پروموشن فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addUpdate")]
        [Exception]
        [HttpPost]
        public IHttpActionResult add(promotionModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addStorePromotion", "StorePromotionController_add"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@promotionPercent", model.promotionPercent.dbNullCheckDecimal());
                repo.cmd.Parameters.AddWithValue("@promotionDsc", model.promotionDsc.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@isActive", model.isActive.dbNullCheckBoolean());
                var id = repo.cmd.Parameters.AddWithValue("@id", model.id.dbNullCheckLong());
                id.Direction = System.Data.ParameterDirection.InputOutput;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new {id = id.Value, msg = repo.rMsg });
            }

        }
        /// <summary>
        /// دریافت تنظیمات پروموشن فروشگاه
        /// </summary>
        /// <returns></returns>
        [Route("get")]
        [Exception]
        [HttpPost]
        public IHttpActionResult get()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getStorePromotion", "StorePromotionController_add",initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId.dbNullCheckLong());
                repo.ExecuteAdapter();
                var info = repo.ds.Tables[0].AsEnumerable();
                if(info.Count() > 0)
                return Ok(
                    info.Select(i => new promotionModel
                    {
                        id = i.Field<long>("id"),
                        promotionPercent = i.Field<decimal>("promotionPercent"),
                        promotionDsc = i.Field<string>("promotionDsc"),
                        isActive = i.Field<bool>("isActive")
                    }

                        ).FirstOrDefault()
                    );
                return Ok(new promotionModel());
            }

        }
    }
    public class promotionModel
    {
        public long id { get; set; }
        [Required(ErrorMessage = " فیلد اجباری")]
        public decimal promotionPercent { get; set; }
        [Required(ErrorMessage = " فیلد اجباری")]
        public string promotionDsc { get; set; }
        [Required(ErrorMessage = " فیلد اجباری")]
        public bool isActive { get; set; }
    }
}
