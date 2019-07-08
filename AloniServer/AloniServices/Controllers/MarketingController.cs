using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Data;
namespace AloniServices.Controllers
{
    /// <summary>
    /// ای پی آی بازاریابی
    /// </summary>
    [RoutePrefix("Marketing")]
    public class MarketingController : AdvancedApiController
    {
        /// <summary>
        /// سرویس افزودن پلن بازاریابی جدید
        /// فروشگاه در هدر ست شود
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addPlan")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addPlan(Plan model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this,"SP_addPlan","MarketingController_addPlan"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if(!repo.hasAccess)
                //{
                //    return new ForbiddenActionResult();
                //}
                repo.cmd.Parameters.AddWithValue("@title", model.title.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@minComission", model.minComission.dbNullCheckDecimal());
                repo.cmd.Parameters.AddWithValue("@validityDate", model.validityDate.dbNullCheckDatetime());
                repo.cmd.Parameters.AddWithValue("@isActive", model.isActive.dbNullCheckBoolean());
                var outId = repo.cmd.Parameters.AddWithValue("@id",model.id.dbNullCheckLong());
                outId.Direction = ParameterDirection.InputOutput;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg, id = outId.Value });
            }
        }
        /// <summary>
        /// سرویس دریافت لیست پلن های بازاریابی فروشگاه
        /// شناسه فروشگاه در هدر ست شود
        /// </summary>
        /// <returns></returns>
        [Route("getStorePlanList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStorePlanList()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getStorePlanList", "MarketingController_getStorePlanList",initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if(!repo.hasAccess)
                //{
                //    return new ForbiddenActionResult();
                //}
              
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i => new
                {
                    id = Convert.ToInt64(i.Field<object>("id")),
                    title = Convert.ToString(i.Field<object>("title")),
                    minCommission = Convert.ToDecimal(i.Field<object>("minCommission") is DBNull ? 0 : i.Field<object>("minCommission")),
                    maxCommission = Convert.ToDecimal(i.Field<object>("maxCommission") is DBNull ? 0 : i.Field<object>("maxCommission")),
                    validityDate = Convert.ToString(i.Field<object>("validityDate")),
                    status = Convert.ToString(i.Field<object>("status")),
                    memberCount = Convert.ToInt32(i.Field<object>("memberCount") is DBNull ? 0 : i.Field<object>("memberCount")),
                    isActive = Convert.ToBoolean(i.Field<object>("isActive"))
                }));
            }
        }
        /// <summary>
        /// سرویس دریافت لیست مشترکین پلن بازاریابی
        /// </summary>
        /// <returns></returns>
        [Route("getStorePlannersSubscriberList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStorePlannersSubscriberList(getStorePlannersSubscriberModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getStorePlannersSubscriberList", "MarketingController_getStorePlannersSubscriberList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if(!repo.hasAccess)
                //{
                //    return new ForbiddenActionResult();
                //}
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@planId", model.planId);
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i => new
                {
                    userId = Convert.ToInt64(i.Field<object>("id")),
                    name = Convert.ToString(i.Field<object>("name")),
                    commission = Convert.ToString(i.Field<object>("comission")),
                    status = Convert.ToString(i.Field<object>("status")),
                    subSetNumber = Convert.ToInt32(repo.ds.Tables[1].AsEnumerable().Where(c => Convert.ToInt64(c.Field<object>("fk_parent_usr_id")) == Convert.ToInt64(i.Field<object>("id"))).Select(c => c.Field<object>("member")).FirstOrDefault())
                }));
            }
        }
        /// <summary>
        /// سرویس جوین شدن یوزر به پلن بازاریابی
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addSubscribe")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addSubscribe(Member model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addSubscribe", "MarketingController_addSubscribe"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if(!repo.hasAccess)
                //{
                //    return new ForbiddenActionResult();
                //}
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@parentUserId", model.parentUserId);
                repo.cmd.Parameters.AddWithValue("@subscribeUserId", model.userId);
                repo.cmd.Parameters.AddWithValue("@planId", model.planId);
                repo.ExecuteAdapter();
                if (repo.rCode == 0)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// دعوت از کاربر برای عضویت در پلن بازاریابی فروشگاه
        /// </summary>
        /// <returns></returns>
        [Route("inviteUserToMarketingStorePlan")]
        [Exception]
        [HttpPost]
        public IHttpActionResult inviteUserToMarketingStorePlan(InviteToStoreMarketingPlan model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_inviteUserToMarketingStorePlan", "MarketingController_inviteUserToMarketingStorePlan"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@userMobile", model.mobile);
                repo.ExecuteAdapter();
                if (repo.rCode == 0)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
               
            }
        }
    }
    /// <summary>
    /// مدل پایه پلن بازاریابی
    /// </summary>
    public class Plan
    {
        /// <summary>
        /// شناسه
        /// </summary>
        public long id { get; set; }
        /// <summary>
        /// عنوان
        /// </summary>
        public string title { get; set; }
        /// <summary>
        /// حداقل پورسانت
        /// </summary>
        public decimal minComission { get; set; }
        /// <summary>
        /// حداکثر پورسانت
        /// </summary>
        public decimal maxCommision { get; set; }
        /// <summary>
        /// تاریخ معتبر بودن پلن
        /// </summary>
        public DateTime validityDate { get; set; }
        /// <summary>
        /// وضعیت فعال بودن یا نبودن پلن
        /// </summary>
        public bool isActive { get; set; }

    }
    /// <summary>
    /// مدل پایه عضو در پلن بازاریابی
    /// </summary>
    public class Member
    {
        /// <summary>
        /// شناسه سرشاخه پلن
        /// میتواند نال باشد
        /// </summary>
        public long? parentUserId { get; set; }
        /// <summary>
        /// شناسه کاربر زیر شاخه
        /// </summary>
        public long userId { get; set; }
        /// <summary>
        /// شناسه پلن درآمدی
        /// </summary>
        public long planId { get; set; }
    }
    /// <summary>
    /// مدل پایه دعوت کاربر به طرح بازاریابی فروشگاه
    /// </summary>
    public class InviteToStoreMarketingPlan
    {
        /// <summary>
        /// شماره موبایل کاربر
        /// </summary>
        public string mobile { get; set; }
    }
    public class getStorePlannersSubscriberModel:searchParameterModel
    {
        public long planId { get; set; }

    }
}
