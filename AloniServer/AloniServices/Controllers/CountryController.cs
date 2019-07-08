using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// ای پی آی های مرتبط با موجودیت کشور
    /// </summary>
    [RoutePrefix("Country")]
    public class CountryController : AdvancedApiController
    {
        /// <summary>
        /// دریافت لیست کشور ها به همراه پیش کد
        /// </summary>
        /// <returns></returns>
        [Route("getList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getList(searchParameterModel model)
        {
            if (!ModelState.IsValid)
            {
                return new BadRequestActionResult(ModelState.Values);
            }

            var retLst = new List<countryModel>();
            using (var repo = new Repo(this, "SP_countryGetList", "CountryController_getList", autenticationMode.NoAuthenticationRequired, true))
            {
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.ExecuteReader();

                while (repo.sdr.Read())
                {
                    retLst.Add(new countryModel()
                    {
                        id = Convert.ToInt16(repo.sdr["id"]),
                        title = Convert.ToString(repo.sdr["title"]),
                        callingCode = Convert.ToString(repo.sdr["callingCode"])
                    });
                }

                return Ok(retLst);
            }
        }
        /// <summary>
        /// مدل خروجی کشور
        /// </summary>
        public class countryModel
        {
            /// <summary>
            /// شناسه کشور
            /// </summary>
            public int id { get; set; }
            /// <summary>
            /// عنوان کشور
            /// </summary>
            public string title { get; set; }
            /// <summary>
            /// پیش کد
            /// </summary>
            public string callingCode { get; set; }
        }
    }
}