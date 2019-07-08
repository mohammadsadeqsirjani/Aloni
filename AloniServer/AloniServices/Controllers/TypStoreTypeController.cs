using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// ای پی آی های مرتبط با لیست انواع فروشگاه (public,public-limited,order,VIP,private) 
    /// </summary>
    [RoutePrefix("TypStoreType")]
    public class TypStoreTypeController : AdvancedApiController
    {
        /// <summary>
        /// ای پی آی دریافت لیست انواع فروشگاه
        /// </summary>
        /// <returns>لیست انواع فروشگاه</returns>
        [Route("getList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getList(searchParameterModel model)
        {
            //if (!ModelState.IsValid)
            //    return new BadRequestActionResult(ModelState.Values);

            var retIst = new List<typStoreTypeModel>();
            using (var repo = new Repo(this, "SP_typStoreTypeGetList", "TypStoreType_GetList", initAsReader: true, checkAccess: false))
            {
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.ExecuteReader();

                while (repo.sdr.Read())
                {
                    retIst.Add(new typStoreTypeModel()
                    {
                        id = Convert.ToInt32(repo.sdr["id"]),
                        title = Convert.ToString(repo.sdr["title"])
                    });
                }
                return Ok(retIst);
            }
        }
    }
    public class typStoreTypeModel
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
