using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// ای پی آی مربوط به مجوزهای دسترسی کاربر
    /// </summary>
    [RoutePrefix("UserAccess")]
    public class UserAccessController : AdvancedApiController
    {
        /// <summary>
        /// سرویس دریافت مجوزهای فروشگاه بر اساس سمت کاربر
        /// </summary>
        /// <param name="storeID">کد فروشگاه</param>
        /// <returns></returns>
        [Route("getList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getList(LongKeyModel storeID)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<UserAccessStoreBinding> result = new List<UserAccessStoreBinding>();
            using (var repo = new Repo(this, "SP_getUserAccessByStoreId", "UserAccessController_getList"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (repo.accessDenied)
                    return new ForbiddenActionResult();

                repo.cmd.Parameters.AddWithValue("@storeId", storeID.id);
                repo.ExecuteReader();

                while (repo.sdr.Read())
                {
                    UserAccessStoreBinding item = new UserAccessStoreBinding();
                    item.funcId = repo.sdr["fk_func_id"].ToString();
                    if (!object.ReferenceEquals(repo.sdr["fk_usr_id"], DBNull.Value))
                        item.userId = Convert.ToInt32(repo.sdr["fk_usr_id"]);
                    item.storeID = Convert.ToInt64(repo.sdr["fk_store_id"]);
                    item.staffId = Convert.ToInt32(repo.sdr["fk_staff_id"]);
                    item.hasAccess = Convert.ToBoolean(repo.sdr["hasAccess"]);
                    result.Add(item);
                }

            }
            return Ok(result);

        }
    
    }
    /// <summary>
    /// مدل مجوزهای فروشگاه بر اساس سمت کاربر 
    /// </summary>
    public class UserAccessStoreBinding
    {
        /// <summary>
        /// عنوان مجوز
        /// </summary>
        public string funcId { get; set; }
        /// <summary>
        /// کد کاربر
        /// </summary>
        public int userId { get; set; }
        /// <summary>
        /// کد سمت
        /// </summary>
        public int staffId { get; set; }
        /// <summary>
        /// کد فروشگاه
        /// </summary>
        public long storeID { get; set; }
        /// <summary>
        /// وضعیت دسترسی
        /// </summary>
        public bool hasAccess { get; set; }

    }
  

}
