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
    /// آی پی آی مربوط به مقاطع تحصیلی
    /// </summary>
    [RoutePrefix("education")]
    public class EducationController : AdvancedApiController
    {
        /// <summary>
        /// دریافت لیست مقاطع تحصیلی
        /// </summary>
        /// <returns></returns>
        [Route("getList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getList()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<TechnicalInfoItemTyp> result = new List<TechnicalInfoItemTyp>();
            using (var repo = new Repo(this, "SP_getEducationList", "educationcontroller_SP_getEducationList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i => new
                {
                    id = Convert.ToInt32(i.Field<object>("id")),
                    title = Convert.ToString(i.Field<object>("title"))
                }).ToList());

            }
         
        }
    }
}
