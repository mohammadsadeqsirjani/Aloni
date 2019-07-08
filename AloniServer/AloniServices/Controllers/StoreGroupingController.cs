using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniServices.Controllers
{
    [RoutePrefix("StoreGrouping")]
    public class StoreGroupingController : AdvancedApiController
    {
        /// <summary>
        /// سرویس افزودن دسته بندی فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("add")]
        [Exception]
        [HttpPost]
        public IHttpActionResult add(StoreGroupingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addStoreGrouping", "StoreGroupingController_add"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (repo.accessDenied)
                    return new ForbiddenActionResult();

                var resultParam = repo.cmd.Parameters.Add("@storegroupingId", sqlDbType:System.Data.SqlDbType.BigInt);
                resultParam.Direction = System.Data.ParameterDirection.Output;
                repo.cmd.Parameters.AddWithValue("@title",model.title.getDbValue());
                repo.cmd.Parameters.AddWithValue("@parentStoreGroupingId",model.fk_storeGrouping_parent.getLongDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId",model.fk_store_id);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(resultParam);
            }
        }
        /// <summary>
        /// سرویس افزودن لیستی از کالاها به دسته بندی داخلی فروشگاه
        /// </summary>
        /// <param name="storeId"></param>
        /// <param name="storeGroupingId"></param>
        /// <param name="itemIdList"></param>
        /// <returns></returns>
        [Route("addItemInStoreGrouping")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addItemInStoreGrouping(AddItemInStoreGroupingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addItemsToStoreGrouping", "StoreGroupingController_addItemInStoreGrouping"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (repo.accessDenied)
                    return new ForbiddenActionResult();


                repo.cmd.Parameters.AddWithValue("@itemIdList", ClassToDatatableConvertor.CreateDataTable(model.itemIdList));
                repo.cmd.Parameters.AddWithValue("@StoreGroupingId",model.storeGroupingId);
                repo.cmd.Parameters.AddWithValue("@storeId",model.storeId);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok();
            }
        }
        /// <summary>
        /// سرویس دریافت لیست دسته بندی های فروشگاه
        /// </summary>
        /// <param name="storeId"></param>
        /// <param name="parentStoreGroupingId"></param>
        /// <returns></returns>
        [Route("getStoreGroupingList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStoreGroupingList(GetStoreGroupingListModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<StoreGroupingModel> result = new List<StoreGroupingModel>();
            using (var repo = new Repo(this, "SP_getStoreGroupingList", "StoreGroupingController_getStoreGroupingList"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (repo.accessDenied)
                    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@parentStoreGroupingId",model.parentStoreGroupingId.getLongDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId",model.storeId);
                repo.ExecuteReader();
               while(repo.sdr.Read())
                {
                    StoreGroupingModel item = new StoreGroupingModel();
                    item.id = Convert.ToInt64(repo.sdr["id"]);
                    item.title = repo.sdr["title"].ToString();
                    result.Add(item);
                }
                
            }
            return Ok(result);
        }

        [Route("getStoreGroupingItemList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStoreGroupingItemList(GetStoreGroupingItemListModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<ItemModel> result = new List<ItemModel>();
            using (var repo = new Repo(this, "SP_getStoreGroupingItems", "StoreGroupingController_getStoreGroupingItemList"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeGroupingId",model.storeGroupingId);
                repo.cmd.Parameters.AddWithValue("@storeId", model.storeId);
                repo.ExecuteReader();
                while (repo.sdr.Read())
                {
                    ItemModel item = new ItemModel();
                    item.id = Convert.ToInt64(repo.sdr["id"]);
                    item.title = repo.sdr["title"].ToString();
                    item.barCode = repo.sdr["barcode"].ToString();
                    item.localBarcode = repo.sdr["localBarcode"].ToString();
                    item.groupName = repo.sdr["groupName"].ToString();
                    item.groupId = Convert.ToInt64(repo.sdr["groupId"]);
                    result.Add(item);
                }
            }
            return Ok(result);
        }

    }
    public class StoreGroupingModel
    {
        public long id { get; set; }
        public string title { get; set; }
        public int? orderNo { get; set; }
        public long? fk_storeGrouping_parent { get; set; }
        public long fk_store_id { get; set; }
        public int fk_status_id { get; set; }
    }
    public class GetStoreGroupingItemListModel:searchParameterModel
    {
        public long storeId { get; set; }
        public long storeGroupingId { get; set; }
    }
    public class GetStoreGroupingListModel:searchParameterModel
    {
        public long storeId { get; set; }
        public long? parentStoreGroupingId { get; set; }
    }
    public class AddItemInStoreGroupingModel
    {
        public long storeId { get; set; }
        public long storeGroupingId { get; set; }
        public List<long> itemIdList { get; set; }
    }
}
