using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// ای پی آی های مربوط به موجودیت شهر
    /// </summary>
    [RoutePrefix("City")]
    public class CityController : AdvancedApiController
    {
        /// <summary>
        /// ای پی آی دریافت لیست شهرها
        /// </summary>
        /// <returns></returns>
        [Route("getList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getList(searchParameterModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);

            var retLst = new List<cityModel>();
            using (var repo = new Repo(this, "SP_cityGetList", "CityController_getList", autenticationMode.NoAuthenticationRequired, true,false))
            {
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.ExecuteReader();

                while (repo.sdr.Read())
                {
                    retLst.Add(new cityModel()
                    {
                        id = Convert.ToInt32(repo.sdr["id"]),
                        title = Convert.ToString(repo.sdr["title"]),
                    });
                }

                return Ok(retLst);
            }
        }
        /// <summary>
        /// سرویس دریافت لیست شهرها به همراه انتخاب همه شهرها
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getList_V2")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getList_V2(searchParameterModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);

            var retIst = new List<cityModel>();
            using (var repo = new Repo(this, "SP_cityGetList", "CityController_getList", autenticationMode.NoAuthenticationRequired, true, false))
            {
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@withAllItem", true);
                repo.ExecuteReader();

                while (repo.sdr.Read())
                {
                    retIst.Add(new cityModel()
                    {
                        id = Convert.ToInt32(repo.sdr["id"]),
                        title = Convert.ToString(repo.sdr["title"]),
                    });
                }

                return Ok(retIst);
            }
        }
    }
    /// <summary>
    /// مدل شهر
    /// </summary>
    public class cityModel
    {
        /// <summary>
        /// شناسه شهر
        /// </summary>
        public int id { get; set; }
        /// <summary>
        /// عنوان شهر
        /// </summary>
        public string title { get; set; }
    }
}
