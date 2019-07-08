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
    /// سرویس های مرتبط با برنامه زمانبندی پرسنل سازمان (اشخاص)
    /// </summary>
    [RoutePrefix("StoreItemSchedule")]
    public class StoreItemScheduleController : AdvancedApiController
    {
        /// <summary>
        /// سرویس تعریف/ ویرایش زمان بندی پرسنل (اشخاص) سازمان
        /// </summary>
        /// <param name="input"></param>
        /// <returns></returns>
        [Route("addUpdate")]
        [Exception]
        [HttpPost]
        public IHttpActionResult updateScheduleStore(storeItemScheduleAddUpdatemodel input)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);

            using (var repo = new Repo(this, "SP_storeItemSchedule_addUpdate", "StoreItemSchedule_addUpdate"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                DataTable dt = new DataTable();
                DataRow row;
                dt.Columns.Add("storeId");
                dt.Columns.Add("dayOfWeek");
                dt.Columns.Add("isActiveFrom");
                dt.Columns.Add("activeUntil");
                //dt.Columns.Add("itemId");
                foreach (var item in input.schedule)
                {
                    row = dt.NewRow();
                    row["storeId"] = item.id;
                    row["dayOfWeek"] = item.dayOfWeek;
                    row["isActiveFrom"] = item.isActiveFrom;
                    row["activeUntil"] = item.activeUntil;
                    //row["itemId"] = item.itemId
                    dt.Rows.Add(row);
                }
                var param = repo.cmd.Parameters.AddWithValue("@schedules", dt);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@itemId",input.itemId);


                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }

        }
        /// <summary>
        /// سرویس دریافت لیست برنامه زمان بندی پرسنل (اشخاص) سازمان
        /// </summary>
        /// <param name="input"> شناسه فروشگاه </param>
        /// <returns></returns>
        [Route("getList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getScheduleStoreList(getScheduleStoreListModel input)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<StoreScheduleModel> result = new List<StoreScheduleModel>();
            using (var repo = new Repo(this, "SP_storeItemSchedule_getList", "StoreItemSchedule_getList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@search", input.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", input.storeId.HasValue ? input.storeId.Value : storeId);
                repo.cmd.Parameters.AddWithValue("@itemId", input.itemId);
                repo.ExecuteReader();
                while (repo.sdr.Read())
                {
                    StoreScheduleModel item = new StoreScheduleModel();
                    //item.storeId = Convert.ToInt64(repo.sdr["fk_store_id"]);
                    item.dayOfWeek = repo.sdr["onDayOfWeek"].dbNullCheckShort();
                    item.isActiveFrom = TimeSpan.Parse(repo.sdr["isActiveFrom"].ToString());
                    item.activeUntil = TimeSpan.Parse(repo.sdr["activeUntil"].ToString());
                    result.Add(item);
                }
            }
            return Ok(result);
        }
    }
    public class storeItemScheduleAddUpdatemodel
    {
        /// <summary>
        /// شناسه پرسنل (شخص)
        /// </summary>
        public long itemId { get; set; }
        /// <summary>
        /// لیست برنامه هفتگی
        /// </summary>
        public List<StoreScheduleModel> schedule { get; set; }
    }
    public class getScheduleStoreListModel : searchParameterModel
    {
        public long? itemId { get; set; }
        public long? storeId { get; set; }
    }
}
