using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    ///  درخواست اصلاح آیتم های مرجع 
    /// </summary>
    /// 
    [RoutePrefix("RequestCorrectionItemTemplateInformation")]
    public class RequestCorrectionItemTemplateInformationController : AdvancedApiController
    {
        /// <summary>
        /// سرویس افزودن و ویرایش
        /// </summary>
        /// <returns></returns>
        [Route("addUpdate")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addUpdate(RequestCorrectionItemTemplateInformationBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_RequestCorrectionItemTemplateInformationAddUpdate", "RequestCorrectionItemTemplateInformationController_addUpdate"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                DataTable dt = new DataTable();
                dt.Columns.Add("id");
                DataRow row;
                foreach (var item in model.documentList == null ? new List<Guid>() : model.documentList)
                {
                    row = dt.NewRow();
                    row["id"] = item;
                    dt.Rows.Add(row);
                }
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@description", model.description.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@suggestedTitle", model.suggestedTitle.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@suggestedBarcode", model.suggestedBarcode.dbNullCheckString());
                var datatable = repo.cmd.Parameters.AddWithValue("@documentList", dt);
                var param = repo.cmd.Parameters.AddWithValue("@id", model.id.dbNullCheckLong());
                param.Direction = ParameterDirection.InputOutput;
                datatable.SqlDbType = SqlDbType.Structured;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg, id = param.Value });
            }
        }
        /// <summary>
        /// دریافت لیست درخواست ها
        /// </summary>
        /// <returns></returns>
        [Route("getList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getList(RequestGetListBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_RequestCorrectionItemTemplateInformationGetList", "RequestCorrectionItemTemplateInformationController_getList",initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@filterByStatus", model.filterByStatus.dbNullCheckInt());
                repo.cmd.Parameters.AddWithValue("@filterByDateFrom", model.filterByDateFrom.HasValue ? model.filterByDateFrom : null);
                repo.cmd.Parameters.AddWithValue("@filterByDateTo", model.filterByDateTo.HasValue ? model.filterByDateTo : null);
                repo.cmd.Parameters.AddWithValue("@search", model.search.dbNullCheckString());
                repo.ExecuteAdapter();
                var data = repo.ds.Tables[0].AsEnumerable();
                var document = repo.ds.Tables[1].AsEnumerable();
                return Ok(data.Select(c => new
                {
                    itemId = c.Field<object>("id"),
                    itemTitle = c.Field<object>("title"),
                    requestId = c.Field<object>("rqId"),
                    suggestedTitle = c.Field<object>("suggestedTitle"),
                    suggestedBarcode = c.Field<object>("title"),
                    statusId = c.Field<object>("fk_status_id"),
                    statusTitle = c.Field<object>("statusTitle"),
                    description = c.Field<object>("description"),
                    requestDate = c.Field<object>("requestDate"),
                    reviewDate = c.Field<object>("reviewDate"),
                    reviewDescription = c.Field<object>("reviewDescription"),
                    documentList = document.Where(m => Convert.ToInt64(c.Field<object>("rqId")) == Convert.ToInt64(m.Field<object>("id"))).Select(j => new DocumentItemTab
                    {
                        id = Guid.Parse(j.Field<object>("documentId").ToString()),
                        thumbImageUrl = Convert.ToString(j.Field<object>("thumbcompeleteLink"))
                    }).ToList()
                }).ToList()
                    );
            }
        }
    }
    public class RequestGetListBindingModel:searchParameterModel
    {
        /// <summary>
        /// 401 = pending to review
        /// 402 = reviewed
        /// </summary>
        public int filterByStatus { get; set; }
        public DateTime? filterByDateFrom { get; set; }
        public DateTime? filterByDateTo { get; set; }
    }
    public class RequestCorrectionItemTemplateInformationBindingModel
    {
        public long id { get; set; }
        public long itemId { get; set; }
        public string description { get; set; }
        public string suggestedTitle { get; set; }
        public string suggestedBarcode { get; set; }
        public List<Guid> documentList { get; set; }
    }
}
