using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// سرویس های مرتبط با حساب کاربری کاربران
    /// </summary>
    [RoutePrefix("userAccount")]
    public class UserAccountController : AdvancedApiController
    {
        /// <summary>
        /// ای پی آی  ثبت نام کاربر
        /// هدینگ ها : public headings :
        /// AcceptLanguage : fa,en,ar,tr,...
        /// authorization : security token
        /// appId : 1 = marketer , 2 = customer , 3 = portal
        /// 
        /// با اجرای این سرویس 
        /// sessionId
        /// در خروجی ارسال می شود. در سرویس های بعدی این پارامتر باید در هدر ست شود.
        /// 
        /// </summary>
        /// <param name="model">the input model of registration</param>
        /// <returns>http action results with status code and message</returns>
        //[Route("cstmr/register")]
        //[Route("mrktr/register")]
        [Route("register")]
        [Exception]
        [HttpPost]
        public IHttpActionResult register(registerBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            mobile = model.mobile;
            otpCode = "";
            using (var repo = new Repo(this, "SP_registerUser", "UserAccountController_register", autenticationMode.authenticateAsAnonymous, checkAccess: false))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                

                repo.cmd.Parameters.AddWithValue("@mobile", model.mobile.getDbValue());
                repo.cmd.Parameters.AddWithValue("@countryId", model.countryId);
                repo.cmd.Parameters.AddWithValue("@introducerUserCode", model.introducerUserCode.getDbValue());
                repo.cmd.Parameters.AddWithValue("@fname", model.fName.getDbValue());
                repo.cmd.Parameters.AddWithValue("@email", model.email.getDbValue());
                repo.cmd.Parameters.AddWithValue("@lname", model.lName.getDbValue());
                var par_sessionId = repo.cmd.Parameters.Add("@sessionId", SqlDbType.BigInt);
                par_sessionId.Direction = ParameterDirection.Output;

                repo.ExecuteNonQuery();

                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(par_sessionId.Value);
            }
        }
        /// <summary>
        /// ای پی آی مربوط به ثبت درخواست لاگین
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
            using (var repo = new Repo(this, "SP_setLogin", "UserAccountController_setLogin", autenticationMode.authenticateAsAnonymous, checkAccess: false))
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
        /// ای پی آی مربوط به لاگین
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

            using (var repo = new Repo(this, "SP_login", "UserAccountController_login", autenticationMode.authenticateAsAnonymous, checkAccess: false))
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
        /// سرویس خروج از حساب کاربری (می تواند به منطور غیرفعال سازی جلسات فعال بر روی دستگاه های دیگر نیز استفاده شود)
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
        /// <summary>
        /// سرویس بروز رسانی موقعیت کاربر
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("updateLocation")]
        [Exception]
        [HttpPost]
        public IHttpActionResult UpdateLocation(locationModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updateUserLocation", "userAccountController_updateLocation"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@lat", model.lat);
                repo.cmd.Parameters.AddWithValue("@lng", model.lng);
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(repo.rMsg);

            }
        }
        /// <summary>
        /// سرویس دریافت اطلاعات پروفایل کاربر
        /// </summary>
        /// <returns></returns>
        [Route("getUserProfileInfo")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getUserProfileInfo()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getUserProfileInfo", "userAccountController_getUserProfileInfo", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                repo.ExecuteAdapter();
                var result = repo.ds.Tables[0];
                return Ok(
                        result.AsEnumerable().Select(
                            row => new
                            {
                                name = Convert.ToString(row.Field<object>("NAME")),
                                mobile = Convert.ToString(row.Field<string>("mobile")),
                                countryId = Convert.ToInt32(row.Field<object>("COUNTRYID") is DBNull ? 0 : row.Field<object>("COUNTRYID")),
                                countryName = Convert.ToString(row.Field<object>("COUNTRYNAME")),
                                cityId = Convert.ToInt32(row.Field<object>("CITYID") is DBNull ? 0 : row.Field<object>("CITYID")),
                                cityName = Convert.ToString(row.Field<object>("CITYNAME")),
                                provinceId = Convert.ToInt32(row.Field<object>("PROVINCEID") is DBNull ? 0 : row.Field<object>("PROVINCEID")),
                                provinceName = Convert.ToString(row.Field<object>("PROVINCENAME"))
                            }
                        ).ToList()
                        );
            }
        }

        /// <summary>
        /// دریافت مانده اعتبار کیف پول الکترونیکی
        /// </summary>
        /// <returns></returns>
        [Route("userCreditGet")]
        [Exception]
        [HttpPost]
        public IHttpActionResult setCreditIncReq()
        {
            //if (!ModelState.IsValid)
            //    return new BadRequestActionResult(ModelState.Values);


            using (var repo = new Repo(this, "SP_userCreditGet", "UserAccountController_userCreditGet", autenticationMode.authenticateAsUser, checkAccess: false))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //repo.cmd.Parameters.AddWithValue("@amount", model.amount.getDbValue());

                var par_creditDsc = repo.cmd.Parameters.Add("@creditDsc", SqlDbType.VarChar, 100);
                par_creditDsc.Direction = ParameterDirection.Output;

                var par_currencyTitle = repo.cmd.Parameters.Add("@currencyTitle", SqlDbType.VarChar, 50);
                par_currencyTitle.Direction = ParameterDirection.Output;

                var par_credit = repo.cmd.Parameters.Add("@credit", SqlDbType.Money);
                par_credit.Direction = ParameterDirection.Output;

                repo.ExecuteNonQuery();

                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { credit = par_credit.Value.dbNullCheckDecimal(), creditDsc = par_creditDsc.Value.dbNullCheckString(), currencyTitle = par_currencyTitle.Value.dbNullCheckString() });
            }
        }

        /// <summary>
        /// درخواست افزایش اعتبار کیف الکترونیکی
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("userCreditSetIncReq")]
        [Exception]
        [HttpPost]
        public IHttpActionResult setCreditIncReq(setCreditIncReqBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);


            using (var repo = new Repo(this, "SP_userCreditSetIncReq", "UserAccountController_userCreditSetIncReq", autenticationMode.authenticateAsUser, checkAccess: false))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                repo.cmd.Parameters.AddWithValue("@amount", model.amount.getDbValue());
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                var par_paymentUrl = repo.cmd.Parameters.Add("@paymentUrl", SqlDbType.VarChar, 255);
                par_paymentUrl.Direction = ParameterDirection.Output;
                par_paymentUrl.Value = sessionId;

                repo.ExecuteNonQuery();

                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { paymentUrl = par_paymentUrl.Value.dbNullCheckString() });
            }
        }
        ///// <summary>
        ///// سرویس تنظیمات اولیه سیستم
        ///// </summary>
        ///// <returns></returns>
        //[Route("initApp")]
        //[Exception]
        //[HttpPost]
        //public IHttpActionResult initApp()
        //{
        //    if (!ModelState.IsValid)
        //        return new BadRequestActionResult(ModelState.Values);


        //    using (var repo = new Repo(this, "SP_initApp", "UserAccountController_initApp",initAsReader:true))
        //    {
        //        if (repo.unauthorized)
        //            return new UnauthorizedActionResult("Unauthorized!");
        //        repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
        //        repo.ExecuteAdapter();
        //        var version = repo.ds.Tables[0];
        //        return Ok(new
        //        {
        //            version = version.AsEnumerable().Select(i => new
        //            {
        //                newVersionStatus = Convert.ToInt16(i.Field<object>("newVersionStatus")),
        //                versionCode = Convert.ToDecimal(i.Field<object>("versionCode")),
        //                releasNote = Convert.ToString(i.Field<object>("releasNote"))
        //            })
        //        }

        //            );
             
        //    }
        //}




        /// <summary>
        /// Depricated! please use the latest Version of this service.
        /// بروزرسانی توکن سرور پوش نوتیفیکیشن
        /// </summary>
        /// <param name="token">توکن</param>
        /// <returns></returns>
        [Route("updatePushNotiClientToken")]
        [Exception]
        [HttpPost]
        [Obsolete(message: "Depricated! please use the latest Version of this service")]
        public IHttpActionResult updatePushNotiId([FromBody] string token)
        {
            //if (!ModelState.IsValid)
            //    return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_usrSession_updatePushNotiClientToken", "usrSession_updatePushNotiClientToken"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if(repo.accessDenied)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@pushNotiId", token);
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId.getDbValue());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// بروزرسانی توکن سرور پوش نوتیفیکیشن
        /// </summary>
        /// <param name="input"></param>
        /// <returns></returns>
        [Route("updatePushNotiClientToken/v2")]
        [Exception]
        [HttpPost]
        public IHttpActionResult updatePushNotiId_v2(updatePushNotiIdBindingModel input )
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_usrSession_updatePushNotiClientToken", "usrSession_updatePushNotiClientToken"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if(repo.accessDenied)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@pushNotiId", input.token);
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@provider", input.provider);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }

    }

    #region models
    /// <summary>
    /// مدل ورودی به منظور خرید اعتبار در اپ خریدار
    /// </summary>
    public class setCreditIncReqBindingModel
    {
        /// <summary>
        /// مبلغ درخواستی
        /// </summary>
        public decimal amount { get; set; }


    }
    /// <summary>
    /// مدل ورودی سرویس بروز رسانی توکن اعلان کاربر
    /// </summary>
    public class updatePushNotiIdBindingModel
    {
        /// <summary>
        /// توکن اعلان کاربر
        /// </summary>
        [Display(Name = "توکن اعلان کاربر")]
        [Required(ErrorMessage ="ورود {0} الزامی است.")]
        public string token { get; set; }
        /// <summary>
        /// تامین کننده
        /// push noti provider - 1 : GCM , 2 : FCM , 3 : ONESIGNAL
        [Display(Name = "نوع تامین کننده")]
        [Required(ErrorMessage = "ورود {0} الزامی است.")]
        public byte provider { get; set; }
    }

    /// <summary>
    /// مدل اطلاعاتی ثبت نام کاربر
    /// </summary>
    public class registerBindingModel
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
        /// شناسه کشور انتخابی کاریر
        /// </summary>
        [Required]
        public int countryId { get; set; }
        /// <summary>
        /// نام
        /// </summary>
        [Required]
        public string fName { get; set; }
        /// <summary>
        /// آدرس ایمیل (اختیاری)
        /// </summary>
        public string email { get; set; }

        /// <summary>
        /// نام خانوادگی
        /// </summary>
        public string lName { get; set; }
        /// <summary>
        /// شناسه معرف
        /// می تواند شماره موبایل با فرمت
        /// +989150000000
        /// باشد و یا شناسه معرف کارکتری که در پروفایل موجود است
        /// </summary>
        public string introducerUserCode { get; set; }


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
        /// 1 : android , 2 : IOS , 3 : portal
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

    #endregion


}
