using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// ای پی آی های مرتبط با دسته بندی فروشگاه
    /// دسته بندی فروشگاه به مواردی مانند سوپر مارکت، بوتیک ،پت مارکت، دراگ استور و ... گفته میشه.
    /// </summary>
    [RoutePrefix("TypStoreCategory")]
    public class TypStoreCategoryController : AdvancedApiController
    {
        /// <summary>
        /// دریافت لیست
        /// </summary>
        /// <returns></returns>
        [Route("getList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getList(searchParameterModel model)
        {
            //if (!ModelState.IsValid)
            //    return new BadRequestActionResult(ModelState.Values);

            var retIst = new List<typStoreCategoryModel>();
            using (var repo = new Repo(this, "SP_typStoreCategoryGetList", "TypStoreCategoryController_getList", initAsReader: true, checkAccess: false))
            {
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.ExecuteReader();

                while (repo.sdr.Read())
                {
                    retIst.Add(new typStoreCategoryModel()
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
    /// مدل خروجی دسته بندی فروشگاه
    /// </summary>
    public class typStoreCategoryModel
    {
        /// <summary>
        /// شناسه دسته
        /// </summary>
        public int id { get; set; }
        /// <summary>
        /// عنوان دسته
        /// </summary>
        public string title { get; set; }
    }
}
