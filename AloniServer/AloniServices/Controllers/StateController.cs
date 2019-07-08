using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// ای پی آی های مرتبط با موجودیت استان
    /// </summary>
    [RoutePrefix("State")]
    public class StateController : AdvancedApiController
    {
        /// <summary>
        /// دریافت لیست استان ها
        /// </summary>
        /// <returns></returns>
        [Route("getList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getList(searchParameterModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);

            var retIst = new List<stateModel>();
            using (var repo = new Repo(this, "SP_stateGetList" , "StateController_getList", autenticationMode.NoAuthenticationRequired, true,false))
            {
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.ExecuteReader();

                while (repo.sdr.Read())
                {
                    retIst.Add(new stateModel()
                    {
                        id = Convert.ToInt16(repo.sdr["id"]),
                        title = Convert.ToString(repo.sdr["title"]),
                       // callingCode = Convert.ToString(repo.sdr["callingCode"])
                    });
                }

                return Ok(retIst);
            }
        }
    }
    /// <summary>
    /// مدل استان
    /// </summary>
    public class stateModel
    {
        /// <summary>
        /// شناسه استان
        /// </summary>
        public int id { get; set; }
        /// <summary>
        /// عنوان استان
        /// </summary>
        public string title { get; set; }
    }
}
