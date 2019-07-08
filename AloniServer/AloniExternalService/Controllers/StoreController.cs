using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniExternalService.Controllers
{
    [RoutePrefix("Store")]
    public class StoreController : AdvancedApiController
    {
      
       /// <summary>
       /// سرویس دریافت لیست فروشگاها (پنل
       /// </summary>
       /// <returns></returns>
        [Route("getStoreList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStoreList()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getStoreList", "StoreController_getStoreList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (repo.accessDenied)
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
