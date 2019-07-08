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
    /// ای پی آی مدیریت مشتریان فروشگاه
    /// </summary>
    [RoutePrefix("Customer")]
    public class CustomerController : AdvancedApiController
    {
        /// <summary>
        /// سرویس دریافت مشخصات مشتری بر اساس شناسه یکتا
        /// </summary>
        /// <param name="model">
        /// شناسه فروشگاه در هدر ست شود
        /// شناسه یکتا
        /// </param>
        /// <returns></returns>
        [Route("getCustomerByUniqId")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getCustomerByUniqId(getCustomerByUniqIdModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getCustomerByUniqId", "CustomerController_getCustomerByUniqId"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@id_str", model.id_str);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteAdapter();
                //if (repo.rCode != 1)
                //    return new NotFoundActionResult(repo.rMsg);
                var result = repo.ds.Tables[0];
                return Ok(result.AsEnumerable().Select(
                    row => new
                    {
                        id = Convert.ToInt64(row.Field<object>("id")),
                        name = Convert.ToString(row.Field<object>("name")),
                        mobile = Convert.ToString(row.Field<object>("mobile")),
                        pic = Convert.ToString(row.Field<object>("completeLink")),
                        thumbPic = Convert.ToString(row.Field<object>("thumbcompeleteLink"))
                    }
                    ).FirstOrDefault());
            }
        }
        /// <summary>
        /// سرویس لیست اشخاص خرید کرده عضو نشده در فروشگاه
        /// </summary>
        /// <param name="model">
        /// در هدر شناسه فروشگاه ست شود
        /// </param>
        /// <returns></returns>
        [Route("getCustomerListByOrder")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getCustomerListByOrder(searchParameterModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getCustomerListByOrder", "CustomerController_getCustomerListByOrder", initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@search", model.search);
                var msg = repo.cmd.Parameters.Add("@rMsg", SqlDbType.NVarChar);
                msg.Size = 500;
                msg.Direction = ParameterDirection.Output;
                repo.ExecuteAdapter();
                if (repo.ds.Tables.Count == 0)
                    return new NotFoundActionResult(Convert.ToString(msg.Value));
                var result = repo.ds.Tables[0];
                return Ok(result.AsEnumerable().Select(
                    row => new
                    {
                        id = Convert.ToInt64(row.Field<object>("id")),
                        name = Convert.ToString(row.Field<object>("name")),
                        mobile = Convert.ToString(row.Field<object>("mobile")),
                        pic = Convert.ToString(row.Field<object>("completeLink")),
                        thumbPic = Convert.ToString(row.Field<object>("thumbcompeleteLink"))
                    }
                    ).ToList());
            }
        }
        /// <summary>
        ///سرویس دریافت اطلاعات کاربر بر اساس شماره تلفن
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getCustomerByPhone")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getCustomerByPhone(getCustomerByPhoneModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getCustomerByPhone", "CustomerControllerController_getCustomerByPhone"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@phone", model.phone);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteAdapter();
                if (repo.rCode == 0 | repo.rCode == 1)
                    return new NotFoundActionResult(repo.rMsg);
                var result = repo.ds.Tables[0];
                return Ok(result.AsEnumerable().Select(
                    row => new
                    {
                        id = Convert.ToInt64(row.Field<object>("id")),
                        name = Convert.ToString(row.Field<object>("name")),
                        mobile = Convert.ToString(row.Field<object>("mobile")),
                        pic = Convert.ToString(row.Field<object>("completeLink")),
                        thumbPic = Convert.ToString(row.Field<object>("thumbcompeleteLink"))
                    }
                    ).FirstOrDefault());
            }
        }
        /// <summary>
        /// سرویس لیست مشتریان فروشگاه 
        /// </summary>
        /// <param name="model">
        /// شناسه فروشگاه در هدر ست شود
        /// </param>
        /// <returns></returns>
        [Route("getCustomerListOfStore")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getCustomerListOfStore(getCustomerListOfStoreModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getCustomerListOfStore", "CustomerController_getCustomerListOfStore", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@status", model.state);
                var msg = repo.cmd.Parameters.Add("@rMsg", SqlDbType.NVarChar);
                msg.Size = 500;
                msg.Direction = ParameterDirection.Output;
                repo.ExecuteAdapter();
                if (repo.ds.Tables.Count == 0)
                    return new NotFoundActionResult(Convert.ToString(msg.Value));
                var result = repo.ds.Tables[0];
                return Ok(result.AsEnumerable().Select(
                    row => new
                    {
                        id = Convert.ToInt64(row.Field<object>("id")),
                        name = Convert.ToString(row.Field<object>("name")),
                        mobile = Convert.ToString(row.Field<object>("mobile")),
                        pic = Convert.ToString(row.Field<object>("completeLink")),
                        thumbPic = Convert.ToString(row.Field<object>("thumbcompeleteLink")),
                        storeGroupingId = Convert.ToInt64(row.Field<object>("sgId")),
                        storeGroupingtitle = Convert.ToString(row.Field<object>("title")),
                        storeGroupingDiscountPercent = Convert.ToDecimal(row.Field<object>("discountPercent"))
                    }
                    ).ToList());
            }
        }
        /// <summary>
        /// سرویس افزودن مشتری به فروشگاه
        /// </summary>
        /// <param name="model">
        /// شناسه فروشگاه در هدر ست شود</param>
        /// <returns></returns>
        [Route("joinToStoreByUser")]
        [Exception]
        [HttpPost]
        public IHttpActionResult joinToStoreByUser(joinCustomerToStoreModel model)
        {
            if(model.userId == 0)
                return new BadRequestActionResult(ModelState.Values);
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_joinCustomerToStore", "CustomerController_joinToStoreByUser"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@customerId", model.userId);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@fk_storeGroupingId", model.fk_storeGroupId.dbNullCheckLong());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
               
            }
        }
        /// <summary>
        /// سرویس حذف و یا بلاک کردن مشتری از لیست مشتریان فروشگاه
        /// </summary>
        /// <returns></returns>
        [Route("deleteOrBlockCustomer")]
        [Exception]
        [HttpPost]
        public IHttpActionResult deleteOrBlockCustomer(deleteCustomerFromStoreModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_deleteCustomerFromStore", "CustomerController_deleteCustomer"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@customerId", model.userId);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@state", model.state); 
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });

            }
        }
        /// <summary>
        /// سرویس درخواست عضویت فروشگاه توسط مشتری
        /// </summary>
        /// <returns></returns>
        [Route("joinCustomerToStore")]
        [Exception]
        [HttpPost]
        public IHttpActionResult joinCustomerToStore(joinCustomerToStoreModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_joinToStoreByUser", "CustomerController_joinCustomerToStore"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });

            }
        }

        /// <summary>
        /// سرویس درخواست عدم عضویت فروشگاه توسط مشتری
        /// </summary>
        /// <returns></returns>
        [Route("leftCustomerFromStore")]
        [Exception]
        [HttpPost]
        public IHttpActionResult LeftCustomerFromStore(joinCustomerToStoreModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_leftCustomerFromStore", "CustomerController_leftCustomerToStore"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });

            }
        }
        /// <summary>
        /// سرویس دریافت متن دعوتنامه
        /// </summary>
        /// <returns></returns>
        [Route("getInvitationText")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getInvitationText()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getInvitationText", "CustomerController_getInvitationText"))
            {
                if (repo.unauthorized)
                {
                    return new UnauthorizedActionResult("Unauthorized!");
                }
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.ExecuteNonQuery();
                return Ok(new { msg = repo.rMsg });

            }
        }
        /// <summary>
        /// سرویس نشان شده ها
        /// </summary>
        /// <returns></returns>
        [Route("getTaggedList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getTaggedList()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getTaggedList", "CustomerController_getTaggedList",initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i=> new {

                    storeId = Convert.ToInt64(i.Field<object>("id")),
                    storeTitle = Convert.ToString(i.Field<object>("title")),
                    storeLogo = repo.ds.Tables[1].AsEnumerable().Where(j=> Convert.ToInt64(j.Field<object>("id")) == Convert.ToInt64(i.Field<object>("id"))).Select(m=> Convert.ToString(m.Field<object>("completeLink"))).FirstOrDefault(),
                    thumbStoreLogo = repo.ds.Tables[1].AsEnumerable().Where(j => Convert.ToInt64(j.Field<object>("id")) == Convert.ToInt64(i.Field<object>("id"))).Select(m => Convert.ToString(m.Field<object>("thumbcompeleteLink"))).FirstOrDefault(),
                    storeAddress = Convert.ToString(i.Field<object>("address")),
                    storeState = Convert.ToString(i.Field<object>("storeStatus")),
                    statusId = Convert.ToInt32(i.Field<object>("stId"))

                }).ToList());

            }
        }
        /// <summary>
        /// سرویس فعالیت های اخیر کاربر
        /// </summary>
        /// <returns></returns>
        [Route("getRecentActivityList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getRecentActivityList()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getRecentActivityList", "CustomerController_getRecentActivityList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i => new {

                    title = Convert.ToString(i.Field<object>("title")),
                    storeLogo = Convert.ToString(i.Field<object>("completeLink")),
                    thumbStoreLogo = Convert.ToString(i.Field<object>("thumbcompeleteLink")),
                    datetime = Convert.ToString(i.Field<object>("datetime_")),
                    sentUserId = Convert.ToInt64(i.Field<object>("fk_sent_usr_id")),
                    storeId = Convert.ToInt64(i.Field<object>("id"))

                }).ToList());

            }
        }

    }
    /// <summary>
    /// مدل سرویس لیست مشتریان فروشگاه
    /// </summary>
    public class getCustomerListOfStoreModel : searchParameterModel
    {
        /// <summary>
        /// وضعیت ها
        /// 1. مشتریان فعال
        /// 2.مشتریان انصرافی
        /// 3.مشتریان بلاک شده
        /// 4.درخواست عضویت
        /// </summary>
        public short state { get; set; }
    }
    /// <summary>
    /// مدل سرویس افزودن مشتری به فروشگاه
    /// </summary>
    public class joinCustomerToStoreModel
    {
        /// <summary>
        /// شناسه کاربر
        /// </summary>
        public long userId { get; set; }
        /// <summary>
        /// شناسه گروه بندی مشتریان مثلا مشتریان برنزی، طلایی و ...
        /// </summary>
        public long? fk_storeGroupId { get; set; }
    }
    /// <summary>
    /// مدل سرویس حذف و یا بلاک کردن مشتری از لیست مشتریان فروشگاه
    /// </summary>
    public class deleteCustomerFromStoreModel
    {
        /// <summary>
        /// شناسه کاربر
        /// </summary>
        public long userId { get; set; }
        /// <summary>
        /// وضعیت ها
        /// 1. حذف مشتری از لیست مشتریان
        /// 2. بلاک کردن مشتری
        /// </summary>
        public short state { get; set; }
    }
    /// <summary>
    /// مدل سرویس دریافت اطلاعات کاربر بر اساس شماره تلفن 
    /// </summary>
    public class getCustomerByPhoneModel
    {
        /// <summary>
        /// شماره تماس مشتری
        /// </summary>
        public string phone { get; set; }
    }
    /// <summary>
    /// سرویس دریافت مشخصات مشتری بر اساس شناسه یکتا
    /// </summary>
    public class getCustomerByUniqIdModel
    {
        /// <summary>
        /// شناسه یکتای کاربر
        /// </summary>
        public string id_str { get; set; }
    }
    
}
