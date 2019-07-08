using System;
using System.Data;
using System.Linq;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// ای پی آی گزارشات نظرسنجی و ارزیابی
    /// </summary>
    /// 
    [RoutePrefix("OpinionReport")]
    public class OpinionReportController : AdvancedApiController
    {
        /// <summary>
        /// دریافت جزئیات ارزیابی و نظرسنجی و کامنت های مرتبط با آیتم ها
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        [Exception]
        [Route("get")]
        public IHttpActionResult get(OpinionReportModelBinding model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getOpinionReport", "OpinionReport_get", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new NotFoundActionResult(repo.rMsg);
                repo.cmd.Parameters.AddWithValue("storeId", storeId);
                repo.cmd.Parameters.AddWithValue("type", model.type.dbNullCheckShort());
                repo.cmd.Parameters.AddWithValue("itemGrpId", model.filter_ItemGrpId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("startDateTime", model.filter_StartDate);
                repo.cmd.Parameters.AddWithValue("endDatetime", model.filter_EndDate);
                repo.ExecuteAdapter();
                var data = repo.ds.Tables[0].AsEnumerable();
                return Ok(
                        data.Select(i=> new
                        {
                            id = Convert.ToInt64(i.Field<object>("id")),
                            title = Convert.ToString(i.Field<object>("title")),
                            technicalTitle = Convert.ToString(i.Field<object>("technicalTitle")),
                            barcode = Convert.ToString(i.Field<object>("barcode")),
                            localBarcode = Convert.ToString(i.Field<object>("localBarcode")),
                            uniqueBarcode = Convert.ToString(i.Field<object>("uniqueBarcode")),
                            opinionCnt = Convert.ToInt32(i.Field<object>("opinionCnt")),
                            opinionAvg = Convert.ToDecimal(i.Field<object>("opinionAvg")),
                            participateCnt = Convert.ToInt32(i.Field<object>("participateCnt")),
                            evaluationCnt = Convert.ToInt32(i.Field<object>("evaluationCnt")),
                            evaluationAvg = Convert.ToDecimal(i.Field<object>("evaluationAvg")),
                        }).ToList()
                    );
            }
        }
    }
    /// <summary>
    /// مدل پایه برای استفاده از سرویس های مربوط به گزارشات نظرسنجی
    /// </summary>
    public class OpinionReportModelBinding:searchParameterModel
    {
        /// <summary>
        ///فیلتر شناسه گروه
        /// </summary>
        public long? filter_ItemGrpId { get; set; }
        /// <summary>
        /// فیلتر بازه شروع نظرسنجی
        /// </summary>
        public DateTime? filter_StartDate { get; set; }
        /// <summary>
        /// فیلتر بازه خاتمه نظرسنجی
        /// </summary>
        public DateTime? filter_EndDate { get; set; }
    }
}
