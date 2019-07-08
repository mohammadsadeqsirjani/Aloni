using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// ای پی آی مربوط به واحد شمارش کالا
    /// </summary>
    [RoutePrefix("UnitItem")]
    public class UnitItemController : AdvancedApiController
    {
        /// <summary>
        /// سرویس دریافت لیست واحد های  فعال شمارش کالا
        /// </summary>
        /// <returns></returns>
        [Route("getActiveUnitList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult GetActiveUnitList(searchParameterModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<UnitModel> result = new List<UnitModel>();

            using (var repo = new Repo(this, "SP_getActiveUnit", "UnitItemController_GetActiveUnitList",autenticationMode.NoAuthenticationRequired,initAsReader:true))
            {
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.ExecuteReader();

                while (repo.sdr.Read())
                {
                    UnitModel item = new UnitModel();
                    item.id = Convert.ToInt32(repo.sdr["id"]);
                    item.title = Convert.ToString(repo.sdr["title"]);
                    result.Add(item);
                }
            }
            return Ok(result);
        }
        public class UnitModel
        {
            public int id { get; set; }
            public string title { get; set; }
        }
    }
}
