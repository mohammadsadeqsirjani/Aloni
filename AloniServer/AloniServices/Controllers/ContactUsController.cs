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
    /// سرویس های ارتباط با ما
    /// </summary>
    [RoutePrefix("contactUs")]
    public class ContactUsController : AdvancedApiController
    {
        /// <summary>
        /// سرویس ثبت/ویرایش 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("add")]
        [Exception]
        [HttpPost]
        public IHttpActionResult add(contactUsModel model)
        {
            if (!ModelState.IsValid)
            {
                return new BadRequestActionResult(ModelState.Values);
            }

            using (var repo = new Repo(this, "SP_LP_addContactUs", "contactUs_add", autenticationMode.authenticateAsAnonymous, checkAccess: false))
            {
                repo.cmd.Parameters.AddWithValue("@subject", model.subject);
                repo.cmd.Parameters.AddWithValue("@mobile", model.mobile);
                repo.cmd.Parameters.AddWithValue("@email", model.email);
                repo.cmd.Parameters.AddWithValue("@message", model.message);
                repo.cmd.Parameters.AddWithValue("@saveIp", model.saveIp);
                repo.cmd.Parameters.AddWithValue("@fk_deprtmentTypeId", model.fk_deprtmentTypeId);

                var par_trackingCode = repo.cmd.Parameters.Add("@trackingCode", SqlDbType.VarChar,6);
                par_trackingCode.Direction = ParameterDirection.Output;

                
                repo.ExecuteNonQuery();

                if (repo.rCode != 1)
                {
                    return new NotFoundActionResult(repo.rMsg);
                }

                return Ok(new { trackingCode = par_trackingCode.Value.dbNullCheckString() });
            }
        }
    }
    /// <summary>
    /// مدل  پایه سرویس های ارتباط با ما
    /// </summary>
    public class contactUsModel
    {
        /// <summary>
        /// موضوع ارتباط
        /// </summary>
        public string subject { get; set; }
        /// <summary>
        /// شماره موبایل
        /// </summary>
        public string mobile { get; set; }
        /// <summary>
        /// آدرس پست الکترونیک
        /// </summary>
        public string email { get; set; }
        /// <summary>
        /// متن پیام
        /// </summary>
        public string message { get; set; }
        /// <summary>
        /// آدرس آی پی درخواست دهنده
        /// </summary>
        public string saveIp { get; set; }
        /// <summary>
        /// دپارتمان سازمانی
        /// </summary>
        public int fk_deprtmentTypeId { get; set; }
    }
}
