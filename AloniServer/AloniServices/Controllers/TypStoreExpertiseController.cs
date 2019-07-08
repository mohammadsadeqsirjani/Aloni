using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// ای پی آی های مرتبط با لیست تخصص ها یا حوزه های فعالیت فروشگاه
    /// </summary>
    [RoutePrefix("TypStoreExpertise")]
    public class TypStoreExpertiseController : AdvancedApiController
    {
        /// <summary>
        /// ای پی آی دریافت لیست تخصص ها یا حوزه های فعالیت فروشگاه
        /// </summary>
        /// <returns>لیست تخصص ها یا حوزه های فعالیت</returns>
        [Route("getList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getList(searchParameterModel model)
        {
            //if (!ModelState.IsValid)
            //    return new BadRequestActionResult(ModelState.Values);

            var retIst = new List<typStoreExpertiseModel>();
            using (var repo = new Repo(this, "SP_typStoreExpertiseGetList", "TypStoreExpertiseController",initAsReader: true,checkAccess:false))
            {
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.ExecuteReader();

                while (repo.sdr.Read())
                {
                    retIst.Add(new typStoreExpertiseModel()
                    {
                        id = Convert.ToInt16(repo.sdr["id"]),
                        title = Convert.ToString(repo.sdr["title"])
                    });
                }
                return Ok(retIst);
            }
        }
    }
    /// <summary>
    /// مدل تخصص ها یا حوزه های فعالیت
    /// </summary>
    public class typStoreExpertiseModel
    {
        /// <summary>
        /// شناسه حوزه فعالیت
        /// </summary>
        public int id { get; set; }
        /// <summary>
        /// عنوان حوزه فعالیت
        /// </summary>
        public string title { get; set; }
    }
}
