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
    /// ای پی آی های مرتبط با موجودیت نوع گزارش فروشگاه
    /// </summary>
    [RoutePrefix("typeStoreReportType")]
    public class typeStoreReportTypeController : AdvancedApiController
    {
        /// <summary>
        /// ای پی آی دریافت لیست انواع گزارش فروشگاه
        /// </summary>
        /// <returns>لیست انواع گزارش فروشگاه</returns>
        [Route("getList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getList(searchParameterModel model)
        {
            //if (!ModelState.IsValid)
            //    return new BadRequestActionResult(ModelState.Values);

            //var retIst = new List<typStoreTypeModel>();
            using (var repo = new Repo(this, "SP_typeStoreReportTypeGetList", "typeStoreReportType_GetList", initAsReader: true, checkAccess: false, AuthMode: autenticationMode.NoAuthenticationRequired))
            {
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(b => new
                {
                    id = b.Field<object>("id"),
                    title = b.Field<object>("title"),
                    usageInfo = b.Field<object>("usageInfo")
                }));
                //repo.ExecuteReader();
                //while (repo.sdr.Read())
                //{
                //    retIst.Add(new typStoreTypeModel()
                //    {
                //        id = Convert.ToInt32(repo.sdr["id"]),
                //        title = Convert.ToString(repo.sdr["title"])
                //    });
                //}
                //return Ok(retIst);
            }
        }
    }
}
