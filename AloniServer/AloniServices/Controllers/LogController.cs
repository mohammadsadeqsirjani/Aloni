using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniServices.Controllers
{
    [RoutePrefix("log")]
    public class LogController : AdvancedApiController
    {
        [Exception]
        [HttpPost]
        [Route("crashReport")]
        public IHttpActionResult crashReport(crashReportModelBinding model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_reportCrashBug", "LogController_crashReport",autenticationMode.authenticateAsUser))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
               
                repo.cmd.Parameters.AddWithValue("@errorCode", model.errorCode.dbNullCheckInt());
                repo.cmd.Parameters.AddWithValue("@source", model.source.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@message", model.message.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@app", model.app.dbNullCheckShort());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = "ok" });
            }
        }
    }
    public class crashReportModelBinding
    {
        /// <summary>
        /// شناسه خطای اکسپشن دات نت 
        /// </summary>
        public int errorCode { get; set; }
        /// <summary>
        /// منشاء بروز خطا
        /// </summary>
        public string source { get; set; }
        public string message { get; set; }
        /// <summary>
        /// شناسه پلتفرم
        /// 1. ویندوز
        /// 2. آندروید
        /// 3. آی او اس
        /// 4. پورتال
        /// </summary>
        public short app { get; set; }

    }
}
