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
    /// 
    /// </summary>
    
    [RoutePrefix("size")]
    public class SizeController : AdvancedApiController
    {
        /// <summary>
        /// سرویس دریافت لیست سایزهای کالای فروشگاه
        /// برای یک آیتم شناسه آیتم مورد نظر در parent  ست شود
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getItemSizeList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getItemSizeList(searchParameterModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getItemSizeList", "itemController_getItemSizeList", autenticationMode.NoAuthenticationRequired, initAsReader: true, checkAccess: false))
            {
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.ExecuteAdapter();
                var items = repo.ds.Tables[0].AsEnumerable();
                var sizeList = repo.ds.Tables[1].AsEnumerable();
                return Ok(
                        items.Select(row => new {
                            item = new IdTitleValue<long> { id = Convert.ToInt64(row.Field<object>("id")), title = Convert.ToString(row.Field<object>("title")) },
                            sizeList = sizeList.Where(c => Convert.ToInt64(row.Field<object>("id")) == Convert.ToInt64(c.Field<object>("itemId"))).Select(m => new ItemSizeModel
                            {
                                sizeInfo = Convert.ToString(m.Field<object>("sizeInfo")),
                                isActive = Convert.ToBoolean(m.Field<object>("isActive")),
                                sizeCost = Convert.ToDecimal(m.Field<object>("sizeCost"))
                            }).ToList()

                        }).ToList()

                    );
            }
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addUpdateItemSize")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addUpdateItemSize(addUpdateItemSizeBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addUpdateItemSize", "itemController_addUpdateItemSize"))
            {
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@sizeInfo", model.sizeInfo.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@isActive", model.isActive.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@sizeCost", model.sizeCost.dbNullCheckDecimal());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new messageModel(repo.rMsg));
            }
        }
        /// <summary>
        /// حذف سایز یک آیتم
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("deleteItemSize")]
        [Exception]
        [HttpPost]
        public IHttpActionResult deleteItemSize(addUpdateItemSizeBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);


            using (var repo = new Repo(this, "SP_deleteItemSize", "colorController_deleteItemSize"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@sizeInfo", model.sizeInfo.dbNullCheckString());

                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { repo.rMsg });
            }

        }
    }
}
