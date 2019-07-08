using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Data;
namespace AloniServices.Controllers
{
    /// <summary>
    /// ای پی آی مربوط به عملیات دعوت کاربر
    /// </summary>
    [RoutePrefix("Invite")]
    public class InviteController : AdvancedApiController
    {
        /// <summary>
        ///سرویس دعوت کاربر به فروشگاه
        ///شناسه فروشگاه در هدر ست شود
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("inviteUserToStore")]
        [Exception]
        [HttpPost]
        public IHttpActionResult inviteUserToStore(inviteUserToStoreModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_inviteUserToStore", "InviteController_inviteUserToStore"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@mobile", model.mobile);
                repo.cmd.Parameters.AddWithValue("@staffId", model.staffId);
                repo.cmd.Parameters.AddWithValue("@description", model.recommanderDesc.dbNullCheckString());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس دریافت لیست دعوتنامه های فروشگاه ها
        /// </summary>
        /// <returns></returns>
        [Route("getInvitationList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getInvitationList()
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getInvitationList", "InviteController_getInvitationList",initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(
                    row=> new
                    {
                        inviteId = Convert.ToInt64(row.Field<object>("id")),
                        recommanderMobile = Convert.ToString(row.Field<object>("mobile")),
                        recommanderName = Convert.ToString(row.Field<object>("name")),
                        recommanderStaffInfo = Convert.ToString(row.Field<object>("storeInfo")),
                        recommanderStaff = Convert.ToString(row.Field<object>("semat_pishnahadi")),
                        recommanderDesc = Convert.ToString(row.Field<object>("recommanderDesc"))
                    }
                    ).ToList());
            }
        }
        /// <summary>
        /// سرویس پاسخ به درخواست دعوت
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("responseToInvite")]
        [Exception]
        [HttpPost]
        public IHttpActionResult responseToInvite(responseToInviteModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_responseToInvite", "InviteController_responseToInvite"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@inviteId", model.inviteId);
                repo.cmd.Parameters.AddWithValue("@accept", model.accept);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg});
            }
        }
        /// <summary>
        /// سرویس کنسل کردن دعوت یا اخراج کارمند
        /// </summary>
        /// <param name="model">
        /// id : شناسه دعوت
        /// </param>
        /// <returns></returns>
        [Route("deleteInvite")]
        [Exception]
        [HttpPost]
        public IHttpActionResult deleteInvite(deleteInviteModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_deleteInvite", "InviteController_deleteInvite"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@inviteId", model.inviteId);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }

    }
    /// <summary>
    /// مدل پایه دعوت کاربر
    /// </summary>
    public class inviteUserToStoreModel
    {
        /// <summary>
        /// تلفن همراه
        /// </summary>
        public string mobile { get; set; }
        /// <summary>
        /// شناسه سمت پیشنهادی
        /// </summary>
        public short staffId { get; set; }
        /// <summary>
        /// توضیحات
        /// </summary>
        public string recommanderDesc { get; set; }
    }
    /// <summary>
    /// مدل پایه پاسخ به دعوت کاربر
    /// </summary>
    public class responseToInviteModel
    {
        /// <summary>
        /// شناسه دعوت
        /// </summary>
        public long inviteId { get; set; }
        /// <summary>
        /// فلگ می پذیرم/نمی پذیرم
        /// </summary>
        public bool accept { get; set; }
    }
    /// <summary>
    /// مدل حذف دعوت
    /// </summary>
    public class deleteInviteModel
    {
        /// <summary>
        /// شناسه دعوت
        /// </summary>
        public long inviteId { get; set; }
    }

}
