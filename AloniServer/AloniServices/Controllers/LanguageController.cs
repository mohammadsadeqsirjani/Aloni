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
    /// 
    [RoutePrefix("Language")]
    
    public class LanguageController : AdvancedApiController
    {
        /// <summary>
        /// سرويس دريافت ليست زبان ها
        /// </summary>
        /// <returns></returns>
        [Route("get")]
        [Exception]
        [HttpPost]
        public IHttpActionResult get()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getLanguage", "LanguageController_get", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.ExecuteAdapter();
                var result = repo.ds.Tables[0];
                return Ok(result.AsEnumerable().Select(row => new
                {
                    id = Convert.ToString(row.Field<object>("id")),
                    title = Convert.ToString(row.Field<object>("title")),
                    isRtl = Convert.ToBoolean(row.Field<object>("isRTL"))
                }).ToList());
            }
        }
    }
}
