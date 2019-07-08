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
    /// 
    /// </summary>
    [RoutePrefix("report")]
    public class ReportController : AdvancedApiController
    {
        /// <summary>
        /// گزارش پرسنل
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        [Exception]
        [Route("getEmployee")]
        public IHttpActionResult getEmployee(ReportFilterModelBinding model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_reportGetEmployee", "report_SP_reportGetEmployee", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new NotFoundActionResult(repo.rMsg);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@search", search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@groupId", model.groupId.dbNullCheckLong());
                repo.ExecuteAdapter();
                var data = repo.ds.Tables[0].AsEnumerable();
                return Ok(
                        data.Select(i => new
                        {
                            id = Convert.ToInt64(i.Field<object>("id")),
                            title = Convert.ToString(i.Field<object>("title")),
                            technicalTitle = Convert.ToString(i.Field<object>("technicalTitle")),
                            barcode = Convert.ToString(i.Field<object>("barcode")),
                            uniqueBarcode = Convert.ToString(i.Field<object>("uniqueBarcode")),
                            sex = Convert.ToString(i.Field<object>("sex")),
                            groupTitle = Convert.ToString(i.Field<object>("groupTitle")),
                            state = Convert.ToString(i.Field<object>("state")),
                            city = Convert.ToString(i.Field<object>("city")),
                            unitName = Convert.ToString(i.Field<object>("unitName")),
                            village = Convert.ToString(i.Field<object>("village")),
                            educationTitle = Convert.ToString(i.Field<object>("educationTitle")),
                            categoryTitle = Convert.ToString(i.Field<object>("categoryTitle"))
                        }).ToList()
                    );
            }
        }
        /// <summary>
        /// گزارش موجودیت های اموال،اماکن و شعب
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        [Exception]
        [Route("getEntityReport")]
        public IHttpActionResult getEntityReport(ReportFilterModelBinding model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_reportGetEntities", "report_getEntityReport", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new NotFoundActionResult(repo.rMsg);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@search",model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@groupId", model.groupId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@type", model.type);
                repo.ExecuteAdapter();
                var data = repo.ds.Tables[0].AsEnumerable();
                return Ok(
                        data.Select(i => new
                        {
                            id = Convert.ToInt64(i.Field<object>("id")),
                            title = Convert.ToString(i.Field<object>("title")),
                            technicalTitle = Convert.ToString(i.Field<object>("technicalTitle")),
                            barcode = Convert.ToString(i.Field<object>("barcode")),
                            uniqueBarcode = Convert.ToString(i.Field<object>("uniqueBarcode")),
                            localBarcode = Convert.ToString(i.Field<object>("localBarcode")),
                            groupTitle = Convert.ToString(i.Field<object>("groupTitle")),
                            state = Convert.ToString(i.Field<object>("state")),
                            city = Convert.ToString(i.Field<object>("city")),
                            unitName = Convert.ToString(i.Field<object>("unitName")),
                            village = Convert.ToString(i.Field<object>("village")),
                            educationTitle = Convert.ToString(i.Field<object>("educationTitle")),
                            categoryTitle = Convert.ToString(i.Field<object>("categoryTitle"))
                        }).ToList()
                    );
            }
        }

        /// <summary>
        /// گزارش اقلام انبار
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        [Exception]
        [Route("getItemReport")]
        public IHttpActionResult getItemReport(ReportFilterModelBinding model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_reportGetEntities", "report_getItemReport", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new NotFoundActionResult(repo.rMsg);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@groupId", model.groupId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@type", 1);
                repo.ExecuteAdapter();
                var data = repo.ds.Tables[0].AsEnumerable();
                return Ok(
                        data.Select(i => new
                        {
                            id = Convert.ToInt64(i.Field<object>("id")),
                            title = Convert.ToString(i.Field<object>("title")),
                            technicalTitle = Convert.ToString(i.Field<object>("technicalTitle")),
                            barcode = Convert.ToString(i.Field<object>("barcode")),
                            uniqueBarcode = Convert.ToString(i.Field<object>("uniqueBarcode")),
                            localBarcode = Convert.ToString(i.Field<object>("localBarcode")),
                            groupTitle = Convert.ToString(i.Field<object>("groupTitle")),
                            manufacturerCo = Convert.ToString(i.Field<object>("manufacturerCo")),
                            importerCo = Convert.ToString(i.Field<object>("importerCo")),
                            manufacturerCountry = Convert.ToString(i.Field<object>("manufacturerCountry")),
                            categoryTitle = Convert.ToString(i.Field<object>("categoryTitle"))
                        }).ToList()
                    );
            }
        }
        /// <summary>
        /// گزارش ارزیابی
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        [Exception]
        [Route("getEvaluationReport")]
        public IHttpActionResult getEvaluationReport(searchParameterModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getEvaluationReport", "report_getEvaluationReport", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new NotFoundActionResult(repo.rMsg);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckInt());
                
                repo.ExecuteAdapter();
                var data = repo.ds.Tables[0].AsEnumerable();
                return Ok(
                        data.Select(i => new
                        {
                            id = Convert.ToInt64(i.Field<object>("id")),
                            title = Convert.ToString(i.Field<object>("title")),
                            technicalTitle = Convert.ToString(i.Field<object>("technicalTitle")),
                            barcode = Convert.ToString(i.Field<object>("barcode")),
                            uniqueBarcode = Convert.ToString(i.Field<object>("uniqueBarcode")),
                            evaluationCnt = Convert.ToInt32(i.Field<object>("evaluationCnt")),
                            evaluationAvg = Convert.ToDecimal(i.Field<object>("evaluationAvg")),
                            messageCnt = Convert.ToInt32(i.Field<object>("messageCnt")),
                        
                        }).ToList()
                    );
            }
        }
    }
    public class ReportFilterModelBinding:searchParameterModel
    {
        public long? groupId { get; set; }
    }
}
