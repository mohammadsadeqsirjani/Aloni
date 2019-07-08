using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniExternalService.Controllers
{
    /// <summary>
    /// ای پی آی مربوط به هویت سنجی کاربران
    /// </summary>
    [RoutePrefix("Account")]
    public class AccountController : AdvancedApiController
    {
        /// <summary>
        ///  ثبت درخواست لاگین
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("setLogin")]
        [Exception]
        [HttpPost]
        public IHttpActionResult setLogin(setLoginBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            mobile = model.mobile;
            otpCode = "";
            using (var repo = new Repo(this, "SP_setLogin", "AccountController_setLogin", autenticationMode.authenticateAsAnonymous, checkAccess: false))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");

                repo.cmd.Parameters.AddWithValue("@mobile", model.mobile.getDbValue());
                var par_sessionId = repo.cmd.Parameters.Add("@sessionId", SqlDbType.BigInt);
                par_sessionId.Direction = ParameterDirection.Output;
                repo.ExecuteNonQuery();

                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg, sessionId = par_sessionId.Value });
            }
        }
        /// <summary>
        /// سرویس لاگین
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("login")]
        [Exception]
        [HttpPost]
        public IHttpActionResult login(loginBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);

            mobile = model.mobile;
            otpCode = model.otpCode;

            using (var repo = new Repo(this, "SP_login", "AccountController_login", autenticationMode.authenticateAsAnonymous, checkAccess: false))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                repo.cmd.Parameters.AddWithValue("@mobile", model.mobile.getDbValue());
                repo.cmd.Parameters.AddWithValue("@otpCode", model.otpCode.getDbValue());
                repo.cmd.Parameters.AddWithValue("@deviceInfo", model.deviceInfo.getDbValue());
                repo.cmd.Parameters.AddWithValue("@deviceId", model.deviceId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@deviceId_appDefined", model.deviceId_appDefined.getDbValue());
                repo.cmd.Parameters.AddWithValue("@osType", model.osType);
                //repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                var par_sessionId = repo.cmd.Parameters.Add("@sessionId", SqlDbType.BigInt);
                par_sessionId.Direction = ParameterDirection.InputOutput;
                par_sessionId.Value = sessionId;

                var par_authorization = repo.cmd.Parameters.Add("@authorization", SqlDbType.Char, 128);
                par_authorization.Direction = ParameterDirection.Output;

                repo.ExecuteNonQuery();

                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg, authorization = par_authorization.Value });
            }
        }

        /// <summary>
        /// سرویس خروج از حساب کاربری 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("logout")]
        [Exception]
        [HttpPost]
        public IHttpActionResult logout(logoutBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_logout", "UserAccountController_logout"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@targetSessionId", model.targetSessionId);
                repo.ExecuteNonQuery();

                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
    }
    /// <summary>
    /// مدل ورودی درخواست لاگین
    /// </summary>
    public class setLoginBindingModel
    {
        /// <summary>
        /// شماره موبایل کاربر
        /// اجباری
        /// فرمت:
        /// +989120000000
        /// </summary>
        [Required]
        public string mobile { get; set; }
    }

    /// <summary>
    /// مدل ورودی لاگین
    /// </summary>
    public class loginBindingModel
    {
        /// <summary>
        /// شماره موبایل کاربر
        /// اجباری
        /// فرمت:
        /// +989120000000
        /// </summary>
        [Required]
        public string mobile { get; set; }
        /// <summary>
        /// کد اعتبار سنجی 5 رقمی
        /// اجباری
        /// </summary>
        [Required]
        public string otpCode { get; set; }
        /// <summary>
        /// مشخصات دستگاه (برند،مدل،نسخه سیستم عامل)
        /// </summary>
        public string deviceInfo { get; set; }
        /// <summary>
        /// شناسه سخت افزار دستگاه
        /// </summary>
        public string deviceId { get; set; }
        /// <summary>
        /// شناسه دستگاه (تولید شده توسط اپ)
        /// </summary>
        public string deviceId_appDefined { get; set; }
        /// <summary>
        /// values:
        /// 1 : android , 2 : IOS , 3 : web 4 : windows
        /// </summary>
        public byte osType { get; set; }
    }
    /// <summary>
    /// مدل ورودی سرویس خروج از حساب کاربری
    /// </summary>
    public class logoutBindingModel
    {
        /// <summary>
        /// شناسه جلسه مورد نظر
        /// </summary>
        public long targetSessionId { get; set; }
    }
}
