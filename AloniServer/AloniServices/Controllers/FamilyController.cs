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
    /// ای پی آی مربوط به خانواده
    /// </summary>
    [RoutePrefix("Family")]
    public class FamilyController : AdvancedApiController
    {
        /// <summary>
        /// سرویس تعریف خانواده
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("define")]
        [Exception]
        [HttpPost]
        public IHttpActionResult define(defineModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this,"SP_defineFamily", "FamilyController_define"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                var param = repo.cmd.Parameters.Add("@id", SqlDbType.BigInt);
                param.Direction = ParameterDirection.Output;
                repo.cmd.Parameters.AddWithValue("@mobile", model.mobile.getDbValue());
                repo.cmd.Parameters.AddWithValue("@title", model.title.getDbValue());
                
                
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg, id = Convert.ToInt64(param.Value) });
            }
        }
        /// <summary>
        ///  سرویس دریافت لیست خانواده 
        /// </summary>
        /// <returns></returns>
        [Route("getList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getList()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getFamilyList", "FamilyController_getList",initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.ExecuteAdapter();
                //d.completeLink,u.fname + ISNULL(u.lname, '') name,uf.title,ISNULL(st.title, s.title) status_
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i =>
                new
                {
                    id = Convert.ToInt64(i.Field<object>("id")),
                    image = Convert.ToString(i.Field<object>("completeLink")),
                    thumbImage = Convert.ToString(i.Field<object>("thumbcompeleteLink")),
                    name = Convert.ToString(i.Field<object>("name")),
                    familyTitle = Convert.ToString(i.Field<object>("title")),
                    status = Convert.ToString(i.Field<object>("status_")),
                    statusId = Convert.ToInt32(i.Field<object>("stId")),
                    isMine = Convert.ToBoolean(i.Field<object>("isMine"))
                }
                ).ToList());
            }
        }
        /// <summary>
        /// سرویس دریافت لیست درخواست عضویت در خانواده
        /// </summary>
        /// <returns></returns>
        [Route("getReqList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getReqList()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getFamilyList", "FamilyController_getList",initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@seeRequested", true);
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i =>
                new
                {
                    id = Convert.ToInt32(i.Field<object>("id") is DBNull ? 0 : i.Field<object>("id")),
                    image = Convert.ToString(i.Field<object>("completeLink")),
                    name = Convert.ToString(i.Field<object>("name")),
                    familyTitle = Convert.ToString(i.Field<object>("title")),
                    status = Convert.ToString(i.Field<object>("status_"))
                }
                ).ToList());
            }
        }
        /// <summary>
        ///  سرویس پاسخ به درخواست عضویت در خانواده
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("responsToReq")]
        [Exception]
        [HttpPost]
        public IHttpActionResult responsToReq(responsToReqModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_responsToReqFamily", "FamilyController_responsToReq"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@id", model.id);
                repo.cmd.Parameters.AddWithValue("@accept", model.accept);
                repo.cmd.Parameters.AddWithValue("@reqTitle", model.reqTitle.getDbValue());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس حذف عضویت در خانواده
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("delete")]
        [Exception]
        [HttpPost]
        public IHttpActionResult delete(familyModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_responsToReqFamily", "FamilyController_responsToReq"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@id", model.id);
                repo.cmd.Parameters.AddWithValue("@deletion", true);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس دریافت عناوین خانواده
        /// </summary>
        /// <returns></returns>
        [Route("getFamilyTitle")]
        [Exception]
        [HttpPost]
        [Obsolete("Depricated")]
        public IHttpActionResult getFamilyTitle()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getFamilyTitle", "FamilyController_getFamilyTitle", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i =>
                new
                {
                    id = Convert.ToInt32(i.Field<object>("id")),
                    title = Convert.ToString(i.Field<object>("title"))
                }
                ).ToList());
            }
        }
    }
    /// <summary>
    /// مدل سرویس تعریف خانواده
    /// </summary>
    public class defineModel
    {
        /// <summary>
        /// عنوان شخص در خانواده از طرف درخواست دهنده
        /// </summary>
        public string title { get; set; }
        /// <summary>
        /// شماره موبایل
        /// </summary>
        public string mobile { get; set; }
        
        /// <summary>
        /// عنوان شخص در خانواده از طرف پذیرنده درخواست
        /// </summary>
        /// 
        
        public string reqTitle { get; set; }
    }
    /// <summary>
    /// مدل سرویس پاسخ به درخواست عضویت در خانواده
    /// </summary>
    public class responsToReqModel
    {
        /// <summary>
        /// شناسه دعوت
        /// </summary>
        public long id { get; set; }
        /// <summary>
        /// پذیرفتن/عدم پذیرفتن
        /// </summary>
        public bool accept { get; set; }
        /// <summary>
        /// عنوان شخص در خانواده از طرف پذیرنده درخواست
        /// </summary>
        public string reqTitle { get; set; }
    }
    /// <summary>
    /// مدل سرویس حذف عضویت در خانواده 
    /// </summary>
    public class familyModel
    {
        /// <summary>
        /// شناسه دعوت
        /// </summary>
        public long id { get; set; }
    }
}
