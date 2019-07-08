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
    /// ای پی آی مربوط به افزدون - حذف کالاهای مورد علاقه یک پنل
    /// </summary>
    /// 
    [RoutePrefix("StoreFavoriteItem")]
    public class StoreItemFavoriteController : AdvancedApiController
    {
        /// <summary>
        /// افزودن یک آیتم به علاقه مندی
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [Exception]
        [Route("add")]
        public IHttpActionResult add(StoreItemFavoriteBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addFavoriteItem", "StoreFavoriteItemController_add"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.dbNullCheckLong());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// حذف آیتم از لیست علاقه مندی
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        [Exception]
        [Route("delete")]
        public IHttpActionResult delete(StoreItemFavoriteBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_deleteFavoriteItem", "StoreFavoriteItemController_delete"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.dbNullCheckLong());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg});
            }
        }
        /// <summary>
        /// دریافت لیست آیتم های مورد علاقه کاربر در یک چنل
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [Exception]
        [Route("getList")]
        public IHttpActionResult getList()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getFavoriteItem", "StoreFavoriteItemController_getList",initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i => new {
                    itemId = i.Field<object>("id"),
                    itemTitle = i.Field<object>("title"),
                    storeId = i.Field<object>("storeId"),
                    storeTitle = i.Field<object>("storeTitle"),
                    itemLogo = i.Field<object>("thumbcompeleteLink")
                }).ToList());
            }
        }
    }
    /// <summary>
    /// مدل پایه
    /// </summary>
    public class StoreItemFavoriteBindingModel
    {
        /// <summary>
        /// شناسه آیتم
        /// </summary>
        public long itemId { get; set; }
    }
}
