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
    /// سرویس های مرتبط با شرایط و قوانین استفاده از برنامه
    /// </summary>
    [RoutePrefix("termsAndConditions")]
    public class TermsAndConditionsController : AdvancedApiController
    {
        /// <summary>
        /// پذیرش شرایط و قوانین
        /// چنانچه قوانین و مقررات مربوط به اپ فروشنده می باشد ورود شناسه فروشگاه الزامی می باشد در هدر
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("accept")]
        [Exception]
        [HttpPost]
        public IHttpActionResult accept(TermsAndConditionsAcceptBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_termsAndConditions_accept", "termsAndConditions_accept", autenticationMode.authenticateAsUser, checkAccess: false))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");

                //if (repo.accessDenied)
                //    return new ForbiddenActionResult();

                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                repo.cmd.Parameters.AddWithValue("@version", model.version.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                //var par_sessionId = repo.cmd.Parameters.Add("@sessionId", SqlDbType.BigInt);
                //par_sessionId.Direction = ParameterDirection.Output;

                repo.ExecuteNonQuery();

                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = "success"});
            }
        }
        /// <summary>
        /// دریافت آخرین نسخه از شرایط و قوانین
        /// </summary>
        /// <returns></returns>
        [Route("getLastVersion")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getLastVersion()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_termsAndConditions_getLastVersion", "termsAndConditions_getLastVersion", autenticationMode.NoAuthenticationRequired, checkAccess: false))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");

                //if (repo.accessDenied)
                //    return new ForbiddenActionResult();

                var par_version = repo.cmd.Parameters.Add("@version", SqlDbType.Money);
                par_version.Direction = ParameterDirection.Output;

                //SqlParameter par_version = new SqlParameter("@version", SqlDbType.Money);
                ////par_versionCode.SourceColumn = "myValue";
                //par_version.Precision = 10;
                //par_version.Scale = 3;
                //par_version.Direction = ParameterDirection.Output;
                //repo.cmd.Parameters.Add(par_version);


                var par_title = repo.cmd.Parameters.Add("@title", SqlDbType.VarChar,50);
                par_title.Direction = ParameterDirection.Output;

                var par_description = repo.cmd.Parameters.Add("@description", SqlDbType.VarChar,-1);
                par_description.Direction = ParameterDirection.Output;

                var par_saveDateTime_dsc = repo.cmd.Parameters.Add("@saveDateTime_dsc", SqlDbType.VarChar,20);
                par_saveDateTime_dsc.Direction = ParameterDirection.Output;

                repo.ExecuteNonQuery();

                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new
                {
                    version = par_version.Value.dbNullCheckDecimal(),
                    title = par_title.Value.dbNullCheckString(),
                    description = par_description.Value.dbNullCheckString(),
                    saveDateTime_dsc = par_saveDateTime_dsc.Value.dbNullCheckString()
                });
            }
        }

      
    }
    #region models
    /// <summary>
    /// مدل پذیرش ش و ق
    /// </summary>
    public class TermsAndConditionsAcceptBindingModel
    {
        /// <summary>
        /// کد نگارش شرایط و قوانین
        /// </summary>
        [Display(Name = "کد نگارش شرایط و قوانین")]
        [Required(ErrorMessage = "{0} is required")]
        public decimal? version { get; set; }
    }

    #endregion


}
