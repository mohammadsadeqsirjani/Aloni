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
    /// ای پی آی مربوط به اطلاعات آماری موجودیت های مختلف
    /// </summary>

    [RoutePrefix("Statistics")]
    public class StatisticsController : AdvancedApiController
    {
        /// <summary>
        /// سرویس صفحه اصلی فروشگاه
        /// </summary>
        /// <returns></returns>
        [Route("getStoreSale")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStoreSale()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getStoreSale", "StatisticsController_getStoreSale", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteAdapter();

                return Ok(
                    new
                    {
                        saleStatistics = repo.ds.Tables[0].AsEnumerable().Select(i=> new { value = Convert.ToDecimal(i.Field<object>("sale") is DBNull ? 0 : i.Field<object>("sale")),date = Convert.ToString(i.Field<object>("date")) }).ToList(),
                        cash_dsc = repo.ds.Tables[1].AsEnumerable().Select(i=>Convert.ToString(i.Field<object>("account"))).FirstOrDefault(),
                        ItemsWithoutstock = repo.ds.Tables[2].AsEnumerable().Select(i=>Convert.ToInt32(i.Field<object>("withoutstock") is DBNull ? 0 : i.Field<object>("withoutstock"))).FirstOrDefault(),
                        ItemsinOrderPoint = repo.ds.Tables[3].AsEnumerable().Select(i => Convert.ToInt32(i.Field<object>("orderPoint") is DBNull ? 0 : i.Field<object>("orderPoint"))).FirstOrDefault(),
                        orderIsRunning = repo.ds.Tables[4].AsEnumerable().Select(i => Convert.ToInt32(i.Field<object>("orderIsRunning") is DBNull ? 0 : i.Field<object>("orderIsRunning"))).FirstOrDefault(),
                        orderCanceled = repo.ds.Tables[5].AsEnumerable().Select(i => Convert.ToInt32(i.Field<object>("orderCanceled") is DBNull ? 0 : i.Field<object>("orderCanceled"))).FirstOrDefault(),
                        lastOrders = repo.ds.Tables[6].AsEnumerable().Select(i => new { orderId = Convert.ToString(i.Field<object>("orderId")), name = Convert.ToString(i.Field<object>("name")), date = Convert.ToString(i.Field<object>("datetime_")) , detailCount = Convert.ToInt32(i.Field<object>("tedAghlam") is DBNull ? 0 : i.Field<object>("tedAghlam")) }).ToList()
                    });
            }
        }

        /// <summary>
        /// سرویس تعداد پیام ها و اقلام در سفارش
        /// </summary>
        /// <returns></returns>
        [Route("getUserStatistic")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getUserStatistic()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getUserStatistic", "StatisticsController_getUserStatistic", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
             
                repo.ExecuteAdapter();
                return Ok(
                    new
                    {
                        msgCnt = repo.ds.Tables[0].AsEnumerable().Select(i => Convert.ToString(i.Field<object>("msgCnt"))).FirstOrDefault().dbNullCheckInt(),
                        itemInCartCnt = repo.ds.Tables[1].AsEnumerable().Select(i => Convert.ToString(i.Field<object>("itemsInCartsCnt"))).FirstOrDefault().dbNullCheckInt(),
                        cartCnt = repo.ds.Tables[1].AsEnumerable().Select(i => Convert.ToString(i.Field<object>("cartCnt"))).FirstOrDefault().dbNullCheckInt()
                    });
            }
        }

    }
}
