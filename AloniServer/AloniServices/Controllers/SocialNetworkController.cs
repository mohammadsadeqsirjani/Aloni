using System;
using System.Data;
using System.Linq;
using System.Net.Mail;
using System.Web.Http;

namespace AloniServices.Controllers
{
    [RoutePrefix("SocialNetwork")]
    public class SocialNetworkController : AdvancedApiController
    {
        /// <summary>
        /// دریافت لیست شبکه های اجتماعی فروشگاه
        /// </summary>
        /// <returns></returns>
        [Route("getList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getList()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getSocialNetworkList", "SocialNetworkController_getList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteAdapter();
              
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i =>
                new
                {
                    id = Convert.ToInt64(i.Field<object>("id")),
                    socialNetworkType = Convert.ToString(i.Field<object>("socialNetworkType")),
                    socialNetworkAccount = Convert.ToString(i.Field<object>("socialNetworkAccount")),
                }
                ).ToList());
            }
        }
        /// <summary>
        /// سرویس افزودن و ویرایش
        /// </summary>
        /// <returns></returns>
        [Route("addUpdate")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addUpdate(SocialNetworkModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_socialNetworkAddUpdate", "SocialNetworkController_addUpdate"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@socialType", model.socialNetworkType.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@socialId", model.socialNetworkAccount.dbNullCheckString());
                var param = repo.cmd.Parameters.AddWithValue("@id", model.id.dbNullCheckLong());
                param.Direction = ParameterDirection.InputOutput;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg, id = param.Value });
            }
        }
       
        /// <summary>
        /// سرویس حذف 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("delete")]
        [Exception]
        [HttpPost]
        public IHttpActionResult delete(SocialNetworkModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_DeleteSocialNetworkAccount", "SocialNetworkController_delete"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@id", model.id);
               
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }

        /// <summary>
        /// دریافت  شبکه های اجتماعی فروشگاه
        /// ورژن 2
        /// </summary>
        /// <returns></returns>
        [Route("getStoreSocialNetwork")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStoreSocialNetwork()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getStoreSocialNetwork", "SocialNetworkController_getStoreSocialNetwork", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteAdapter();
                
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i =>
                new StoreSocialNetworkModelBindingModel
                {
                    instagramAccount =Convert.ToString(i.Field<object>("instagramAccount")),
                    telegramAccount = Convert.ToString(i.Field<object>("telegramAccount")),
                    twitterAccount = Convert.ToString(i.Field<object>("twitterAccount")),
                    emailAccount = Convert.ToString(i.Field<object>("emailAccount"))
                }
                ).FirstOrDefault());
            }
        }
        /// <summary>
        /// سرویس ویرایش
        /// ورژن 2 AddUpdate
        /// </summary>
        /// <returns></returns>
        [Route("update")]
        [Exception]
        [HttpPost]
        public IHttpActionResult update(StoreSocialNetworkModelBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_socialNetworkUpdate", "SocialNetworkController_update"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                if (!string.IsNullOrWhiteSpace(model.emailAccount))
                {
                    try
                    {
                        MailAddress m = new MailAddress(model.emailAccount);
                    }
                    catch (FormatException)
                    {
                        return new NotFoundActionResult("ایمل وارد شده معتبر نمی باشد");
                    }
                }
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@instagramAccount", model.instagramAccount.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@telegramAccount", model.telegramAccount.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@twitterAccount", model.twitterAccount.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@emailAccount", model.emailAccount.dbNullCheckString());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg});
            }
        }
    }

    public class SocialNetworkModel
    {
        public long id { get; set; }
        /// <summary>
        /// telegram
        /// twitter
        /// instagram
        /// </summary>
        public string socialNetworkType { get; set; }
        public string socialNetworkAccount { get; set; }

    }
    public class StoreSocialNetworkModelBindingModel
    {
        public string instagramAccount { get; set; }
        public string telegramAccount { get; set; }
        public string twitterAccount { get; set; }
        public string emailAccount { get; set; }
    }
}
