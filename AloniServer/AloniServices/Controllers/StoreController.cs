using System;
using System.Data;
using System.Web.Http;
using System.Linq;
using Microsoft.SqlServer.Types;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Net;

namespace AloniServices.Controllers
{
    /// <summary>
    /// ای پی آی های مرتبط با موجودیت فروشگاه
    /// </summary>
    [RoutePrefix("Store")]
    public class StoreController : AdvancedApiController
    {
        /// <summary>
        /// سرویس ثبت یک فروشگاه جدید
        /// </summary>
        /// <param name="model">مدل ورودی</param>
        /// <returns></returns>
        [Route("add")]
        [Exception]
        [HttpPost]
        public IHttpActionResult add(storeBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_storeAdd", "StoreController_add", checkAccess: false))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");

                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                DataTable addedexpertise = ClassToDatatableConvertor.CreateDataTable(model.expertises == null ? new List<IdTitleValue<int>>():model.expertises);
                DataTable addedstoreItemGrpPanelCategories = ClassToDatatableConvertor.CreateDataTable(model.storeItemGrpPanelCategories == null ? new List<IdTitleValue<long>>() : model.storeItemGrpPanelCategories);
                //DataTable addedstoreItemGrpItemGrpAndServices = ClassToDatatableConvertor.CreateDataTable(model.storeItemGrpItemGrpAndServices ?? new List<IdTitleValue<long>>());
                repo.cmd.Parameters.AddWithValue("@title", model.title.getDbValue());
                repo.cmd.Parameters.AddWithValue("@id_str", model.id_str.getDbValue());
                repo.cmd.Parameters.AddWithValue("@title_second", model.title_second.getDbValue());
                repo.cmd.Parameters.AddWithValue("@store_typeId", model.storeTyp == null ? 0 : model.storeTyp.id.dbNullCheckInt());
                repo.cmd.Parameters.AddWithValue("@description", model.description.getDbValue());
                repo.cmd.Parameters.AddWithValue("@keyword",model.keyWords == null ? null : model.keyWords.Replace('،', ',').dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@categoryId", (model.category == null ? null :model.category.id.dbNullCheckInt()));
                repo.cmd.Parameters.AddWithValue("@ordersNeedConfimBeforePayment", model.ordersNeedConfimBeforePayment);
                repo.cmd.Parameters.AddWithValue("@onlyCustomersAreAbleToSetOrder", model.onlyCustomersAreAbleToSetOrder);
                repo.cmd.Parameters.AddWithValue("@onlyCustomersAreAbleToSeeItems", model.onlyCustomersAreAbleToSeeItems);
                repo.cmd.Parameters.AddWithValue("@customerJoinNeedsConfirm", model.customerJoinNeedsConfirm);
                repo.cmd.Parameters.AddWithValue("@storePersonalityType",model.storePersonalityType == null ? null : model.storePersonalityType.id.dbNullCheckInt());
                repo.cmd.Parameters.AddWithValue("@uid", model.docId != null ? model.docId : default(Guid));
                var param = repo.cmd.Parameters.AddWithValue("@expertise", addedexpertise);
                param.SqlDbType = SqlDbType.Structured;
                var param_pan = repo.cmd.Parameters.AddWithValue("@storeItemGrpPanelCategories", addedstoreItemGrpPanelCategories);
                param_pan.SqlDbType = SqlDbType.Structured;
              
                var par_storeId = repo.cmd.Parameters.AddWithValue("@storeId", model.storeId.dbNullCheckLong());
                par_storeId.Direction = ParameterDirection.InputOutput;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { storeId = par_storeId.Value });
            }

        }
        /// <summary>
        /// سرویس ویرایش اطلاعات پایه فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("updateBasicStoreInfo")]
        [Exception]
        [HttpPost]
        public IHttpActionResult updateBasicStoreInfo(storeBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "", "StoreController_updateBasicStoreInfo", checkAccess: false))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");

                ////if (!repo.hasAccess)
                ////    return new ForbiddenActionResult();

                //DataTable addedexpertise = ClassToDatatableConvertor.CreateDataTable(model.expertises);
                ////DataRow row;
                ////addedexpertise.Columns.Add("ExpertiseId");
                ////for (int i = 0; i < model.expertises.Length; i++)
                ////{
                ////    row = addedexpertise.NewRow();
                ////    row["ExpertiseId"] = model.expertises[i];
                ////    addedexpertise.Rows.Add(row);
                ////}
                //repo.cmd.Parameters.AddWithValue("@title", model.title.getDbValue());
                //repo.cmd.Parameters.AddWithValue("@id_str", model.id_str.getDbValue());
                //repo.cmd.Parameters.AddWithValue("@title_second", model.id_str.getDbValue());
                //repo.cmd.Parameters.AddWithValue("@store_typeId", model.storeTyp.id);
                //repo.cmd.Parameters.AddWithValue("@description", model.description.getDbValue());
                //repo.cmd.Parameters.AddWithValue("@keyword", model.keyWords.getDbValue());
                //repo.cmd.Parameters.AddWithValue("@categoryId", model.category.id);
                //repo.cmd.Parameters.AddWithValue("@ordersNeedConfimBeforePayment", model.ordersNeedConfimBeforePayment);
                //repo.cmd.Parameters.AddWithValue("@onlyCustomersAreAbleToSetOrder", model.onlyCustomersAreAbleToSetOrder);
                //repo.cmd.Parameters.AddWithValue("@onlyCustomersAreAbleToSeeItems", model.onlyCustomersAreAbleToSeeItems);
                //repo.cmd.Parameters.AddWithValue("@customerJoinNeedsConfirm", model.customerJoinNeedsConfirm);
                //var param = repo.cmd.Parameters.AddWithValue("@expertise", addedexpertise);
                //param.SqlDbType = SqlDbType.Structured;
                //var par_storeId = repo.cmd.Parameters.Add("@storeId", SqlDbType.BigInt);
                //par_storeId.Direction = ParameterDirection.Output;
                //repo.ExecuteNonQuery();
                //if (repo.rCode != 1)
                //    return new NotFoundActionResult(repo.rMsg);
                //return Ok(new { storeId = par_storeId.Value });
            }
            return Ok();
        }
        /// <summary>
        /// سرویس مرحله یک فروشگاه جدید
        /// </summary>
        /// <param name="model">مدل ورودی</param>
        /// <returns></returns>
        [Route("updateStoreLocation")]
        [Exception]
        [HttpPost]
        public IHttpActionResult UpdateStoreLocation(storeBindingModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updateStoreLocation", "StoreController_updateStoreLocation",checkAccess:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();
                var msge = string.Empty;

                DataTable phones = ClassToDatatableConvertor.CreateDataTable(model.phoneNos);
                var par_storeId = repo.cmd.Parameters.AddWithValue("@storeId", model.storeId);
                repo.cmd.Parameters.AddWithValue("@countryId", model.location.country_id);
                repo.cmd.Parameters.AddWithValue("@cityId", model.location.city_id);
                repo.cmd.Parameters.AddWithValue("@addressFull", model.location.address_full.getDbValue());
                repo.cmd.Parameters.AddWithValue("@address", model.location.address.getDbValue());
                repo.cmd.Parameters.AddWithValue("@lat", model.location.lat);
                repo.cmd.Parameters.AddWithValue("@lng", model.location.lng);
                repo.cmd.Parameters.AddWithValue("@email", model.email.getDbValue());
                var param = repo.cmd.Parameters.AddWithValue("@phones", phones);
                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس دریافت اطلاعات واحد پول فروشگاه
        /// </summary>
        /// <param name="storeId">کد فروشگاه</param>
        /// <returns></returns>
        [Route("GetStoreCurrencyUnit")]
        [Exception]
        [HttpPost]
        public IHttpActionResult GetStoreCurrencyUnit(LongKeyModel storeId)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            currencyModel result = new currencyModel();

            using (var repo = new Repo(this, "SP_getStoreCurrencyUnit", "StoreController_GetStoreCurrencyUnit", initAsReader: true,checkAccess:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@search", storeId.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId.id);
                repo.ExecuteReader();

                while (repo.sdr.Read())
                {
                    result.id = Convert.ToInt32(repo.sdr["id"]);
                    result.title = Convert.ToString(repo.sdr["title"]);
                    result.symbol = Convert.ToString(repo.sdr["Symbol"]);
                }
            }
            return Ok(result);
        }
        /// <summary>
        /// سرویس بروزرسانی وضعیت باز یا بسته بودن فروشگاه
        /// </summary>
        /// <param name="storeId"></param>
        /// <param name="status"></param>
        /// <returns></returns>
        [Route("updateShiftStoreStatus")]
        [Exception]
        [HttpPost]
        public IHttpActionResult UpdateShiftStoreStatus(UpdateShiftStoreStatusModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updateShiftStoreStatus", "StoreController_updateShiftStoreStatus",checkAccess:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();

                repo.cmd.Parameters.AddWithValue("@storeId", model.storeId);
                repo.cmd.Parameters.AddWithValue("@statusId", model.shiftStatus);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(repo.rMsg);
            }

        }

        /// <summary>
        /// سرویس دریافت لیستی از فروشگاه های مرتبط با کاربر
        /// </summary>
        /// <returns>
        /// List of UserRelatedStoreModel
        /// </returns>
        [Route("getUserRelatedStoreList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getUserRelatedStoreList(searchParameterModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<UserRelatedStoreModel> result = new List<UserRelatedStoreModel>();
            using (var repo = new Repo(this, "SP_getUserRelatedStore", "StoreController_getUserRelatedStoreList", initAsReader: true, checkAccess: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.ExecuteReader();
                while (repo.sdr.Read())
                {
                    UserRelatedStoreModel item = new UserRelatedStoreModel();
                    item.storeId = Convert.ToInt64(repo.sdr["id"]);
                    item.title = repo.sdr["title"].ToString();
                    item.staffTitle = repo.sdr["staffTitle"].ToString();
                    item.staffId =Convert.ToInt64(repo.sdr["staffId"]);
                    item.userName = repo.sdr["userName"].ToString();
                    item.statusId = Convert.ToInt32(repo.sdr["fk_status_id"]);
                    item.statusStore_dsc = Convert.ToString(repo.sdr["status_des"]);
                    item.unReadMessageCount = Convert.ToInt32(repo.sdr["unReadMessageCount"] is DBNull ? 0 : repo.sdr["unReadMessageCount"]);
                    item.newOrderCount = Convert.ToInt32(repo.sdr["newOrderCount"] is DBNull ? 0 : repo.sdr["newOrderCount"]);
                    item.statusStore = Convert.ToInt32(repo.sdr["fk_status_id"] is DBNull ? 0 : repo.sdr["fk_status_id"]);
                    item.mobile = Convert.ToString(repo.sdr["mobile"]);
                    item.autoSyncTimePeriod = Convert.ToInt32(repo.sdr["autoSyncTimePeriod"]);
                    result.Add(item);
                }
            }
            return Ok(result);
        }
        /// <summary>
        /// سرویس تعریف/ ویرایش زمان بندی فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("updateScheduleStore")]
        [Exception]
        [HttpPost]
        public IHttpActionResult updateScheduleStore(List<StoreScheduleModel> model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);

            using (var repo = new Repo(this, "SP_addShchduleStore", "StoreController_updateScheduleStore",checkAccess:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();
                DataTable dt = new DataTable();
                DataRow row;
                dt.Columns.Add("storeId");
                dt.Columns.Add("dayOfWeek");
                dt.Columns.Add("isActiveFrom");
                dt.Columns.Add("activeUntil");
                foreach (var item in model)
                {
                    row = dt.NewRow();
                    row["storeId"] = item.id;
                    row["dayOfWeek"] = item.dayOfWeek;
                    row["isActiveFrom"] = item.isActiveFrom;
                    row["activeUntil"] = item.activeUntil;
                    dt.Rows.Add(row);
                }
                var param = repo.cmd.Parameters.AddWithValue("@schedules", dt);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(repo.rMsg);
            }

        }
        /// <summary>
        /// سرویس دریافت لیست برنامه زمان بندی فروشگاه
        /// </summary>
        /// <param name="model"> شناسه فروشگاه </param>
        /// <returns></returns>
        [Route("getScheduleStoreList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getScheduleStoreList(LongKeyModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<StoreScheduleModel> result = new List<StoreScheduleModel>();
            using (var repo = new Repo(this, "SP_getStoreScheduleList", "StoreController_getScheduleStoreList", initAsReader: true,checkAccess:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", model.id.dbNullCheckLong());
                repo.ExecuteReader();
                while (repo.sdr.Read())
                {
                    StoreScheduleModel item = new StoreScheduleModel();
                    item.id = Convert.ToInt64(repo.sdr["fk_store_id"]);
                    item.dayOfWeek = Convert.ToInt16(repo.sdr["onDayOfWeek"]);
                    item.isActiveFrom = TimeSpan.Parse(repo.sdr["isActiveFrom"].ToString());
                    item.activeUntil = TimeSpan.Parse(repo.sdr["activeUntil"].ToString());
                    result.Add(item);
                }
            }
            return Ok(result);
        }

        /// <summary>
        /// سرویس دریافت کالاهای  فروشگاه خاص
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getItemsinStoreList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getItemsinStoreList(ItemsOfStoreModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<ItemsOfStoreModel> result = new List<ItemsOfStoreModel>();
            using (var repo = new Repo(this, "SP_getItemListinStore", "StoreController_getItemsinStoreList", initAsReader: true,checkAccess:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();
                
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                repo.cmd.Parameters.AddWithValue("@storeId",(storeId != null) ? storeId : model.storeId);
                repo.cmd.Parameters.AddWithValue("@itemGrpId", model.itemGrpId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@state", model.state);
                repo.cmd.Parameters.AddWithValue("@activeItem", model.activeUnit);
                repo.cmd.Parameters.AddWithValue("@orderType", model.orderType);
                repo.cmd.Parameters.AddWithValue("@showItemInStore",model.showItemInStore == null ? 2 : model.showItemInStore);
                repo.cmd.Parameters.AddWithValue("@sellItemStatus", model.sellItemStatus == null ? 2 : model.sellItemStatus);
                repo.cmd.Parameters.AddWithValue("@taxItemStatus", model.taxItemStatus == null ? 2 : model.taxItemStatus);
                repo.cmd.Parameters.AddWithValue("@discountItemStatus", model.discountItemStatus == null ? 2 : model.discountItemStatus);
                repo.cmd.Parameters.AddWithValue("@typeItem", model.typeItem == null ? 2 : model.typeItem);
                repo.cmd.Parameters.AddWithValue("@catId", model.catId.dbNullCheckLong());
                //repo.ExecuteReader();
                repo.ExecuteAdapter();


                var tb_bd = repo.ds.Tables[0];
                var tb_op = repo.ds.Tables[1].AsEnumerable();
                var tb_doc = repo.ds.Tables[2].AsEnumerable();
                //while (repo.sdr.Read())
                foreach (var itm in tb_bd.AsEnumerable())
                {
                    ItemsOfStoreModel item = new ItemsOfStoreModel();
                    item.ItemId = Convert.ToInt64(itm.Field<object>("pk_fk_item_id") is DBNull ? 0 : itm.Field<object>("pk_fk_item_id"));
                    item.storeId = model.storeId;
                    item.state = model.state;
                    item.type = (model.type == 0 || model.type == null) ? 1 : model.type;
                    item.itemTitle = Convert.ToString(itm.Field<object>("title") is DBNull ? "" : itm.Field<object>("title"));
                    item.technicalTitle = Convert.ToString(itm.Field<object>("technicalTitle"));
                    item.itemGrp_dsc = Convert.ToString(itm.Field<object>("grpTitle"));
                    item.qty = Convert.ToDecimal(itm.Field<object>("qty") is DBNull ? 0 : itm.Field<object>("qty"));
                    item.orderPoint = Convert.ToDecimal(itm.Field<object>("orderPoint") is DBNull ? 0 : itm.Field<object>("orderPoint"));
                    item.loacalBarcode = Convert.ToString(itm.Field<object>("localBarcode") is DBNull ? "" : itm.Field<object>("localBarcode"));
                    item.uniqueBarcode = Convert.ToString(itm.Field<object>("uniqueBarcode"));
                    item.discountPercent_dsc = Convert.ToString(itm.Field<object>("discount_percent"));
                    item.price_dsc = Convert.ToString(itm.Field<object>("price"));
                    item.priceAfterDiscount_dsc = Convert.ToString(itm.Field<object>("priceAfterDiscount"));
                    item.includedTax = Convert.ToBoolean(itm.Field<object>("includedTax"));
                    item.dontShowinginStoreItem = Convert.ToBoolean(itm.Field<object>("dontShowinginStoreItem"));
                    item.isNotForSelling = Convert.ToBoolean(itm.Field<object>("isNotForSelling"));
                    item.qty_dsc = Convert.ToString(itm.Field<object>("qty_dsc"));
                    item.orderPoint_dsc = Convert.ToString(itm.Field<object>("orderPoint_dsc"));
                    item.orginalImage = tb_doc.Where(o => (o.Field<object>("pk_fk_item_id") is DBNull ? 0 : Convert.ToInt64(o.Field<object>("pk_fk_item_id"))) == Convert.ToInt64(itm.Field<object>("pk_fk_item_id") is DBNull ? 0 : itm.Field<object>("pk_fk_item_id"))).Select(c => Convert.ToString(c.Field<object>("completeLink"))).FirstOrDefault();
                    item.thumbnailImage = tb_doc.Where(o => (o.Field<object>("pk_fk_item_id") is DBNull ? 0 : Convert.ToInt64(o.Field<object>("pk_fk_item_id"))) == Convert.ToInt64(itm.Field<object>("pk_fk_item_id") is DBNull ? 0 : itm.Field<object>("pk_fk_item_id"))).Select(c => Convert.ToString(c.Field<object>("thumbcompeleteLink"))).FirstOrDefault();
                    item.isTemplate = Convert.ToBoolean(itm.Field<object>("isTemplate"));
                    var opt = tb_op.Where(o => (o.Field<object>("fk_item_id") is DBNull ? 0 : Convert.ToInt64(o.Field<object>("fk_item_id"))) == Convert.ToInt64(itm.Field<object>("pk_fk_item_id") is DBNull ? 0 : itm.Field<object>("pk_fk_item_id"))).FirstOrDefault();
                    item.activeOpinionpollId = opt == null ? new long?() : Convert.ToInt64(opt.Field<object>("id"));
                    item.itemStatus = new IdTitleValue<int> { id = Convert.ToInt32(itm["statusId"]), title = Convert.ToString(itm["statusTitle"]) };
                    item.barcode = Convert.ToString(itm.Field<object>("barcode"));
                    //item.objectGrp = new IdTitleValue<long> { id = Convert.ToInt32(itm["objectId"]), title = Convert.ToString(itm["objectTitle"]) };
                    item.unit_dsc = Convert.ToString(itm.Field<object>("unit_dsc"));
                    item.isEditable = Convert.ToBoolean(itm.Field<object>("isEditable"));
                    item.pollId = Convert.ToInt64(itm.Field<object>("pollId"));
                    item.isLocked = Convert.ToBoolean(itm.Field<object>("isLocked"));
                    item.commentWaitForConfirmCnt = Convert.ToInt32(itm.Field<object>("commentWaitForConfirmCnt"));
                    result.Add(item);
                }
            }
            return Ok(result);
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getEmployeeinStoreList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getEmployeeinStoreList(EmployeeStoreModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<EmployeeStoreModel> result = new List<EmployeeStoreModel>();
            using (var repo = new Repo(this, "SP_getEmployeeinStoreList", "StoreController_getEmployeeinStoreList", initAsReader: true,checkAccess:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();
                if (model.itemGrp == null) model.itemGrp = new IdTitleValue<long> { id = 0 };
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@state", model.state);
                repo.cmd.Parameters.AddWithValue("@orderType", model.orderType);
                repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                repo.cmd.Parameters.AddWithValue("@itemGrpId", model.itemGrp.id.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@showInStoreStatus", model.showInStoreStatus.dbNullCheckShort());
                repo.cmd.Parameters.AddWithValue("@pollStatus", model.pollStatus.dbNullCheckShort());
                repo.cmd.Parameters.AddWithValue("@sexStatus", model.sexStatus.dbNullCheckShort());

                repo.ExecuteAdapter();
                var tb_bd = repo.ds.Tables[0];
                var tb_eval = repo.ds.Tables[1];
                //while (repo.sdr.Read())
                foreach (var itm in tb_bd.AsEnumerable())
                {
                    EmployeeStoreModel item = new EmployeeStoreModel();
                    item.ItemId = Convert.ToInt64(itm.Field<object>("pk_fk_item_id") is DBNull ? 0 : itm.Field<object>("pk_fk_item_id"));
                    item.itemTitle = Convert.ToString(itm.Field<object>("title") is DBNull ? "" : itm.Field<object>("title"));
                    item.technicalTitle = Convert.ToString(itm.Field<object>("technicalTitle"));
                    item.loacalBarcode = Convert.ToString(itm.Field<object>("localBarcode") is DBNull ? "" : itm.Field<object>("localBarcode"));
                    item.uniqueBarcode = Convert.ToString(itm.Field<object>("uniqueBarcode"));
                    item.dontShowinginStoreItem = Convert.ToBoolean(itm.Field<object>("dontShowinginStoreItem"));
                    item.unitName = Convert.ToString(itm.Field<object>("unitName"));
                    item.startOpinion = Convert.ToString(itm.Field<object>("startDateTime"));
                    item.endOpinion = Convert.ToString(itm.Field<object>("endDateTime"));
                    item.cntOpinion = Convert.ToInt32(itm.Field<object>("cntOpinions"));
                    item.avgOpinion = Convert.ToDecimal(itm.Field<object>("avgOpinions"));
                    item.hasOpinion = Convert.ToBoolean(itm.Field<object>("hasOpinion"));
                    item.opinionPollId = Convert.ToInt64(itm.Field<object>("pollId") is DBNull ? 0 : itm.Field<object>("pollId"));
                    item.showOpinionResult = Convert.ToBoolean(itm.Field<object>("resultIsPublic"));
                    item.orginalImage = Convert.ToString(itm.Field<object>("completeLink"));
                    item.thumbnailImage = Convert.ToString(itm.Field<object>("thumbcompeleteLink"));
                    item.findJustBarcode = Convert.ToBoolean(itm.Field<object>("findJustBarcode"));
                    item.itemGrp = new IdTitleValue<long> { id = Convert.ToInt64(itm.Field<object>("grpId")), title = Convert.ToString(itm.Field<object>("grpTitle")) };
                    item.memberEval = tb_eval.AsEnumerable().Where(c => Convert.ToInt64(itm.Field<object>("pk_fk_item_id")) == Convert.ToInt64(c.Field<object>("fk_item_id"))).Select(c => Convert.ToInt32(c.Field<object>("cnt"))).FirstOrDefault();
                    item.rateEval = tb_eval.AsEnumerable().Where(c => Convert.ToInt64(itm.Field<object>("pk_fk_item_id")) == Convert.ToInt64(c.Field<object>("fk_item_id"))).Select(c => Convert.ToInt32(c.Field<object>("rate"))).FirstOrDefault();
                    item.isLocked = Convert.ToBoolean(itm.Field<object>("isLocked"));
                    item.commentWaitForConfirmCnt = Convert.ToInt32(itm.Field<object>("commentWaitForConfirmCnt"));
                    result.Add(item);
                }
            }
            return Ok(result);
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getObjectinStoreList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getObjectinStoreList(EmployeeStoreModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<EmployeeStoreModel> result = new List<EmployeeStoreModel>();
            using (var repo = new Repo(this, "SP_getObjectinStoreList", "StoreController_getObjectinStoreList", initAsReader: true,checkAccess:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@state", model.state);
                repo.cmd.Parameters.AddWithValue("@orderType", model.orderType);
                repo.cmd.Parameters.AddWithValue("@itemGrp", model.itemGrp != null ? model.itemGrp.id.dbNullCheckLong() : 0);
                repo.cmd.Parameters.AddWithValue("@dontShowinginStoreItem", model.showInStoreStatus);
                repo.cmd.Parameters.AddWithValue("@hasOpinion", model.pollStatus);
                repo.ExecuteAdapter();
                var tb_bd = repo.ds.Tables[0];
                var tb_eval = repo.ds.Tables[1];
                var categories = repo.ds.Tables[2];
                //while (repo.sdr.Read())
                foreach (var itm in tb_bd.AsEnumerable())
                {
                    EmployeeStoreModel item = new EmployeeStoreModel();
                    item.ItemId = Convert.ToInt64(itm.Field<object>("pk_fk_item_id") is DBNull ? 0 : itm.Field<object>("pk_fk_item_id"));
                    item.itemTitle = Convert.ToString(itm.Field<object>("title") is DBNull ? "" : itm.Field<object>("title"));
                    item.technicalTitle = Convert.ToString(itm.Field<object>("technicalTitle"));
                    item.loacalBarcode = Convert.ToString(itm.Field<object>("localBarcode") is DBNull ? "" : itm.Field<object>("localBarcode"));
                    item.uniqueBarcode = Convert.ToString(itm.Field<object>("uniqueBarcode"));
                    item.dontShowinginStoreItem = Convert.ToBoolean(itm.Field<object>("dontShowinginStoreItem"));
                    item.unitName = Convert.ToString(itm.Field<object>("unitName"));
                    item.startOpinion = Convert.ToString(itm.Field<object>("startDateTime"));
                    item.endOpinion = Convert.ToString(itm.Field<object>("endDateTime"));
                    item.cntOpinion = Convert.ToInt32(itm.Field<object>("cntOpinions"));
                    item.avgOpinion = Convert.ToDecimal(itm.Field<object>("avgOpinions"));
                    item.hasOpinion = Convert.ToBoolean(itm.Field<object>("hasOpinion"));
                    item.opinionPollId = Convert.ToInt64(itm.Field<object>("pollId") is DBNull ? 0 : itm.Field<object>("pollId"));
                    item.showOpinionResult = Convert.ToBoolean(itm.Field<object>("resultIsPublic"));
                    item.orginalImage = Convert.ToString(itm.Field<object>("completeLink"));
                    item.thumbnailImage = Convert.ToString(itm.Field<object>("thumbcompeleteLink"));
                    item.itemGrp = new IdTitleValue<long> { id = Convert.ToInt64(itm.Field<object>("grpId")), title = Convert.ToString(itm.Field<object>("grpTitle")) };
                    item.category = categories.AsEnumerable().Where(c => Convert.ToInt64(itm.Field<object>("pk_fk_item_id")) == Convert.ToInt64(c.Field<object>("pk_fk_item_id"))).Select(c => new IdTitleValue<long> { id = Convert.ToInt64(c.Field<object>("catId")), title = Convert.ToString(c.Field<object>("catTitle")) }).ToList();
                    item.memberEval = tb_eval.AsEnumerable().Where(c => Convert.ToInt64(itm.Field<object>("pk_fk_item_id")) == Convert.ToInt64(c.Field<object>("fk_item_id"))).Select(c => Convert.ToInt32(c.Field<object>("cnt"))).FirstOrDefault();
                    item.rateEval = tb_eval.AsEnumerable().Where(c => Convert.ToInt64(itm.Field<object>("pk_fk_item_id")) == Convert.ToInt64(c.Field<object>("fk_item_id"))).Select(c => Convert.ToInt32(c.Field<object>("rate"))).FirstOrDefault();
                    item.isLocked = Convert.ToBoolean(itm.Field<object>("isLocked"));
                    item.commentWaitForConfirmCnt = Convert.ToInt32(itm.Field<object>("commentWaitForConfirmCnt"));
                    result.Add(item);
                }
            }
            return Ok(result);
        }
        /// <summary>
        /// سرویس جست و جو و دریافت لیست اطلاعات کالاهای تمپلیت
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getSearchTemplateItemsinStoreList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getSearchTemplateItemsinStoreList(LongKeyModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<ItemModel> result = new List<ItemModel>();
            using (var repo = new Repo(this, "SP_searchTemplateItem", "StoreController_getSearchTemplateItemsinStoreList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (repo.accessDenied)
                    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", model.id);
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@type", model.type.getDbValue());
                repo.ExecuteReader();

                while (repo.sdr.Read())
                {
                    ItemModel item = new ItemModel();
                    item.id = Convert.ToInt64(repo.sdr["id"]);
                    item.barCode = repo.sdr["barcode"].ToString();
                    item.groupName = repo.sdr["grpName"].ToString();
                    item.groupId = Convert.ToInt64(repo.sdr["fk_itemGrp_id"]);
                    item.title = repo.sdr["title"].ToString();
                    item.technicalTitle = repo.sdr["technicalTitle"].ToString();
                    result.Add(item);
                }
            }
            return Ok(result);
        }
        /// <summary>
        /// سرویس دریافت اطلاعات کامل کالای تمپلیت در فروشگاه
        /// </summary>
        /// <param name="storeId"></param>
        /// <param name="itemId"></param>
        /// <returns></returns>
        [Route("getItemInfo")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getItemInfo(GetItemInfoModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            CustomItemModel result = new CustomItemModel();
            using (var repo = new Repo(this, "SP_getCompleteItemInfo", "StoreController_getItemInfo", initAsReader: true))
            {
                //if (repo.unauthorized)
                //    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId);
                repo.cmd.Parameters.AddWithValue("@storeId", model.storeId.getLongDbValue());
                repo.ExecuteAdapter();
                DataTable bodyInfo = repo.ds.Tables[0];
                DataTable warranty = repo.ds.Tables[1];
                DataTable technical_info = repo.ds.Tables[2];
                DataTable documents = repo.ds.Tables[3];
                DataTable colors = repo.ds.Tables[4];
                DataTable sizes = repo.ds.Tables[5];
                DataTable opinionpoll = repo.ds.Tables[6];
                DataTable inCartCnt = repo.ds.Tables[7];
                DataTable storeCustomCategory = repo.ds.Tables[8];
                foreach (DataRow item in bodyInfo.Rows)
                {

                    result.itemId = model.itemId;
                    result.storeId = Convert.ToInt64(item["storeId"] is DBNull ? false : item["storeId"]);
                   
                    result.storeTitle = Convert.ToString(item["storeName"]);
                    result.isTemplate = Convert.ToBoolean(item["isTemplate"] is DBNull ? false : item["isTemplate"]);
                    result.voted = Convert.ToBoolean(item["voted"] is DBNull ? 0 : item["voted"]);
                    result.editable = Convert.ToBoolean(item["editable"] is DBNull ? 0 : item["editable"]);
                    result.hasWaranty = Convert.ToBoolean(item["hasWarranty"] is DBNull ? 0 : item["hasWarranty"]);
                    result.purcheseWithoutWaranty = Convert.ToBoolean(item["canBePurchasedWithoutWarranty"] is DBNull ? 0 : item["canBePurchasedWithoutWarranty"]);
                    result.education = new IntTitleValue { id = Convert.ToInt32(item["eduId"] is DBNull ? 0 : item["eduId"]), title = Convert.ToString(item["eduTitle"]) };
                    result.storeType = Convert.ToInt32(item["storeType"]);
                    result.userMembershipStatus = Convert.ToInt32(item["statusId"]);
                    result.isCallerFavorite = Convert.ToBoolean(item["isCallerFavorite"]);
                    result.sohInfoItem = new SohInfoTabItem()
                    {
                        unit = new IdTitleValue<int>() { id = Convert.ToInt32(item["fk_unit_id"] is DBNull ? 0 : item["fk_unit_id"]), title = Convert.ToString(item["unitTitle"]) },
                        includesTax = Convert.ToBoolean(item["includedTax"] is DBNull ? false : item["includedTax"]),
                        quantity = Convert.ToDecimal(item["qty"] is DBNull ? 0 : item["qty"]),
                        orderPoint = Convert.ToDecimal(item["orderPoint"] is DBNull ? 0 : item["orderPoint"]),
                        price = Convert.ToDecimal(item["price"] is DBNull ? 0 : item["price"]),
                        price_dsc = Convert.ToString(item["price_dsc"]),
                        discountPerPurcheseNumeric = Convert.ToInt32(item["discount_minCnt"] is DBNull ? 0 : item["discount_minCnt"]),
                        discountPerPurchesePercently = Convert.ToDecimal(item["discount_percent"] is DBNull ? 0 : item["discount_percent"]),
                        prepaymentPercentage = Convert.ToInt32(item["prepaymentPercent"] is DBNull ? 0 : item["prepaymentPercent"]),
                        penaltyCancellationPercentage = Convert.ToInt32(item["cancellationPenaltyPercent"] is DBNull ? 0 : item["cancellationPenaltyPercent"]),
                        periodicValidDayOrder = Convert.ToInt32(item["validityTimeOfOrder"] is DBNull ? 0 : item["validityTimeOfOrder"]),
                        notForSellingItem = Convert.ToBoolean(item["isNotForSelling"] is DBNull ? 0 : item["isNotForSelling"]),
                        discountprice_dsc = Convert.ToString(item["discountprice_dsc"]),
                        promotionPercent = Convert.ToDecimal(item["promotionPercent"] is DBNull ? 0 : item["promotionPercent"]),
                        promotionDsc = Convert.ToString(item["promotionDsc"])
                    };

                    result.basicItem = new BasicItemTab()
                    {
                        country = new IdTitleValue<int>() { id = Convert.ToInt32(item["fk_country_Manufacturer"] is DBNull ? 0 : item["fk_country_Manufacturer"]), title = Convert.ToString(item["countryTitle"]) },
                        manufacturerCo = Convert.ToString(item["ManufacturerCo"]),
                        importerCo = Convert.ToString(item["importerCo"])
                    };

                    result.review = Convert.ToString(item["review"]);
                    result.reviewAddress =$"http://178.22.121.237/Front/Items/Review/{model.itemId}";
                    result.commonItem = new CommonTabItem()
                    {

                        localBarcode = Convert.ToString(item["localBarcode"]),
                        deliveriable = Convert.ToBoolean(item["hasDelivery"] is DBNull ? false : item["hasDelivery"]),
                        barcode = Convert.ToString(item["barcode"]),
                        itemGroup = new IdTitleValue<long>() { id = Convert.ToInt64(item["fk_itemGrp_id"] is DBNull ? 0 : item["fk_itemGrp_id"]), title = Convert.ToString(item["grpTitle"]) },
                        grpType = Convert.ToInt16(item["grpType"] is DBNull ? 0 : item["grpType"]),
                        itemType = Convert.ToInt16(item["grpType"] is DBNull ? 0 : item["grpType"]),
                        itemTitle = Convert.ToString(item["title"]),
                        technicalItem = Convert.ToString(item["technicalTitle"]),
                        dontShowingStoreItems = Convert.ToBoolean(item["dontShowinginStoreItem"]),
                        uniqueBarcode = Convert.ToString(item["uniqueBarcode"]),
                        city = new IntTitleValue { id = Convert.ToInt32(item["cityId"] is DBNull ? 0 : item["cityId"]), title = Convert.ToString(item["cityTitle"]) },
                        state = new IntTitleValue { id = Convert.ToInt32(item["stateId"] is DBNull ? 0 : item["stateId"]), title = Convert.ToString(item["stateTitle"]) },
                        sex = Convert.ToBoolean(item["sex"] is DBNull ? 0 : item["sex"]),
                        village = Convert.ToString(item["village"]),
                        unitName = Convert.ToString(item["unitName"]),
                        dontShowUniqBarcode = Convert.ToBoolean(item["doNotShowUniqueBarcode"] is DBNull ? 0 : item["doNotShowUniqueBarcode"]),
                        fk_ObjectGrpId = new IdTitleValue<long?> { id = item["objectId"].dbNullCheckInt(), title = item["objectTitle"].dbNullCheckString() },
                        findJustBarcode = Convert.ToBoolean(item["findJustBarcode"] is DBNull ? false : item["findJustBarcode"]),
                        hasSchedule = item["hasSchedule"].dbNullCheckBoolean(),
                        todaySchedule = item["todaySchedule"].dbNullCheckString(),
                        currentShiftStatus = item["currentShiftStatus"].dbNullCheckBoolean(),
                        education = new IdTitleValue<int?> { id = item["eduId"].dbNullCheckInt(),title = item["eduTitle"].dbNullCheckString() },
                        storeCustomCategory = storeCustomCategory.AsEnumerable().Select(row => new IdTitleValue<long?>() { id = row.Field<object>("id").dbNullCheckLong(), title = row.Field<object>("title").dbNullCheckString() }).ToList(),
                        location = new ItemLocation { lat = item["lat"].dbNullCheckDouble(), lng = item["lng"].dbNullCheckDouble(), address = item["address"].dbNullCheckString() },
                        commetnCntPerUser =Convert.ToInt32(item["commentCntPerUser"] is DBNull ? null : item["commentCntPerUser"]),
                        commentCntPerDayPerUser = Convert.ToInt32(item["commentCntPerDayPerUser"] is DBNull ? null : item["commentCntPerDayPerUser"]),
                        canUpdateAccessLevel = Convert.ToBoolean(item["canUpdateAccessLevel"] is DBNull ? 0 : item["canUpdateAccessLevel"]),
                        isLocked = Convert.ToBoolean(item["isLocked"] is DBNull ? 0 : item["isLocked"])
                    };

                    result.docInfoItem = documents.AsEnumerable().Select(row =>
                    new DocumentItemTab
                    {
                        isDefault = Convert.ToBoolean(row.Field<object>("isDefault") is DBNull ? 0 : row.Field<object>("isDefault")),
                        downloadLink = Convert.ToString(row.Field<object>("completeLink")),
                        thumbImageUrl = Convert.ToString(row.Field<object>("thumbcompeleteLink")),
                        id = Guid.Parse(row.Field<object>("id").ToString())
                    }).ToList();
                    result.techInfoItem = technical_info.AsEnumerable().Select(row => new TechnicalInfoItemTab
                    {
                        strValue = Convert.ToString(row.Field<object>("strValue")),
                        key = Convert.ToString(row.Field<object>("key")),
                        val = Convert.ToString(row.Field<object>("val")),
                        description = Convert.ToString(row.Field<object>("description")),
                        title = Convert.ToString(row.Field<object>("title")),
                        type = Convert.ToInt32(row.Field<object>("type")),
                        order = Convert.ToInt32(row.Field<object>("order"))
                    }).ToList();

                    result.warantiesItem = warranty.AsEnumerable().Select(row => new WarantyItemTab
                    {
                        warrantyId = Convert.ToInt64(row.Field<object>("id")),
                        WarantyCo = Convert.ToString(row.Field<object>("WarrantyCo")),
                        WarantyPrice = Convert.ToDecimal(row.Field<object>("warrantyCost") is DBNull ? 0 : row.Field<object>("warrantyCost")),
                        WarantyPrice_dsc = Convert.ToString(row.Field<object>("WarantyPrice_dsc")),
                        durationdayWaranty = Convert.ToInt32(row.Field<object>("warrantyDays") is DBNull ? 0 : row.Field<object>("warrantyDays"))

                    }).ToList();
                    result.itemColor = colors.AsEnumerable().Select(row => new ItemColorModel
                    {
                        color = Convert.ToString(row.Field<object>("id")),
                        colorName = Convert.ToString(row.Field<object>("title")),
                        isActive = Convert.ToBoolean(row.Field<object>("isActive")),
                        colorCost = Convert.ToDecimal(row.Field<object>("colorCost"))
                    }).ToList();
                    result.itemSize = sizes.AsEnumerable().Select(row => new ItemSizeModel
                    {
                        sizeInfo = Convert.ToString(row.Field<object>("pk_sizeInfo")),
                        isActive = Convert.ToBoolean(row.Field<object>("isActive") is DBNull ? 1 : row.Field<object>("isActive")),
                        sizeCost = Convert.ToDecimal(row.Field<object>("sizeCost"))
                    }).ToList();
                    result.opinionPoll = opinionpoll == null ? null : opinionpoll.AsEnumerable().Select(f =>
                    new opnionPollModel
                    {
                        id = f.Field<object>("id").dbNullCheckLong(),
                        countOfparticipants = f.Field<object>("countOfparticipants").dbNullCheckInt(),
                        opinionPollIsRunning = f.Field<object>("opinionPollIsRunning").dbNullCheckBoolean(),
                        resultIsPublic = f.Field<object>("resultIsPublic").dbNullCheckBoolean(),
                        title = f.Field<object>("title").dbNullCheckString(),
                        totalAvg = f.Field<object>("totalAvg").dbNullCheckDecimal()
                    }).OrderByDescending(o => o.id).FirstOrDefault();
                    result.inCartCnt = inCartCnt.AsEnumerable().Select(i => Convert.ToInt32(i.Field<object>("sum_qty"))).FirstOrDefault();
                }

            }
            return Ok(result);
        }
        /// <summary>
        /// سرویس جست و جوی لیست فروشگاه ها
        /// </summary>
        /// <param name="model"></param>
        /// <returns>
        /// [
        ///     {
        ///         "id":1,
        ///         "title":'فروشگاه 1',
        ///         "stId":1,
        ///         "stDesc":'باز',
        ///         "addr":'مشهد',
        ///         "dist":4.7,
        ///         "score":3,
        ///         "exper":[{"id": 0,"title": null}],
        ///         "loc": { "country_id": 0, "state_id": 0, "city_id": 0, "address_full": null, "lat": 0.0, "lng": 0.0, "address": null}
        ///     }
        /// ]
        /// </returns>
        [Route("searchStoreList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult searchStoreList(searchStoreModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            // List<searchStoreResult> result = new List<searchStoreResult>();
            using (var repo = new Repo(this, "SP_searchStore", "StoreController_searchStoreList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@itemGroupId", model.itemGrpId.getLongDbValue());
                repo.cmd.Parameters.AddWithValue("@lat", model.lat);
                repo.cmd.Parameters.AddWithValue("@lng", model.lng);
                repo.cmd.Parameters.AddWithValue("@curLat", model.curLat);
                repo.cmd.Parameters.AddWithValue("@curLng", model.curLng);
                repo.cmd.Parameters.AddWithValue("@justOpenStore", model.storeJustOpenState.GetValueOrDefault());
                repo.cmd.Parameters.AddWithValue("@maxDistanceToStore", model.maxDistanceToStore.GetValueOrDefault());
                repo.cmd.Parameters.AddWithValue("@sortByDistance", model.sortByDistance.GetValueOrDefault());
                repo.cmd.Parameters.AddWithValue("@sortByOpenCloseState", model.sortByStoreState.GetValueOrDefault());
                repo.cmd.Parameters.AddWithValue("@sortAlphabetic", model.sortByAlphabetic.GetValueOrDefault());
                repo.cmd.Parameters.AddWithValue("@cityId", model.cityId);
                repo.cmd.Parameters.AddWithValue("@typeStore", model.typeStore.dbNullCheckInt());
                repo.ExecuteAdapter();
                DataTable storeInfo = repo.ds.Tables[0];
                DataTable experties = repo.ds.Tables[1];
                DataTable storeMember = repo.ds.Tables[2];
                DataTable currentUserFollowinStore = repo.ds.Tables[3];
                DataTable documents = repo.ds.Tables[4];
                DataTable hasDelivery = repo.ds.Tables[6];
                DataTable storeDayOpen = repo.ds.Tables[7];
                DataTable storeOpen = repo.ds.Tables[8];
                DataTable storePanel = repo.ds.Tables[9];
                DataTable distanceList = repo.ds.Tables[10];
                DataTable statusList = repo.ds.Tables[11];
                var result = storeInfo.AsEnumerable().Select(row =>
                new searchStoreResult
                {
                    id = Convert.ToInt64(row.Field<object>("id")),
                    title = Convert.ToString(row.Field<object>("title")),
                    dist = distanceList.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(b => Convert.ToString(b.Field<object>("distance"))).FirstOrDefault() ,
                    keywords = Convert.ToString(row.Field<object>("keywords")),
                    storeDefaulDocumnet = repo.ds.Tables[5].AsEnumerable().Where(b => Convert.ToInt64(b.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(b => new DocumentItemTab { thumbImageUrl = Convert.ToString(b.Field<object>("thumbcompeleteLink")), downloadLink = Convert.ToString(b.Field<object>("completeLink")) }).FirstOrDefault(),
                    storeLogo = documents.AsEnumerable().Where(b => Convert.ToInt64(b.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(b => new DocumentItemTab { thumbImageUrl = Convert.ToString(b.Field<object>("thumbcompeleteLink1")), downloadLink = Convert.ToString(b.Field<object>("completeLink1")) }).FirstOrDefault(),
                    storeDocumnetList = repo.ds.Tables[5].AsEnumerable().Where(b => Convert.ToInt64(b.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(b => new DocumentItemTab { thumbImageUrl = Convert.ToString(b.Field<object>("thumbcompeleteLink")), downloadLink = Convert.ToString(b.Field<object>("completeLink")) }).Distinct().Take(5).ToList(),
                    onlineGetway = Convert.ToBoolean(row.Field<object>("onlinePayment")),
                    securePayment = Convert.ToBoolean(row.Field<object>("securePayment")),
                    hasDelivery = hasDelivery.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("storeId")) == Convert.ToInt64(row.Field<object>("id"))).Select(b => Convert.ToBoolean(b.Field<object>("hasDelivery"))).FirstOrDefault(),
                    loc = new locationModel
                    {
                        lat = Convert.ToSingle(row.Field<object>("lat")),
                        lng = Convert.ToSingle(row.Field<object>("lng")),
                        address = Convert.ToString(row.Field<object>("address")),
                        address_full = Convert.ToString(row.Field<object>("address_full")),
                        city_id = Convert.ToInt32(row.Field<object>("fk_city_id")),
                        cityTitle = Convert.ToString(row.Field<object>("cityTitle")),
                        country_id = Convert.ToInt32(row.Field<object>("fk_country_id"))
                    },
                    score = Convert.ToDecimal(row.Field<object>("score")),
                    stDesc = statusList.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(b => Convert.ToString(b.Field<object>("statusTitle"))).FirstOrDefault(),//Convert.ToString(row.Field<object>("statusTitle")),
                    stId = statusList.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(b => Convert.ToInt32(b.Field<object>("statusId"))).FirstOrDefault(),//Convert.ToInt32(row.Field<object>("statusId")),
                    exper = (from table1 in storeInfo.AsEnumerable()
                             join table2 in experties.AsEnumerable() on Convert.ToInt64(table1["id"]) equals Convert.ToInt64(table2["pk_fk_store_id"])
                             where Convert.ToInt64(table2["pk_fk_store_id"]) == Convert.ToInt64(row.Field<object>("id"))
                             select new typStoreExpertiseModel
                             {
                                 id = Convert.ToInt32(table2["id"]),
                                 title = Convert.ToString(table2["title"])
                             }).ToList(),


                    storeFollowerCount = (from table1 in storeInfo.AsEnumerable()
                                          join table2 in storeMember.AsEnumerable() on Convert.ToInt64(table1["id"]) equals Convert.ToInt64(table2["pk_fk_store_id"])
                                          where Convert.ToInt64(table2["pk_fk_store_id"]) == Convert.ToInt64(row.Field<object>("id"))
                                          select Convert.ToInt32(table2.Field<object>("userStoreMember"))).FirstOrDefault(),
                    areYoufollow = (from table1 in storeInfo.AsEnumerable()
                                    join table2 in currentUserFollowinStore.AsEnumerable() on Convert.ToInt64(table1["id"]) equals Convert.ToInt64(table2["pk_fk_store_id"])
                                    where Convert.ToInt64(table2["pk_fk_store_id"]) == Convert.ToInt64(row.Field<object>("id"))
                                    select Convert.ToInt32(table2.Field<int>("userStoreMember"))).Count() > 0 ? true : false,

                    opentoday = string.Join("-", storeDayOpen.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("storeId")) == Convert.ToInt64(row.Field<object>("id"))).Select(b => Convert.ToString(b.Field<object>("time_"))).ToArray().Count() > 0 ? storeDayOpen.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("storeId")) == Convert.ToInt64(row.Field<object>("id"))).Select(b => Convert.ToString(b.Field<object>("time_"))).ToArray() : new string[] { "برنامه زمانبندی مشخص نشده"}),
                    openNow = storeOpen.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("storeId")) == Convert.ToInt64(row.Field<object>("id"))).Count() > 0 ? true : false,
                    panelCategory = string.Join(",", storePanel.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("storeId")) == Convert.ToInt64(row.Field<object>("id"))).Select(b => Convert.ToString(b.Field<object>("grpTitle"))).ToArray()),

                }).ToList();
                return Ok(result);
            }


        }
        /// <summary>
        /// سرویس دریافت اطلاعات فروشگاه
        /// </summary>
        /// <param name="storeId"></param>
        /// <returns></returns>
        [Route("getStoreData")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStoreData(LongKeyModel storeId)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            storeBindingModel result = new storeBindingModel();

            using (var repo = new Repo(this, "SP_getStoreInfo", "Store_getStoreData", checkAccess: false, initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (repo.appId != 2)
                {
                    //if (!repo.hasAccess)
                    //    return new ForbiddenActionResult();
                }

                repo.cmd.Parameters.AddWithValue("@storeId", storeId.id);
                var msg = repo.cmd.Parameters.Add("@msg", SqlDbType.NVarChar);
                var rCode = repo.cmd.Parameters.Add("@rCode", SqlDbType.SmallInt);
                msg.Direction = ParameterDirection.Output;
                rCode.Direction = ParameterDirection.Output;
                msg.Size = 100;
                repo.ExecuteAdapter();
                if (Convert.ToInt16(rCode.Value) == 0)
                    return new NotFoundActionResult(msg.Value.ToString());

                DataTable store = repo.ds.Tables[0];
                DataTable experties = repo.ds.Tables[1];
                DataTable phone = repo.ds.Tables[2];
                DataTable storeAccount = repo.ds.Tables[3];
                DataTable securePayment = repo.ds.Tables[4];
                DataTable followers = repo.ds.Tables[5];
                DataTable certificates = repo.ds.Tables[9];
                DataTable certificateDocuments = repo.ds.Tables[10];
                DataTable customCategory = repo.ds.Tables[14];
                DataTable customCategoryItems = repo.ds.Tables[15];
                DataTable logo = repo.ds.Tables[16];
                DataTable conversationId = repo.ds.Tables[17];
                DataTable itemGrp_panelCategory = repo.ds.Tables[18];
                //DataTable itemGrp_itemGrpAndServices = repo.ds.Tables[19];
                DataTable categoryHeader = repo.ds.Tables[19];
                DataTable highlightVitrins = repo.ds.Tables[20];
                foreach (DataRow item in store.Rows)
                {
                    result.storeId = Convert.ToInt64(item["id"]);
                    result.title = item["title"].ToString();
                    result.id_str = item["id_str"].ToString();
                    result.keyWords = Convert.ToString(item["keyWords"]);
                    result.description = Convert.ToString(item["description"]);
                    result.email = Convert.ToString(item["email"]);
                    result.storeAdminMobile = Convert.ToString(item["mobile"]);
                    result.expertises = experties.AsEnumerable().Select(row => new IdTitleValue<int> { id = row.Field<int>(0), title = row.Field<string>(1) }).ToList();
                    result.phoneNos = phone.AsEnumerable().Select(row => new Phone { phone = Convert.ToString(row.Field<object>("phone")), isDefault = Convert.ToBoolean(row.Field<object>("isDefault")) }).ToList();
                    result.description_second = Convert.ToString(item["description_second"]);
                    result.title_second = Convert.ToString(item["title_second"]);
                    result.verifiedAsOriginal = Convert.ToBoolean(item["verifiedAsOriginal"] is DBNull ? 0 : item["verifiedAsOriginal"]);
                    result.shiftStartTime = TimeSpan.Parse(item["shiftStartTime"] is DBNull ? $"0" : item["shiftStartTime"].ToString());
                    result.shiftEndTime = TimeSpan.Parse(item["shiftEndTime"] is DBNull ? $"0" : item["shiftEndTime"].ToString());
                    result.fk_status_shiftStatus = item["fk_status_shiftStatus"].dbNullCheckInt();
                    result.fk_status_shiftStatus_dsc = Convert.ToString(item["fk_status_shiftStatus_dsc"]);
                    result.hasSchedule = item["hasSchedule"].dbNullCheckBoolean();
                    result.reportedByCaller = item["reportedByCaller"].dbNullCheckBoolean();
                    result.todaySchedule = item["todaySchedule"].dbNullCheckString();
                    result.currentShiftStatus = item["currentShiftStatus"].dbNullCheckBoolean();
                    result.ordersNeedConfimBeforePayment = Convert.ToBoolean(item["ordersNeedConfimBeforePayment"]);
                    result.customerJoinNeedsConfirm = Convert.ToBoolean(item["customerJoinNeedsConfirm"]);
                    result.onlyCustomersAreAbleToSeeItems = Convert.ToBoolean(item["onlyCustomersAreAbleToSeeItems"]);
                    result.onlyCustomersAreAbleToSetOrder = Convert.ToBoolean(item["onlyCustomersAreAbleToSetOrder"]);
                    result.taxRate = Convert.ToDecimal(item["taxRate"]);
                    result.taxIncludedInPrices = Convert.ToBoolean(item["taxIncludedInPrices"]);
                    result.calculateTax = Convert.ToBoolean(item["calculateTax"]);
                    result.canOrderWhenClose = Convert.ToBoolean(item["canOrderWhenClose"]);
                    result.score = Convert.ToDecimal(item["score"] is DBNull ? 0 : item["score"]);
                    result.status = new IdTitleValue<int>() { id = Convert.ToInt32(item["fk_status_id"]), title = Convert.ToString(item["statusTitle"]) };
                    result.category = new IdTitleValue<int?>() { id = item["fk_store_category_id"].dbNullCheckInt(), title = item["categoryTitle"].dbNullCheckString() };
                    result.storeTyp = new IdTitleValue<int>() { id = Convert.ToInt32(item["fk_store_type_id"]), title = Convert.ToString(item["storeTypTitle"]) };
                    result.city = new IdTitleValue<int>() { id = Convert.ToInt32(item["fk_city_id"] is DBNull ? 0 : item["fk_city_id"]), title = Convert.ToString(item["cityTitle"]) };
                    result.state = new IdTitleValue<int>() { id = Convert.ToInt32(item["stateId"] is DBNull ? 0 : item["stateId"]), title = Convert.ToString(item["stateTitle"]) };
                    result.country = new IdTitleValue<int>() { id = Convert.ToInt32(item["fk_country_id"] is DBNull ? 0 : item["fk_country_id"]), title = Convert.ToString(item["countryTitle"]) };
                    result.location = new locationModel() { address = Convert.ToString(item["address"]), address_full = Convert.ToString(item["address_full"]), lat = Convert.ToSingle(item["lat"] is DBNull ? 0 : item["lat"]), lng = Convert.ToSingle(item["lng"] is DBNull ? 0 : item["lng"]) };
                    result.account = Convert.ToString(item["account"]);
                    result.bank = storeAccount.AsEnumerable().Select(i => new IdTitleValue<int>() { id = Convert.ToInt32(i.Field<object>("fk_bank_id")), title = Convert.ToString(i.Field<object>("bankName")) }).FirstOrDefault();
                    result.onlinePaymentGetway = storeAccount.AsEnumerable().Select(i => new IdTitleValue<int>() { id = Convert.ToInt32(i.Field<object>("statusId")), title = Convert.ToString(i.Field<object>("statusTitle")) }).FirstOrDefault();
                    result.securePayment = securePayment.AsEnumerable().Select(i => new IdTitleValue<int>() { id = Convert.ToInt32(i.Field<object>("statusId")), title = Convert.ToString(i.Field<object>("statusTitle")) }).FirstOrDefault();
                    result.hasDelivery = securePayment.AsEnumerable().Select(i => Convert.ToBoolean(i.Field<object>("hasDelivery"))).FirstOrDefault();
                    result.followers = followers.AsEnumerable().Select(i => Convert.ToString(i.Field<object>("followersCount"))).FirstOrDefault();
                    result.socialNetwork = repo.ds.Tables[6].AsEnumerable().Select(i => new storeSocialNetworkModel { socialNetworkType = Convert.ToString(i.Field<object>("socialNetworkType")), socialNetworkAccount = Convert.ToString(i.Field<object>("socialNetworkAccount")) }).ToList();
                    result.notification = Convert.ToBoolean(item["notification"] is DBNull ? 0 : item["notification"]);
                    result.secondLanSetting = new secondLanguageSetting() { title = Convert.ToString(item["second_lan_title"]), dsc = Convert.ToString(item["second_lan_about"]), manager = Convert.ToString(item["second_lan_manager"]), address = Convert.ToString(item["second_lan_address"]) };
                    result.storePersonalityType = new IdTitleValue<int?>() { id = item["storePersonalityType"].dbNullCheckInt(), title = item["storePersonalityType_dsc"].dbNullCheckString() };
                    result.storeItemGrpPanelCategories = itemGrp_panelCategory.AsEnumerable().Select(row => new IdTitleValue<long> { id = row.Field<long>(0), title = row.Field<string>(1) }).ToList();
                    //result.storeItemGrpItemGrpAndServices = itemGrp_itemGrpAndServices.AsEnumerable().Select(row => new IdTitleValue<long> { id = row.Field<long>(0), title = row.Field<string>(1) }).ToList();
                    result.itemGroupList = repo.ds.Tables[7].AsEnumerable().Select(i =>
                    new storeItemGrpModel
                    {
                        itemGrpId = Convert.ToInt64(i.Field<object>("id")),
                        itemGrpTitle = Convert.ToString(i.Field<object>("title")),
                        itemGrpImage = Convert.ToString(i.Field<object>("completeLink")),
                        itemGrpthumbImage = Convert.ToString(i.Field<object>("thumbcompeleteLink"))
                    }).ToList();
                    result.storeActiveCurrentDay = repo.ds.Tables[8].AsEnumerable().Select(i => Convert.ToString(i.Field<object>("storeActiveTime"))).FirstOrDefault();
                    result.certificates = certificates.AsEnumerable().Select(i => new updateStoreCertificateModel
                    {

                        id = Convert.ToInt64(i.Field<object>("id")),
                        title = Convert.ToString(i.Field<object>("title")),
                        dsc = Convert.ToString(i.Field<object>("dsc")),
                        fk_status_id = Convert.ToInt32(i.Field<object>("statusId")),
                        status_dsc = Convert.ToString(i.Field<object>("status_")),
                        documents = certificateDocuments.AsEnumerable().Where(c => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(c.Field<object>("id"))).Select(m => new DocumentItemTab
                        {
                            id = Guid.Parse(m.Field<object>("guid_").ToString()),
                            downloadLink = Convert.ToString(m.Field<object>("completeLink")),
                            thumbImageUrl = Convert.ToString(m.Field<object>("thumbcompeleteLink"))
                        }).ToList()

                    }).ToList();
                    result.cstmrJoinStatus =
                        repo.ds.Tables[11].AsEnumerable().Select(i => new IdTitleValue<int?>
                        {
                            id = i.Field<int?>("cstmrJoinStatus").dbNullCheckInt(),
                            title = i.Field<string>("cstmrJoinStatus_dsc").dbNullCheckString()
                        }).FirstOrDefault();
                    result.storeDocuments = repo.ds.Tables[12].AsEnumerable().Select(i => new DocumentItemTab
                    {
                        id = Guid.Parse(i.Field<object>("id").ToString()),
                        downloadLink = Convert.ToString(i.Field<object>("completeLink")),
                        thumbImageUrl = Convert.ToString(i.Field<object>("thumbcompeleteLink")),
                        isDefault = Convert.ToBoolean(i.Field<object>("isDefault"))
                    }).ToList();
                    result.onlinePaymentGetway = repo.ds.Tables[13].AsEnumerable().Select(i => new IdTitleValue<int> { id = Convert.ToInt32(i.Field<object>("onlineGetway_id") is DBNull ? 0 : i.Field<object>("onlineGetway_id")), title = Convert.ToString(i.Field<object>("onlineGetway_dsc")) }).FirstOrDefault();
                    result.securePayment = repo.ds.Tables[13].AsEnumerable().Select(i => new IdTitleValue<int> { id = Convert.ToInt32(i.Field<object>("securePayment_id") is DBNull ? 0 : i.Field<object>("securePayment_id")), title = Convert.ToString(i.Field<object>("securePayment_dsc")) }).FirstOrDefault();
                    result.storeCustomCategoryList = customCategory.AsEnumerable().Select(i => new CustomCategoryModel
                    {
                        id = Convert.ToInt64(i.Field<object>("id")),
                        title = Convert.ToString(i.Field<object>("title")),
                        document = new DocumentItemTab { thumbImageUrl = Convert.ToString(i.Field<object>("thumbcompeleteLink")), downloadLink = Convert.ToString(i.Field<object>("completeLink")) },
                        itemList = customCategoryItems.AsEnumerable().Where(b => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(b.Field<object>("id"))).Select(c => new CustomCategoryItemDetails
                        {
                            item = new IdTitleValue<long>()
                            {
                                id = Convert.ToInt64(c.Field<object>("itemId")),
                                title = Convert.ToString(c.Field<object>("itemTitle"))
                            }
                        }).ToList()

                    }).ToList();

                    result.storeLogo = logo.AsEnumerable().Select(v => new DocumentItemTab
                    {
                        downloadLink = Convert.ToString(v.Field<object>("ImageUrl")),
                        thumbImageUrl = Convert.ToString(v.Field<object>("thumbImageUrl")),
                        isDefault = Convert.ToBoolean(v.Field<object>("isDefault")),
                        id = Guid.Parse(v.Field<object>("id").ToString())
                    }).FirstOrDefault();
                    result.categoryHeaders = categoryHeader.AsEnumerable().Select(v => new categoryHeader
                    {
                        categoryId = Convert.ToInt64(v.Field<object>("id")),
                        categoryTitle = Convert.ToString(v.Field<object>("title")),
                        categoryType = Convert.ToInt16(v.Field<object>("type"))

                    }).ToList();
                    result.highlightVitrinList = highlightVitrins.AsEnumerable().Select(v => new highlightVitrinStore
                    {
                        id = Convert.ToInt64(v.Field<object>("id")),
                        title = Convert.ToString(v.Field<object>("title")),
                        itemId = Convert.ToInt64(v.Field<object>("fk_item_id")),
                        itemGrp = Convert.ToInt64(v.Field<object>("fk_itemGrp_id")),
                        thumbImage = Convert.ToString(v.Field<object>("thumbcompeleteLink")),
                        type = Convert.ToInt16(v.Field<object>("type"))
                    }).ToList();
                    result.storeAbout_dsc = Convert.ToString(item["storeAbout"]);
                    result.conversationId = conversationId.AsEnumerable().Select(i => Convert.ToInt64(i.Field<object>("id"))).FirstOrDefault();
                }
            }
            return Ok(result);
        }
        /// <summary>
        /// سرویس دریافت لیست مجوزهای فروشگاه
        /// </summary>
        /// <returns></returns>
        [Route("getStoreCertificate")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStoreCertificate()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
           List<updateStoreCertificateModel> result = new List<updateStoreCertificateModel>();

            using (var repo = new Repo(this, "SP_getStoreCertificate", "Store_getStoreCertificate", checkAccess: false, initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (repo.appId != 2)
                {
                    //if (!repo.hasAccess)
                    //    return new ForbiddenActionResult();
                }
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteAdapter();
              
                DataTable certificates = repo.ds.Tables[0];
                DataTable certificateDocuments = repo.ds.Tables[1];
                result = certificates.AsEnumerable().Select(i => new updateStoreCertificateModel
                    {

                        id = Convert.ToInt64(i.Field<object>("id")),
                        title = Convert.ToString(i.Field<object>("title")),
                        dsc = Convert.ToString(i.Field<object>("dsc")),
                        fk_status_id = Convert.ToInt32(i.Field<object>("statusId")),
                        status_dsc = Convert.ToString(i.Field<object>("status_")),
                        documents = certificateDocuments.AsEnumerable().Where(c => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(c.Field<object>("id"))).Select(m => new DocumentItemTab
                        {
                            id = Guid.Parse(m.Field<object>("guid_").ToString()),
                            downloadLink = Convert.ToString(m.Field<object>("completeLink")),
                            thumbImageUrl = Convert.ToString(m.Field<object>("thumbcompeleteLink"))
                        }).ToList(),

                    }).ToList();
                   
            }
            return Ok(result);
        }
        /// <summary>
        /// فعال / غیرفعال کردن نوتی های یک فروشگاه برای کاربر
        /// </summary>
        /// <returns></returns>
        [Route("changeShowStoreActivityStatus")]
        [Exception]
        [HttpPost]
        public IHttpActionResult changeShowStoreActivityStatus()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            storeBindingModel result = new storeBindingModel();

            using (var repo = new Repo(this, "SP_changeShowStoreActivityStatus", "Store_changeShowStoreActivityStatus",checkAccess:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();
                    repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                var msg = repo.cmd.Parameters.Add("@msg", SqlDbType.NVarChar);
                var rCode = repo.cmd.Parameters.Add("@rCode", SqlDbType.SmallInt);
                msg.Direction = ParameterDirection.Output;
                rCode.Direction = ParameterDirection.Output;
                msg.Size = 100;
                repo.ExecuteAdapter();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }

        }
        /// <summary>
        /// سرویس دریافت کالاهای تخفیف دار فروشگاه
        /// شناسه فروشگاه در هدر ست شود
        /// </summary>
        /// <returns></returns>
        [Route("getStoreDiscountList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStoreDiscountList()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);


            using (var repo = new Repo(this, "SP_getStoreDiscountList", "Store_getStoreDiscountList", checkAccess: false, initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (repo.appId != 2)
                {
                    //if (!repo.hasAccess)
                    //    return new ForbiddenActionResult();
                }

                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                var msg = repo.cmd.Parameters.Add("@msg", SqlDbType.NVarChar);
                var rCode = repo.cmd.Parameters.Add("@rCode", SqlDbType.SmallInt);
                msg.Direction = ParameterDirection.Output;
                rCode.Direction = ParameterDirection.Output;
                msg.Size = 100;
                repo.ExecuteAdapter();
                if (Convert.ToInt16(rCode.Value) == 0)
                    return new NotFoundActionResult(msg.Value.ToString());

                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i => new
                {
                    itemId = i.Field<object>("id").dbNullCheckLong(),
                    itemtitle = i.Field<object>("title").dbNullCheckString(),
                    image = i.Field<object>("itemImage").dbNullCheckString(),
                    thumbImage = i.Field<object>("thumbcompeleteLink").dbNullCheckString(),
                    //price = Convert.ToString(i.Field<object>("price")),
                    //discount_percent_dsc = Convert.ToString(i.Field<object>("discount")) + "%",
                    //discount = Convert.ToInt32(i.Field<object>("discount"))
                    //priceAfterDiscount = Convert.ToString(i.Field<object>("priceAfterDiscount")),
                    price = i.Field<object>("price").dbNullCheckDecimal(),
                    price_dsc = i.Field<object>("price_dsc").dbNullCheckString(),
                    discount = i.Field<object>("discount").dbNullCheckDecimal(),
                    discount_dsc = i.Field<object>("discount_dsc").dbNullCheckString(),
                    priceAfterDiscount = i.Field<object>("priceAfterDiscount").dbNullCheckDecimal(),
                    priceAfterDiscount_dsc = i.Field<object>("priceAfterDiscount_dsc").dbNullCheckString(),
                }).ToList());

            }

        }
        /// <summary>
        /// سرویس کالاهای اخیر فروشگاه
        /// شناسه فروشگاه در هدر ست شود
        /// </summary>
        /// <returns></returns>
        [Route("getRecentItemList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getRecentItemList()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);


            using (var repo = new Repo(this, "SP_getRecentItemList", "Store_getRecentItemList", checkAccess: false, initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (repo.appId != 2)
                {
                    //if (!repo.hasAccess)
                    //    return new ForbiddenActionResult();
                }

                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                var msg = repo.cmd.Parameters.Add("@msg", SqlDbType.NVarChar);
                var rCode = repo.cmd.Parameters.Add("@rCode", SqlDbType.SmallInt);
                msg.Direction = ParameterDirection.Output;
                rCode.Direction = ParameterDirection.Output;
                msg.Size = 100;
                repo.ExecuteAdapter();

                if (Convert.ToInt16(rCode.Value) == 0)
                    return new NotFoundActionResult(msg.Value.ToString());

                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i => new
                {
                    itemId = i.Field<object>("id").dbNullCheckLong(),
                    itemtitle = i.Field<object>("title").dbNullCheckString(),
                    image = i.Field<object>("itemImage").dbNullCheckString(),
                    thumbImage = i.Field<object>("thumbcompeleteLink").dbNullCheckString(),
                    price = i.Field<object>("price").dbNullCheckDecimal(),
                    price_dsc = i.Field<object>("price_dsc").dbNullCheckString(),
                    discount = i.Field<object>("discount").dbNullCheckDecimal(),
                    discount_dsc = i.Field<object>("discount_dsc").dbNullCheckString(),
                    priceAfterDiscount = i.Field<object>("priceAfterDiscount").dbNullCheckDecimal(),
                    priceAfterDiscount_dsc = i.Field<object>("priceAfterDiscount_dsc").dbNullCheckString(),
                }).ToList());

            }

        }
        /// <summary>
        /// سرویس ثبت نظر روی یک فروشگاه و یا کالای یک فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addOpinion")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addOpinion(AddOpinionModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addOpinion", "storeController_addOpinion"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
             
                repo.cmd.Parameters.AddWithValue("@storeId",model.storeId.dbNullCheckLong() != null ? model.storeId.Value : storeId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.getLongDbValue());
                repo.cmd.Parameters.AddWithValue("@comment", model.opinion.getDbValue());
                repo.cmd.Parameters.AddWithValue("@rate", model.rate);
                repo.cmd.Parameters.AddWithValue("@saveIp", model.saveIp.getDbValue());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }

        }

        /// <summary>
        /// سرویس ثبت لیست طرق ارسال مرسولات فروشگاه 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addStoreDeliveryTypeList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addStoreDeliveryTypeList(DeliveryTypeModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addStoreDeliveryTypes", "storeController_addStoreDeliveryTypeList"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@title", model.title.getDbValue());
                repo.cmd.Parameters.AddWithValue("@cost", model.cost);
                repo.cmd.Parameters.AddWithValue("@effectiveDeliveryCostOnInvoce", model.effectiveDeliveryCostOnInvoce);
                repo.cmd.Parameters.AddWithValue("@maxSupportedDistancForDelivery", model.maxSupportedDistancForDelivery);
                repo.cmd.Parameters.AddWithValue("@minPriceForActiveDeliveryType", model.minPriceForActiveDeliveryType);
                repo.cmd.Parameters.AddWithValue("@isActive", model.isActive);
                var outParam = repo.cmd.Parameters.Add("@id", SqlDbType.BigInt);
                outParam.Direction = ParameterDirection.Output;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg, id = Convert.ToInt64(outParam.Value) });
            }

        }
        /// <summary>
        /// سرویس دریافت لیست طرق ارسال مرسولات فروشگاه
        /// </summary>
        /// <param name="model">
        /// id = شناسه فروشگاه
        /// </param>
        /// <returns></returns>
        [Route("getStoreDeliveryTypeList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStoreDeliveryTypeList()
        {

            //if (!ModelState.IsValid)
            //    return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getStoreDeliveryTypeList", "storeController_getStoreDeliveryTypeList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@orderId", orderId.getDbValue());
                repo.ExecuteAdapter();
                var result = repo.ds.Tables[0];
                return Ok(

                    result.AsEnumerable().Select(row => new
                    {
                        id = Convert.ToInt64(row.Field<object>("id") is DBNull ? 0 : row.Field<object>("id")),
                        title = Convert.ToString(row.Field<object>("title")),
                        //storeId =Convert.ToInt64(row.Field<object>("storeId") is DBNull ? 0 : row.Field<object>("storeId")),
                        cost_dsc = Convert.ToString(row.Field<object>("cost_dsc")),
                        cost = Convert.ToDecimal(row.Field<object>("cost") is DBNull ? 0 : row.Field<object>("cost")),
                        effectiveDeliveryCostOnInvoce = Convert.ToBoolean(row.Field<object>("includeCostOnInvoice") is DBNull ? false : row.Field<object>("includeCostOnInvoice")),
                        //lat =Convert.ToSingle(row.Field<object>("lat") is DBNull ? 0 : row.Field<object>("lat")),
                        //lng =Convert.ToSingle(row.Field<object>("lng") is DBNull ? 0 : row.Field<object>("lng")),
                        maxSupportedDistancForDelivery_dsc = Convert.ToString(row.Field<object>("radius_dsc")),
                        maxSupportedDistancForDelivery = Convert.ToInt32(row.Field<object>("radius") is DBNull ? 0 : row.Field<object>("radius")),
                        minPriceForActiveDeliveryType_dsc = Convert.ToString(row.Field<object>("minOrderCost_dsc")),
                        minPriceForActiveDeliveryType = Convert.ToDecimal(row.Field<object>("minOrderCost") is DBNull ? 0 : row.Field<object>("minOrderCost")),
                        isActive = Convert.ToBoolean(row.Field<object>("isActive") is DBNull ? 0 : row.Field<object>("isActive")),
                        //isDelete =Convert.ToBoolean(row.Field<object>("isDelete") is DBNull ? 0 : row.Field<object>("isDelete"))
                    }).ToList()
                    );
            }

        }
        /// <summary>
        /// سرویس ویرایش لیست طرق ارسال مرسولات فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("updateStoreDeliveryTypeList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult updateStoreDeliveryTypeList(DeliveryTypeModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updateStoreDeliveryTypes", "storeController_updateStoreDeliveryTypeList"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@title", model.title.getDbValue());
                repo.cmd.Parameters.AddWithValue("@cost", model.cost);
                repo.cmd.Parameters.AddWithValue("@effectiveDeliveryCostOnInvoce", model.effectiveDeliveryCostOnInvoce);
                repo.cmd.Parameters.AddWithValue("@maxSupportedDistancForDelivery", model.maxSupportedDistancForDelivery);
                repo.cmd.Parameters.AddWithValue("@minPriceForActiveDeliveryType", model.minPriceForActiveDeliveryType);
                repo.cmd.Parameters.AddWithValue("@isActive", model.isActive);
                repo.cmd.Parameters.AddWithValue("@id", model.id);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }

        }
        /// <summary>
        /// سرویس حذف طریقه ارسال مرسولات فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("deleteStoreDeliveryTypeList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult deleteStoreDeliveryTypeList(DeliveryTypeModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_deleteStoreDeliveryType", "storeController_deleteStoreDeliveryTypeList"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@id", model.id);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }

        }
        /// <summary>
        /// سرویس ویرایش تنظیمات ارزش افزوده فروشگاه
        /// </summary>
        /// <param name="model">
        /// storeId
        /// taxRate
        /// taxIncludedInPrices
        /// calculateTax
        /// </param>
        /// <returns></returns>
        [Route("updateStoreTaxSettings")]
        [Exception]
        [HttpPost]
        public IHttpActionResult updateStoreTaxSettings(storeBindingModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updateTaxStoreSettings", "storeController_updateStoreTaxSettings",checkAccess:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();

                repo.cmd.Parameters.AddWithValue("@storeId", model.storeId);
                repo.cmd.Parameters.AddWithValue("@taxRate", model.taxRate);
                repo.cmd.Parameters.AddWithValue("@taxIncludedInPrices", model.taxIncludedInPrices);
                repo.cmd.Parameters.AddWithValue("@calculateTax", model.calculateTax);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }

        }
        /// <summary>
        /// سرویس تعیین وضعیت سفارش گیری فروشگاه در زمان بسته بودن
        /// </summary>
        /// <param name="model">
        /// storeId
        /// canOrderWhenClose
        /// </param>
        /// <returns></returns>
        [Route("updateStoreSettings")]
        [Exception]
        [HttpPost]
        public IHttpActionResult updateStoreSettings(storeBindingModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updateStoreOrderStateSetting", "storeController_updateStoreSettings",checkAccess:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();

                repo.cmd.Parameters.AddWithValue("@storeId", model.storeId);
                repo.cmd.Parameters.AddWithValue("@canOrderWhenClose", model.canOrderWhenClose);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }

        }
        /// <summary>
        /// سرویس دریافت لیست سمت های فروشگاه
        /// </summary>
        /// <returns></returns>
        [Route("getStoreStaffList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStoreStaffList()
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getStoreStaffList", "storeController_getStoreStaffList", initAsReader: true,checkAccess:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(row => new { id = Convert.ToInt32(row.Field<object>("id")), title = Convert.ToString(row.Field<object>("title")) }).ToList());
            }
        }
        /// <summary>
        /// سرویس دریافت لیست کارمندان فروشگاه
        /// نمای واقعی
        /// </summary>
        /// <returns></returns>
        [Route("getStoreEmployeeList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStoreEmployeeList()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getStoreEmployeeList", "storeController_getStoreEmployeeList", initAsReader: true,checkAccess:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteAdapter();

                return Ok(repo.ds.Tables[0].AsEnumerable().Select(
                    row => new
                    {
                        inviteId = Convert.ToInt64(row.Field<object>("id")),
                        Name = Convert.ToString(row.Field<object>("name")),
                        Mobile = Convert.ToString(row.Field<object>("mobile")),
                        storeTitle = Convert.ToString(row.Field<object>("storeInfo")),
                        Staff = Convert.ToString(row.Field<object>("semat_pishnahadi")),
                        status = Convert.ToString(row.Field<object>("status_"))

                    }
                    ).ToList()
                    );
            }
        }
        /// <summary>
        /// سرویس دریافت لیست کارمندان فروشگاه
        /// نمای ظاهری
        /// </summary>
        /// <returns></returns>
        [Route("getStoreEmployeeList_customerView")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStoreEmployeeList_customerView([FromBody]bool CustomersView)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getStoreEmployeeList_customerView", "storeController_getStoreEmployeeList_customerView", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteAdapter();

                return Ok(repo.ds.Tables[0].AsEnumerable().Select(
                    row => new
                    {
                        inviteId = Convert.ToInt64(row.Field<object>("id")),
                        Name = Convert.ToString(row.Field<object>("name")),
                        Mobile = Convert.ToString(row.Field<object>("mobile")),
                        staff = Convert.ToString(row.Field<object>("staff")),
                        completeLink = Convert.ToString(row.Field<object>("completeLink")),
                        thumbcompeleteLink = Convert.ToString(row.Field<object>("thumbcompeleteLink"))

                    }
                    ).ToList()
                    );
            }
        }
        /// <summary>
        /// سرویس تعریف پرسنل 
        /// </summary>
        /// <param name="model">
        /// شناسه فروشگاه در هدر ست شود
        /// </param>
        /// <returns></returns>
        [Route("addEmployee")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addEmployee(addEmployeeModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addEmployee", "storeController_addEmployee"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@fullName", model.fullName.getDbValue());
                Guid documentId;
                if (model.fk_documentId != null & Guid.TryParse(model.fk_documentId, out documentId))
                    repo.cmd.Parameters.AddWithValue("@fk_document_id", Guid.Parse(model.fk_documentId));
                repo.cmd.Parameters.AddWithValue("@mobile", model.mobile.getDbValue());
                repo.cmd.Parameters.AddWithValue("@staff", model.staff.getDbValue());
                repo.cmd.Parameters.AddWithValue("@description", model.dsc.getDbValue());
                var outParam = repo.cmd.Parameters.Add("@id", SqlDbType.BigInt);
                outParam.Direction = ParameterDirection.Output;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg, id = Convert.ToInt32(outParam.Value) });
            }
        }
        /// <summary>
        /// سرویس لیست پرسنل فروشگاه جهت استفاده در اپ خریدار
        /// شناسه فروشگاه در هدر ست شود
        /// </summary>
        /// <returns></returns>
        [Route("getDemoEmployeeList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getDemoEmployeeList()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getDemoStoreEmployee", "storeController_getDemoEmployeeList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteAdapter();
                System.Guid x;
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(
                    row => new
                    {
                        id = Convert.ToInt32(row.Field<object>("id")),
                        fullName = Convert.ToString(row.Field<object>("fullname")),
                        mobile = Convert.ToString(row.Field<object>("mobile")),
                        staff = Convert.ToString(row.Field<object>("staff")),
                        dsc = Convert.ToString(row.Field<object>("description")),
                        picUrl = Convert.ToString(row.Field<object>("completeLink")),
                        thumbPicUrl = Convert.ToString(row.Field<object>("thumbcompeleteLink")),
                        document = new DocumentItemTab { id = Guid.TryParse(Convert.ToString(row.Field<object>("docId")), out x) ? x : default(Guid), downloadLink = Convert.ToString(row.Field<object>("completeLink")), thumbImageUrl = Convert.ToString(row.Field<object>("thumbcompeleteLink")) }
                    }
                    ).ToList()
                    );
            }
        }
        /// <summary>
        /// سرویس بروزرسانی کارمندان فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("updateEmployee")]
        [Exception]
        [HttpPost]
        public IHttpActionResult updateEmployee(addEmployeeModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updateEmployee", "storeController_updateEmployee"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@fullName", model.fullName.getDbValue());
                Guid documentId;
                if (model.fk_documentId != null & Guid.TryParse(model.fk_documentId, out documentId))
                    repo.cmd.Parameters.AddWithValue("@fk_document_id", Guid.Parse(model.fk_documentId));
                repo.cmd.Parameters.AddWithValue("@mobile", model.mobile.getDbValue());
                repo.cmd.Parameters.AddWithValue("@staff", model.staff.getDbValue());
                repo.cmd.Parameters.AddWithValue("@description", model.dsc.getDbValue());
                repo.cmd.Parameters.AddWithValue("@id", model.id);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس حذف کارمند از لیست کارکنان فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("deleteEmployee")]
        [Exception]
        [HttpPost]
        public IHttpActionResult deleteEmployee(addEmployeeModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_deleteEmployee", "storeController_deleteEmployee"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@id", model.id);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس تغییر وضعیا علان های فروشگاه
        /// شناسه فروشگاه در هدر ست شود
        ///  این سرویس زمانی که فرخوانی میشود چنانچه وضعیت فعلی اعلان فعال باشد آنرا غیرفعال میکند و بالعکس
        /// </summary>
        /// <returns></returns>
        [Route("changeNotificationStore")]
        [Exception]
        [HttpPost]
        public IHttpActionResult changeNotificationStore()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_changeNotificationStore", "storeController_changeNotificationStore"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس گزارش محتوای نامناسب فروشگاه
        /// شناسه پنل در هدر ست شود
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("report")]
        [Exception]
        [HttpPost]
        public IHttpActionResult report(reportModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_reportStore", "storeController_reportStore"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@dsc", model.dsc.getDbValue());
                repo.cmd.Parameters.AddWithValue("@conversationId", model.conversationId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@fk_order_correspondence", model.fk_order_correspondence_Id.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@reportTypeId", model.reportTypeId.dbNullCheckInt());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس دریافت فروشگاه های پیشنهادی
        /// </summary>
        /// <returns></returns>
        [Route("getStoreSuggested")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStoreSuggested()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getStoreSuggested", "storeController_getStoreSuggested", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.ExecuteAdapter();

                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i =>
                new
                {
                    storeId = Convert.ToInt64(i.Field<object>("id")),
                    storeLogo = Convert.ToString(i.Field<object>("storeLogo")),
                    thumbStoreLogo = Convert.ToString(i.Field<object>("thumbcompeleteLink")),
                    storeTitle = Convert.ToString(i.Field<object>("title")),
                    storeTitleSecond = Convert.ToString(i.Field<object>("title_second"))
                }).ToList());
            }
        }
        /// <summary>
        /// سرویس درباره فروشگاه
        /// شناسه فروشگاه هدر ست شود
        /// </summary>
        /// <returns></returns>
        [Route("getStoreAbout")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStoreAbout()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getStoreAboutList", "storeController_getStoreAbout", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteAdapter();

                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i =>
                new
                {
                    aboutId = Convert.ToInt64(i.Field<object>("id")),
                    aboutTitle = Convert.ToString(i.Field<object>("title")),
                    dsc = Convert.ToString(i.Field<object>("description")),
                    language = new IdTitleValue<string>() { id = Convert.ToString(i.Field<object>("fk_language_id")), title = Convert.ToString(i.Field<object>("lanTitle")) },
                    images = repo.ds.Tables[1].AsEnumerable().Where(c => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(c.Field<object>("id"))).Select(c => new DocumentItemTab
                    {
                        id = Guid.Parse(c.Field<object>("imageId").ToString()),
                        downloadLink = Convert.ToString(c.Field<object>("completeLink")),
                        thumbImageUrl = Convert.ToString(c.Field<object>("thumbcompeleteLink")),
                        isDefault = Convert.ToBoolean(c.Field<object>("isDefault"))
                    }).ToList()
                }).ToList());
            }
        }
        /// <summary>
        /// سرویس دریافت لیست نظرات فروشگاه
        /// شناسه فروشگاه در هدر ست شود
        /// </summary>
        /// <returns></returns>
        [Route("getStoreEvaluationList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStoreEvaluationList()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getStoreEvaluationList", "storeController_getStoreEvaluationList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                var permitTovote = repo.cmd.Parameters.Add("@permitToVote", SqlDbType.BigInt);
                permitTovote.Direction = ParameterDirection.Output;
                repo.ExecuteAdapter();

                Tuple<float, int> x = repo.ds.Tables[1].AsEnumerable().Count() > 0 ? repo.ds.Tables[1].AsEnumerable().Select(i => new Tuple<float, int>(Convert.ToSingle(i.Field<object>("storeRate") is DBNull ? 0 : i.Field<object>("storeRate")), Convert.ToInt32(i.Field<object>("commentNo") is DBNull ? 0 : i.Field<object>("commentNo")))).FirstOrDefault():new Tuple<float, int>(0,0);
                return Ok(
                    new EvaloationStoreModel()
                    {
                        commentList = repo.ds.Tables[0].AsEnumerable().Select(i =>
                        new commentModel()
                        {
                            evaluationStoreId = Convert.ToInt64(i.Field<object>("id")),
                            name = Convert.ToString(i.Field<object>("name")),
                            date = Convert.ToString(i.Field<object>("date")),
                            comment = Convert.ToString(i.Field<object>("comment")),
                            likeNo = Convert.ToInt32(i.Field<object>("likeNo") is DBNull ? 0 : i.Field<object>("likeNo")),
                            disLikeNo = Convert.ToInt32(i.Field<object>("disLikeNo") is DBNull ? 0 : i.Field<object>("disLikeNo")),
                            rate = Convert.ToSingle(i.Field<object>("rate")),
                            voted = Convert.ToBoolean(i.Field<object>("voted")),
                            orderCnt = Convert.ToInt32(i.Field<object>("orderCnt"))
                        }
                    ).ToList(),
                        storeRate = x.Item1,
                        commentNo = x.Item2,
                        permitToVote =Convert.ToBoolean(permitTovote.Value)

                    });
            }
        }
        /// <summary>
        /// سرویس ثبت نظر برای فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addStoreEvaluation")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addStoreEvaluation(addStoreEvaluationModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addStoreEvaluation", "StoreController_addStoreEvaluation"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@rate", model.rate);
                repo.cmd.Parameters.AddWithValue("@comment", model.comment);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس رای به نظر فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("voteToComment")]
        [Exception]
        [HttpPost]
        public IHttpActionResult voteToComment(voteToCommentModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_voteToComment", "StoreController_voteToComment"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@like", model.like);
                repo.cmd.Parameters.AddWithValue("@disLike", model.disLike);
                repo.cmd.Parameters.AddWithValue("@evalId", model.evaluationStoreId);
                var countParam = repo.cmd.Parameters.Add("@count", SqlDbType.BigInt);
                countParam.Direction = ParameterDirection.Output;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg, count = Convert.ToInt32(countParam.Value) });
            }
        }
        /// <summary>
        /// سرویس افزودن درباره فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addStoreAbout")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addStoreAbout(StoreAboutModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addStoreAbout", "storeController_addStoreAbout"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@title", model.title.getDbValue());
                repo.cmd.Parameters.AddWithValue("@languageId", model.languageId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@dsc", model.dsc.getDbValue());
                DataTable documents = ClassToDatatableConvertor.CreateDataTable(model.documents);
                var param = repo.cmd.Parameters.AddWithValue("@document", documents);
                param.SqlDbType = SqlDbType.Structured;
                var outParam = repo.cmd.Parameters.Add("@id", SqlDbType.BigInt);
                outParam.Direction = ParameterDirection.Output;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg, id = Convert.ToInt32(outParam.Value) });
            }
        }
        /// <summary>
        /// ويرايش درباره فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("updateStoreAbout")]
        [Exception]
        [HttpPost]
        public IHttpActionResult updateStoreAbout(StoreAboutModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updateStoreAbout", "storeController_updateStoreAbout"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@title", model.title.getDbValue());
                repo.cmd.Parameters.AddWithValue("@languageId", model.languageId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@dsc", model.dsc.getDbValue());
                DataTable documents = ClassToDatatableConvertor.CreateDataTable(model.documents);
                repo.cmd.Parameters.AddWithValue("@id", model.id);
                var param = repo.cmd.Parameters.AddWithValue("@document", documents);
                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس حذف "درباره فروشگاه"
        /// فقط ای دی ست شود
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("deleteStoreAbout")]
        [Exception]
        [HttpPost]
        public IHttpActionResult deleteStoreAbout(StoreAboutModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_deleteStoreAbout", "storeController_deleteStoreAbout"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@id", model.id);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس ثبت/ویرایش مجوزهای فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addStoreCertificate")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addStoreCertificate(updateStoreCertificateModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updateStoreCertificate", "storeController_addStoreCertificate"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                DataTable dt = ClassToDatatableConvertor.CreateDataTable(model.documents);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@title", model.title.getDbValue());
                repo.cmd.Parameters.AddWithValue("@cerId", model.id.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@dsc", model.dsc.getDbValue());
                var outParam = repo.cmd.Parameters.Add("@id", SqlDbType.BigInt);
                outParam.Direction = ParameterDirection.Output;
                var documents = repo.cmd.Parameters.AddWithValue("@documents", dt);
                documents.SqlDbType = SqlDbType.Structured;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg, id = outParam.Value });
            }
        }
        /// <summary>
        /// سرویس حذف یک مجوز فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("deleteStoreCertificate")]
        [Exception]
        [HttpPost]
        public IHttpActionResult deleteStoreCertificate(updateStoreCertificateModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_deleteStoreCertificate", "storeController_deleteStoreCertificate"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@id", model.id.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس تغییر نوع فروشگاه از عمومی به خصوصی و یا بالعکس
        /// </summary>
        /// <param name="typeId">شناسه نوع فروشگاه</param>
        /// <returns></returns>
        [Route("changeStoreType")]
        [Exception]
        [HttpPost]
        public IHttpActionResult changeStoreType([FromBody]int typeId)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_changeStoreType", "storeController_changeStoreType"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@fk_Store_type_Id", typeId);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس تنظیمات زبان دوم فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("changeSecondLanguageSetting")]
        [Exception]
        [HttpPost]
        public IHttpActionResult changeSecondLanguageSetting(secondLanguageSetting model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_changeSecondLanguageSetting", "storeController_changeSecondLanguageSetting"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@title", model.title.getDbValue());
                repo.cmd.Parameters.AddWithValue("@dsc", model.dsc.getDbValue());
                repo.cmd.Parameters.AddWithValue("@manager", model.manager.getDbValue());
                repo.cmd.Parameters.AddWithValue("@address", model.address.getDbValue());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس افزودن / ویرایش دسته بندی سفارشی فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addUpdateCustomCategory")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addUpdateCustomCategory(CustomCategoryModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addStoreCustomCategory", "storeController_addUpdateCustomCategory"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                //DataTable dtItemIds = new DataTable();
                //dtItemIds.Columns.Add(new DataColumn("id", typeof(long)));
                //DataRow dr;
                //foreach (var id in model.itemList)
                //{
                //    dr = dtItemIds.NewRow();
                //    dr["id"] = id.item.id.getDbValue();
                //    dtItemIds.Rows.Add(dr);
                //}
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@title", model.title.getDbValue());
                //var param = repo.cmd.Parameters.AddWithValue("@itemList", dtItemIds);
                //param.SqlDbType = SqlDbType.Structured;
                repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                repo.cmd.Parameters.AddWithValue("@isActive", model.isActive.dbNullCheckBoolean());
                var outParam = repo.cmd.Parameters.Add("@customcategoryId", SqlDbType.BigInt);
                outParam.Direction = ParameterDirection.InputOutput;
                outParam.Value = model.id.getDbValue();
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg, id = outParam.Value });
            }
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addItemToCategory")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addItemToCategory(addItemToCategoryModle model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addItemToCategory", "storeController_addItemToCategory"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                DataTable dtItemIds = new DataTable();
                dtItemIds.Columns.Add(new DataColumn("id", typeof(long)));
                DataRow dr;
                foreach (var id in model.itemIds)
                {
                    dr = dtItemIds.NewRow();
                    dr["id"] = id;
                    dtItemIds.Rows.Add(dr);
                }
                DataTable dtGrpIds = new DataTable();
                dtGrpIds.Columns.Add(new DataColumn("id", typeof(long)));
                DataRow dr1;
                foreach (var id in model.grpIds)
                {
                    dr1 = dtGrpIds.NewRow();
                    dr1["id"] = id;
                    dtGrpIds.Rows.Add(dr1);
                }
                repo.cmd.Parameters.AddWithValue("@catId", model.catId.dbNullCheckLong());
                var param = repo.cmd.Parameters.AddWithValue("@itemList", dtItemIds);
                param.SqlDbType = SqlDbType.Structured;
                var param1 = repo.cmd.Parameters.AddWithValue("@itemGrpList", dtGrpIds);
                param1.SqlDbType = SqlDbType.Structured;

                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس دریافت لیست دسته بندی های سفارشی فروشگاه
        /// </summary>
        /// <returns></returns>
        [Route("getCustomCategoryList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getCustomCategoryList(getCustomCategoryListModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getCustomCategoryList", "storeController_getCustomCategoryList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@catId", model.catId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                repo.cmd.Parameters.AddWithValue("@search", model.search.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@sortType", model.sortType.dbNullCheckShort());

              

                repo.ExecuteAdapter();
                DataTable info = repo.ds.Tables[0];
                DataTable itemCn = repo.ds.Tables[1];
                DataTable items = repo.ds.Tables[2];
                return Ok(info.AsEnumerable().Select(i => new
                {
                    id = Convert.ToInt64(i.Field<object>("id")),
                    title = Convert.ToString(i.Field<object>("title")),
                    isActive = Convert.ToBoolean(i.Field<object>("isActive")),
                    status_dsc = Convert.ToString(i.Field<object>("status_dsc")),
                    type = Convert.ToInt16(i.Field<object>("type")),
                    itemCnt = itemCn.AsEnumerable().Where(b => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(b.Field<object>("id"))).Select(c => Convert.ToInt32(c.Field<object>("itemCnt"))).FirstOrDefault(),
                    itemList = items.AsEnumerable().Where(b => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(b.Field<object>("id"))).Select(c => new CustomCategoryItemDetails
                    {
                        item = new IdTitleValue<long>()
                        {
                            id = Convert.ToInt64(c.Field<object>("itemId")),
                            title = Convert.ToString(c.Field<object>("itemTitle"))
                        },
                        itemGrp = Convert.ToString(c.Field<object>("grpTitle")),
                        itemImage = new DocumentItemTab { thumbImageUrl = Convert.ToString(c.Field<object>("image_")) }
                    }).ToList()

                }).ToList());
            }
        }
        /// <summary>
        /// سرویس دریافت آیتم های یک دسته بندی
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getCustomCategoryItemDetailList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getCustomCategoryItemDetailList(getCustomCategoryListModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getCustomCategoryItemDetailList", "storeController_getCustomCategoryItemDetailList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@catId", model.catId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                repo.cmd.Parameters.AddWithValue("@search", model.search.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@sortType", model.search.dbNullCheckString());
                repo.ExecuteAdapter();
                DataTable items = repo.ds.Tables[0];
                return Ok(items.AsEnumerable().Select(c => new
                {
                    item = new IdTitleValue<long>()
                    {
                        id = Convert.ToInt64(c.Field<object>("itemId")),
                        title = Convert.ToString(c.Field<object>("itemTitle"))
                    },
                    itemGrp = Convert.ToString(c.Field<object>("grpTitle")),
                    itemImage = new DocumentItemTab { thumbImageUrl = Convert.ToString(c.Field<object>("image_")) }
                }).ToList());
            }
        }
        /// <summary>
        /// سرویس حذف دسته بندی سفارشی فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("deleteCustomeCategory")]
        [Exception]
        [HttpPost]
        public IHttpActionResult deleteCustomeCategory(CustomCategoryModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_deleteCustomeCategory", "storeController_deleteCustomeCategory"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@customcategoryId", model.id.getDbValue());
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemList != null ? model.itemList.FirstOrDefault().item.id.dbNullCheckLong() : null);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرويس جستجوي كالا وي‍‍ژه فروشگاه 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("searchItemsInSpesificStore")]
        [Exception]
        [HttpPost]
        public IHttpActionResult searchItemsInSpesificStore(searchItemsInSpesificStoreModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_searchItemsInSpesificStore", "storeController_searchItemsInSpesificStore", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", model.storeId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@orderByNewstItem", model.orderByNewstItem.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@orderByCheapestItem", model.orderByCheapestItem.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@orderByMostDiscountItem", model.orderByMostDiscountItem.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@orderByMostExpensiveItem", model.orderByMostExpensiveItem.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@justAvailableItems", model.justAvailableItems.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@includeDiscountItems", model.includeDiscountItems.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@storeGroupingId", model.storeGroupingId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@itemGrpId", model.itemGrpId.dbNullCheckLong());
                repo.ExecuteAdapter();
                DataTable info = repo.ds.Tables[0];
                return Ok(info.AsEnumerable().Select(i => new
                {
                    itemId = Convert.ToInt64(i.Field<object>("itemId")),
                    itemTitle = Convert.ToString(i.Field<object>("itemTitle")),
                    qty = Convert.ToDecimal(i.Field<object>("qty")),
                    price = Convert.ToDecimal(i.Field<object>("price")),
                    price_dsc = Convert.ToString(i.Field<object>("price_dsc")),
                    pricewithdiscount = Convert.ToDecimal(i.Field<object>("pricewithdiscount")),
                    pricewithdiscount_dsc = Convert.ToString(i.Field<object>("pricewithdiscount_dsc")),
                    discount_percent = Convert.ToDecimal(i.Field<object>("discount_percent")),
                    thumbImageItem = Convert.ToString(i.Field<object>("thumbcompeleteLink")),
                    itemGrpId = Convert.ToInt64(i.Field<object>("grpId")),
                    itemGrpTitle = Convert.ToString(i.Field<object>("grpTitle")),
                    isNotForSelling = Convert.ToBoolean(i.Field<object>("isNotForSelling")),
                    type = Convert.ToInt16(i.Field<object>("type")),
                    itemCntInCart = Convert.ToInt32(i.Field<object>("itemInCart"))
                }).ToList());
            }
        }

        /// <summary>
        /// سرويس جستجوي اطراف من 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getNearByLocation")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getNearByLocation(getNearByLocationModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getNearByLocation", "storeController_getNearByLocation", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@centerScreenLat", model.centerScreenLat.dbNullCheckDouble());
                repo.cmd.Parameters.AddWithValue("@centerScreenLng", model.centerScreenLng.dbNullCheckDouble());
                repo.cmd.Parameters.AddWithValue("@curLat", model.curLat.dbNullCheckDouble());
                repo.cmd.Parameters.AddWithValue("@curLng", model.curLng.dbNullCheckDouble());
                repo.ExecuteAdapter();
                DataTable info = repo.ds.Tables[0];
                return Ok(info.AsEnumerable().Select(i => new
                {
                    id = Convert.ToInt64(i.Field<object>("id").dbNullCheckLong()),
                    title = Convert.ToString(i.Field<object>("title").dbNullCheckString()),
                    technicalTitle = Convert.ToString(i.Field<object>("title2").dbNullCheckString()),
                    distance = Convert.ToString(i.Field<object>("distance").dbNullCheckString()),
                    lat = Convert.ToSingle(i.Field<object>("lat").dbNullCheckDouble()),
                    lng = Convert.ToSingle(i.Field<object>("lng").dbNullCheckDouble()),
                    document = new DocumentItemTab { thumbImageUrl = Convert.ToString(i.Field<object>("thumbcompeleteLink")), downloadLink = Convert.ToString(i.Field<object>("completeLink")) },
                    type = Convert.ToInt16(i.Field<object>("type").dbNullCheckShort()),
                    type_dsc = Convert.ToString(i.Field<object>("type_dsc").dbNullCheckString()),
                    storeId = Convert.ToInt64(i.Field<object>("storeId").dbNullCheckLong())
                }).ToList());
            }
        }
        /// <summary>
        /// سرویس دریافت آیتم ها موجود در پنل بر اساس تایپ / جهت استفاده در چاپ برچسب
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getItemList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getItemList(getItemListBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getItemList", "storeController_getItemList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
              
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                repo.cmd.Parameters.AddWithValue("@search", model.search.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@itemGrpId", model.itemGrpId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@justCreateByPanel", model.justCreateByPanel.dbNullCheckBoolean());
                repo.ExecuteAdapter();
                DataTable info = repo.ds.Tables[0];
                return Ok(info.AsEnumerable().Select(i => new
                {
                    id = Convert.ToInt64(i.Field<object>("id").dbNullCheckLong()),
                    title = Convert.ToString(i.Field<object>("title").dbNullCheckString()),
                    technicalTitle = Convert.ToString(i.Field<object>("technicalTitle").dbNullCheckString()),
                    barcode = Convert.ToString(i.Field<object>("barcode").dbNullCheckString()),
                    localBarcode = Convert.ToString(i.Field<object>("localBarcode").dbNullCheckString()),
                    uniqBarcode = Convert.ToString(i.Field<object>("uniqueBarcode").dbNullCheckString()),
                    thumbPicUrl = Convert.ToString(i.Field<object>("thumbcompeleteLink").dbNullCheckString())
                }).ToList());
            }
        }
        /// <summary>
        /// همگام سازی بالکی 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("bulkyUpdateQtyPrice")]
        [Exception]
        [HttpPost]
        public IHttpActionResult bulkyUpdateQtyPrice(BulkeUpdateQtyPriceBindingModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_bulkyUpdateQtyPrice", "StoreController_bulkyUpdateQtyPrice"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                var msge = string.Empty;

                DataTable itemList = ClassToDatatableConvertor.CreateDataTable(model.itemList);
                var par_storeId = repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                var param = repo.cmd.Parameters.AddWithValue("@itemList", itemList);
                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// همگام سازی بالکی ورژن جدید 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("bulkyUpdateQtyPrice_NewVersion")]
        [Exception]
        [HttpPost]
        public IHttpActionResult bulkyUpdateQtyPrice_NewVersion(BulkeUpdateQtyPriceBindingModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_bulkyUpdateQtyPrice_NewVersion", "StoreController_bulkyUpdateQtyPrice_NewVersion"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                var msge = string.Empty;

                DataTable itemList = ClassToDatatableConvertor.CreateDataTable(model.itemList);
                var par_storeId = repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                var param = repo.cmd.Parameters.AddWithValue("@itemList", itemList);
                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        ///ویرایش واحد پول نرم افزارهای جانبی 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("updateRialCurency")]
        [Exception]
        [HttpPost]
        public IHttpActionResult updateRialCurency(updateRialCurencyBindingModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updateRialCurency", "StoreController_updateRialCurency"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                var msge = string.Empty;
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@hasRial", model.hasRial.dbNullCheckBoolean());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        ///ویرایش درصد کاهش موجودی نسبت به نرم افزارهای خارجی 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("updateReducedQty")]
        [Exception]
        [HttpPost]
        public IHttpActionResult updateReducedQty(updateReducedQtyBindingModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updateReducedQty", "StoreController_updateRialCurency"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                var msge = string.Empty;
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@percent", model.percent.dbNullCheckDouble());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// تغییر وضعیت فروش کالاهای منفی در فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("updateSaleNegativeStatus")]
        [Exception]
        [HttpPost]
        public IHttpActionResult updateSaleNegativeStatus(StoreSalesNegativeBindingModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updateSaleNegativeStatus", "StoreController_updateSaleNegativeStatus"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                var msge = string.Empty;
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@canSalesNegative", model.canSalesNegative.dbNullCheckBoolean());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// تعداد کالاهای منفی در فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getItemSaleNegativeCnt")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getItemSaleNegativeCnt(StoreSalesNegativeBindingModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getItemSaleNegativeCnt", "StoreController_getItemSaleNegativeCnt",initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                var msge = string.Empty;
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
              
                repo.ExecuteAdapter();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { cnt = repo.ds.Tables[0].AsEnumerable().Select(i=> i.Field<int>("cnt")).FirstOrDefault()});
            }
        }
        /// <summary>
        /// تنظیمات نوع پنل 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("updateStoreType")]
        [Exception]
        [HttpPost]
        public IHttpActionResult updateStoreType(updateStoreTypeBindingModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updateStoreType", "StoreController_updateStoreType"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                var msge = string.Empty;
                 repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                 repo.cmd.Parameters.AddWithValue("@elzamTasvieFactorBeFactor", model.elzamTasvieFactorBeFactor.dbNullCheckBoolean());
                 repo.cmd.Parameters.AddWithValue("@sabtSefareshFaghatTavasotMoshtarian", model.sabtSefareshFaghatTavasotMoshtarian.dbNullCheckBoolean());
                 repo.cmd.Parameters.AddWithValue("@moshahedeKalaFaghatTavasotMoshtarian", model.moshahedeKalaFaghatTavasotMoshtarian.dbNullCheckBoolean());
                 repo.cmd.Parameters.AddWithValue("@niazBeTaeedBarayeOzviatMoshtarian", model.niazBeTaeedBarayeOzviatMoshtarian.dbNullCheckBoolean());
                 repo.cmd.Parameters.AddWithValue("@namayeshPanelFaghatBeMoshtarianOzv", model.namayeshPanelFaghatBeMoshtarianOzv.dbNullCheckBoolean());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("updateStoreAutoSyncTime")]
        [Exception]
        [HttpPost]
        public IHttpActionResult updateStoreAutoSyncTime(updateStoreAutoSyncTimeBindingModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updateStoreAutoSyncTime", "StoreController_updateStoreAutoSyncTime"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                var msge = string.Empty;
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@timeValue", model.timeValue.dbNullCheckInt());
               
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        ///  دریافت تنظیمات نوع پنل  
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getStoreTypeInfo")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStoreTypeInfo(updateStoreTypeBindingModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getStoreTypeInfo", "StoreController_getStoreTypeInfo", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                var msge = string.Empty;
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i => new updateStoreTypeBindingModel
                {
                    elzamTasvieFactorBeFactor = Convert.ToBoolean(i.Field<object>("elzamTasvieFactorBeFactor")),
                    moshahedeKalaFaghatTavasotMoshtarian = Convert.ToBoolean(i.Field<object>("moshahedeKalaFaghatTavasotMoshtarian")),
                    namayeshPanelFaghatBeMoshtarianOzv = Convert.ToBoolean(i.Field<object>("namayeshPanelFaghatBeMoshtarianOzv")),
                    niazBeTaeedBarayeOzviatMoshtarian = Convert.ToBoolean(i.Field<object>("niazBeTaeedBarayeOzviatMoshtarian")),
                    sabtSefareshFaghatTavasotMoshtarian = Convert.ToBoolean(i.Field<object>("sabtSefareshFaghatTavasotMoshtarian"))
                }
                    ).FirstOrDefault());
            }
        }
        /// <summary>
        /// انتقال ایتم ها از پنل به پنلی دیگر
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("moveItemsToPanel")]
        [Exception]
        [HttpPost]
        public IHttpActionResult moveItemsToPanel(moveItemsToPanelBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_moveItemsToPanel", "StoreController_moveItemsToPanel"/*, checkAccess: true*/))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                var itemList = ClassToDatatableConvertor.CreateDataTable(model.itemList);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@destStoreId", model.destStoreId.dbNullCheckLong());
                var param = repo.cmd.Parameters.AddWithValue("@itemList", itemList);
                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(repo.rMsg);
            }

        }
        /// <summary>
        /// دریافت تنظیمات زبان دوم پنل
        /// </summary>
        /// <returns></returns>
        [Route("getScondLanguagePanelSetting")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getScondLanguagePanelSetting()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getScondLanguagePanelSetting", "StoreController_getScondLanguagePanelSetting", initAsReader:true/*, checkAccess: true*/))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
               
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
              
                repo.ExecuteAdapter();

                return Ok(repo.ds.Tables[0].AsEnumerable().Select(c =>
                new secondLanguageSetting
                {
                    dsc =Convert.ToString(c.Field<object>("second_lan_about")),
                    address =Convert.ToString(c.Field<object>("second_lan_address")),
                    manager =Convert.ToString(c.Field<object>("second_lan_manager")),
                    title =Convert.ToString(c.Field<object>("second_lan_title"))
                }).FirstOrDefault());
            }

        }
        /// <summary>
        /// اعمال تنظیمات مربوط به مدیریت کامنت های منتشر شده برای یک آیتم در پنل
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("updatePanelCommentSetting")]
        [Exception]
        [HttpPost]
        public IHttpActionResult updatePanelCommentSetting(updatePanelCommentSettingBindingPanel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updatePanelCommentSetting", "StoreController_updatePanelCommentSetting"/*, checkAccess: true*/))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
            
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@itemEvaluationShowName", model.itemEvaluationShowName.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@itemEvaluationNeedConfirm", model.itemEvaluationNeedConfirm.dbNullCheckBoolean());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(repo.rMsg);
            }

        }
    }
    /// <summary>
    /// 
    /// </summary>
    public class updatePanelCommentSettingBindingPanel
    {
        /// <summary>
        /// نام نظردهنده نمایش داده شود ؟
        /// </summary>
        public bool itemEvaluationShowName { get; set; }
        /// <summary>
        /// نظرات نیاز به تایید داشته باشند
        /// </summary>
        public bool itemEvaluationNeedConfirm { get; set; }

    }
    /// <summary>
    /// 
    /// </summary>
    public class moveItemsToPanelBindingModel
    {
        public long destStoreId { get; set; }
        public List<LongModel> itemList { get; set; }
    }
    
    public class updateStoreAutoSyncTimeBindingModel
    {
        public int timeValue { get; set; }
    }
    public class updateRialCurencyBindingModel
    {
        public bool hasRial { get; set; }
    }
    public class updateReducedQtyBindingModel
    {
        public float percent { get; set; }
    }
    public class StoreSalesNegativeBindingModel
    {
        public bool canSalesNegative { get; set; }
    }
    public class updateStoreTypeBindingModel
    {
        public bool elzamTasvieFactorBeFactor { get; set; }
        public bool sabtSefareshFaghatTavasotMoshtarian { get; set; }
        public bool moshahedeKalaFaghatTavasotMoshtarian { get; set; }
        public bool niazBeTaeedBarayeOzviatMoshtarian { get; set; }
        public bool namayeshPanelFaghatBeMoshtarianOzv { get; set; }
    }
    public class BulkeUpdateQtyPriceBindingModel
    {
        public List<ViraSystemSyncModel> itemList { get; set; }
    }
    public class ViraSystemSyncModel
    {
        public bool isSelect { get; set; }
        public string title { get; set; }
        public string barcode { get; set; }
        public decimal price { get; set; }
        public decimal qty { get; set; }
        public decimal discount { get; set; }
    }
    public class getItemListBindingModel : searchParameterModel
    {
        public long itemGrpId { get; set; }
        public bool justCreateByPanel { get; set; }
    }
    /// <summary>
    /// مدل سرویس اضافه کردن دریاره فروشگاه
    /// </summary>
    public class StoreAboutModel
    {
        /// <summary>
        /// شناسه 
        /// در حذف کاربرد دارد
        /// </summary>
        public long id { get; set; }
        /// <summary>
        /// عنوان
        /// </summary>
        public string title { get; set; }
        /// <summary>
        /// شناسه زبان
        /// </summary>
        public string languageId { get; set; }
        /// <summary>
        /// شرح
        /// </summary>
        public string dsc { get; set; }
        /// <summary>
        /// لیستی از شناسه های تصویر
        /// </summary>
        public List<DocumentItemTab> documents { get; set; }

    }
    /// <summary>
    /// مدل سرویس ثبت نظر
    /// </summary>
    public class addStoreEvaluationModel
    {
        public float rate { get; set; }
        public string comment { get; set; }
    }
    /// <summary>
    /// مدل سرویس رای به نظر در رابطه فروشگاه
    /// از بین لایک و دیسلایک یک گزینه حتما مقدار داشتبه باشد
    /// </summary>
    public class voteToCommentModel
    {
        /// <summary>
        /// شناسه کامنت
        /// </summary>
        public long evaluationStoreId { get; set; }
        /// <summary>
        /// نی تواند نال باشد
        /// </summary>
        public bool? like { get; set; }
        /// <summary>
        /// می تواند نال باشد
        /// </summary>
        public bool disLike { get; set; }
    }
    public class commentModel
    {
        public long evaluationStoreId { get; set; }
        public string name { get; set; }
        public string date { get; set; }
        public string comment { get; set; }
        public int likeNo { get; set; }
        public int disLikeNo { get; set; }
        public float rate { get; set; }
        public bool voted { get; set; }
        public int orderCnt { get; set; }
    }
    public class secondLanguageSetting
    {
        public string title { get; set; }
        public string dsc { get; set; }
        public string manager { get; set; }
        public string address { get; set; }
    }
    public class EvaloationStoreModel
    {
        public List<commentModel> commentList { get; set; }
        public float storeRate { get; set; }
        public int commentNo { get; set; }
        public bool permitToVote { get; set; }
    }
    /// <summary>
    /// مدل پایه برای سرویس های مربوط به دسته بندی سفارشی فروشگاه
    /// </summary>
    public class CustomCategoryModel
    {
        /// <summary>
        /// شناسه دسته بندی سفارشی - به منظور ویرایش
        /// </summary>
        public long id { get; set; }
        /// <summary>
        /// عنوان - اجباری
        /// </summary>
        public string title { get; set; }
        public bool isActive { get; set; }
        public short? type { get; set; }
        /// <summary>
        /// تصویر دسته بندی فروشگاه
        /// </summary>
        public DocumentItemTab document { get; set; }
        /// <summary>
        /// لیستی از کالاهایی که به دسته بندی بایند شده
        /// </summary>
        public List<CustomCategoryItemDetails> itemList { get; set; }


    }
    public class CustomCategoryItemDetails
    {
        public IdTitleValue<long> item { get; set; }
        public DocumentItemTab itemImage { get; set; }
        public string itemGrp { get; set; }
    }
    public class getCustomCategoryListModel : searchParameterModel
    {
        public long catId { get; set; }
        /// <summary>
        /// 1. جدیدترین
        /// 2. قدیمی ترین
        /// 3. کمترین تعداد آیتم
        /// 4. بیشترین تعداد آیتم
        /// </summary>
        public short sortType { get; set; }
    }
    public class addItemToCategoryModle
    {
        public long catId { get; set; }
        public List<long> grpIds { get; set; }
        public List<long> itemIds { get; set; }
    }
    public class getNearByLocationModel
    {
        public float? centerScreenLat { get; set; }
        public float? centerScreenLng { get; set; }
        public float? curLat { get; set; }
        public float? curLng { get; set; }
    }
    public class searchItemsInSpesificStoreModel
    {
        public long storeId { get; set; }
        public bool orderByNewstItem { get; set; }
        public bool orderByCheapestItem { get; set; }
        public bool orderByMostExpensiveItem { get; set; }
        public bool orderByMostDiscountItem { get; set; }
        public bool justAvailableItems { get; set; }
        public bool includeDiscountItems { get; set; }
        public long storeGroupingId { get; set; }
        public long itemGrpId { get; set; }
        public string search { get; set; }
    }
    #region Models
    /// <summary>
    /// مدل سرویس ریپورت فروشگاه
    /// </summary>
    public class reportModel
    {
        /// <summary>
        /// توضیحات
        /// </summary>
        public string dsc { get; set; }
        /// <summary>
        /// نوع گزارش
        /// </summary>
        public int reportTypeId { get; set; }
        public long? conversationId { get; set; }
        public long? orderId { get; set; }

        public long? fk_order_correspondence_Id { get; set; }

    }
    /// <summary>
    /// مدل سرویس های کارمندان فروشگاه
    /// </summary>
    public class addEmployeeModel
    {
        public long id { get; set; }
        /// <summary>
        /// شناسه تصویر پرسنل
        /// </summary>
        public string fk_documentId { get; set; }
        /// <summary>
        /// شماره موبایل
        /// </summary>
        public string mobile { get; set; }
        /// <summary>
        /// سمت
        /// </summary>
        public string staff { get; set; }
        /// <summary>
        /// توضیحات
        /// </summary>
        public string dsc { get; set; }
        /// <summary>
        /// نام و نام خانوادگی
        /// </summary>
        public string fullName { get; set; }
    }
    /// <summary>
    /// مدل سرویس ویرایش مجوزهای فروشگاه
    /// </summary>
    public class updateStoreCertificateModel
    {
        public long id { get; set; }
        public string title { get; set; }
        public string dsc { get; set; }
        public int fk_status_id { get; set; }
        public string status_dsc { get; set; }
        public List<DocumentItemTab> documents { get; set; }
    }
    public class highlightVitrinStore
    {
        public long id { get; set; }
        public string title { get; set; }
        public long? itemId { get; set; }
        public long? itemGrp { get; set; }
        public string thumbImage { get; set; }
        public short type { get; set; }
    }
    /// <summary>
    /// مدل فروشگاه
    /// </summary>
    public class storeBindingModel
    {
       

        /// <summary>
        /// کد فروشگاه
        /// </summary>
        public long storeId { get; set; }

        /// <summary>
        /// عنوان فروشگاه
        /// </summary>
        public string title { get; set; }

        /// <summary>
        /// شناسه رشته ای یکتای فروشگاه
        /// این شناسه توسط سازنده (مدیر فروشگاه) تعیین می شود و یکتا بودن آن در زمان ثبت توسط سرور بررسی شده و خطای مناسب با تکراری بودن آن صادر می گردد
        /// </summary>
        public string id_str { get; set; }

        /// <summary>
        /// شماره موبایل مدیر فروشگاه
        /// </summary>
        public string storeAdminMobile { get; set; }
        /// <summary>
        /// ایمیل فروشگاه
        /// </summary>
        public string email { get; set; }
        /// <summary>
        /// درباره فروشگاه
        /// </summary>
        public string description { get; set; }
        /// <summary>
        /// کلمات کلیدی مرتبط با فروشگاه
        /// هرکلمه با یک ; جدا می شود
        /// </summary>
        public string keyWords { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public string description_second { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string title_second { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public bool verifiedAsOriginal { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public TimeSpan shiftStartTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public TimeSpan shiftEndTime { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int? fk_status_shiftStatus { get; set; }
        public string fk_status_shiftStatus_dsc { get; set; }
        /// <summary>
        /// امتیاز فروشگاه
        /// </summary>
        public decimal score { get; set; }
        /// <summary>
        /// بولین تاییدیه سفارش قبل از پرداخت
        /// </summary>
        public bool ordersNeedConfimBeforePayment { get; set; }
        /// <summary>
        /// بولین فقط مشتریان فروشگاه میتونند اوردر بدن
        /// </summary>
        public bool onlyCustomersAreAbleToSetOrder { get; set; }
        /// <summary>
        /// بولین فقط مشتریان فروشگاه میتونند کالاها رو ببینن
        /// </summary>
        public bool onlyCustomersAreAbleToSeeItems { get; set; }
        /// <summary>
        /// بولین نیاز به تایید شدن مشتری هنگام جوین شدن به فروشگاه
        /// </summary>
        public bool customerJoinNeedsConfirm { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public bool hasDelivery { get; set; }
        /// <summary>
        /// مبلغ مالیات
        /// </summary>
        public decimal taxRate { get; set; }
        /// <summary>
        /// مالیات روی مبلغ سفارش اثر بگذارد
        /// </summary>
        public bool taxIncludedInPrices { get; set; }
        /// <summary>
        /// ارزش افزوده روی کالا اثر گذاشته است
        /// </summary>
        public bool calculateTax { get; set; }
        /// <summary>
        /// بولین تعیین تنظیمات فعال بودن سفارش گیری در هنگام بسته بودن فروشگاه
        /// </summary>
        public bool canOrderWhenClose { get; set; }
        /// <summary>
        /// شماره حساب فروشگاه - مربوط به درگاه
        /// </summary>
        public string account { get; set; }
        /// <summary>
        /// تعداد فالورها
        /// </summary>
        public string followers { get; set; }
        /// <summary>
        /// وضعیت اعلان های فروشگاه برای کاربر فراخوانده سرویس
        /// </summary>
        public bool notification { get; set; }
        /// <summary>
        /// مشخص کننده ساعت کاری فروشگاه در روز جاری
        /// </summary>
        public string storeActiveCurrentDay { get; set; }
        /// <summary>
        /// شناسه تصویر لوگو پنل - اختیاری
        /// </summary>
        public Guid docId { get; set; }
        /// <summary>
        /// موقعیت فروشگاه
        /// </summary>
        public locationModel location { get; set; }
        /// <summary>
        /// تنظیمات زبان دوم فروشگاه
        /// </summary>
        public secondLanguageSetting secondLanSetting { get; set; }
        /// <summary>
        /// شناسه و عنوان شهر
        /// </summary>
        public IdTitleValue<int> city { get; set; }
        /// <summary>
        /// شناسه و عنوان استان
        /// </summary>
        public IdTitleValue<int> state { get; set; }
        /// <summary>
        /// شناسه و عنوان کشور
        /// </summary>
        public IdTitleValue<int> country { get; set; }
        /// <summary>
        /// وضعیت فروشگاه
        /// </summary>
        public IdTitleValue<int> status { get; set; }
        /// <summary>
        /// شناسه دسته بندی فروشگاه
        /// </summary>
        public IdTitleValue<int?> category { get; set; }
        /// <summary>
        /// شناسه نوع فروشگاه
        /// </summary>
        public IdTitleValue<int> storeTyp { get; set; }
        /// <summary>
        /// نوع شخصیت فروشگاه
        /// 1: haghighi , 2:hoghooghi, 3 sazman
        /// </summary>
        public IdTitleValue<int?> storePersonalityType { get; set; }
        /// <summary>
        /// لیست دسته بندی های پنل فروشگاه
        /// </summary>
        public List<IdTitleValue<long>> storeItemGrpPanelCategories { get; set; }
        ///// <summary>
        ///// لیست گروه کالا و خدمات قابل ارایه فروشگاه
        ///// </summary>
        //public List<IdTitleValue<long>> storeItemGrpItemGrpAndServices { get; set; }

        /// <summary>
        /// بانک مربوط به شماره حساب
        /// </summary>
        public IdTitleValue<int> bank { get; set; }
        /// <summary>
        /// وضعیت درگاه پرداخت آنلاین فروشگاه 
        /// وضعیت ها : 
        /// 12 : درخواست قبلا ثبت شده و در دست بررسی قرار دارد
        /// 13 : فعال
        /// 14 : غیر فعال
        /// </summary>
        public IdTitleValue<int> onlinePaymentGetway { get; set; }
        /// <summary>
        /// وضعیت فعال سازی پرداخت امن فروشگاه
        /// وضعیت ها : 
        /// 12 : درخواست قبلا ثبت شده و در دست بررسی قرار دارد
        /// 13 : فعال
        /// 14 : غیر فعال
        /// </summary>
        public IdTitleValue<int> securePayment { get; set; }
        /// <summary>
        /// لیست شماره های تماس
        /// اولین آیتم شماره پیشفرض باشد
        /// </summary>
        public List<Phone> phoneNos { get; set; }
        /// <summary>
        /// لیست شناسه تخصص ها/حوزه های فعالیت فروشگاه
        /// </summary>
        public List<IdTitleValue<int>> expertises { get; set; }
        /// <summary>
        /// شبکه های اجتماعی فروشگاه
        /// </summary>
        public List<storeSocialNetworkModel> socialNetwork { get; set; }

        /// <summary>
        /// لیستی از گروه های کالایی موجود در فروشگاه
        /// </summary>
        public List<storeItemGrpModel> itemGroupList { get; set; }

        /// <summary>
        /// مجوزهای فروشگاه
        /// </summary>
        public List<updateStoreCertificateModel> certificates { get; set; }
        ///// <summary>
        ///// کد وضعیت عوضیت کاربر جاری در فروشگاه
        ///// در صورت نال بودن کاربر عضو فروشگاه نمی باشد
        ///// </summary>
        //public int? cstmrJoinStatus { get; set; }
        ///// <summary>
        ///// شرح وضعیت عوضیت کاربر جاری در فروشگاه
        ///// در صورت نال بودن کاربر عضو فروشگاه نمی باشد
        ///// </summary>
        //public string cstmrJoinStatus_dsc { get; set; }

        /// <summary>
        /// کد وضعیت عوضیت کاربر جاری در فروشگاه
        /// در صورت نال بودن کاربر عضو فروشگاه نمی باشد
        /// </summary>
        public IdTitleValue<int?> cstmrJoinStatus { get; set; }
        public List<DocumentItemTab> storeDocuments { get; set; }
        public List<CustomCategoryModel> storeCustomCategoryList { get; set; }
        public DocumentItemTab storeLogo { get; set; }
        public List<categoryHeader> categoryHeaders { get; set; }
        public List<highlightVitrinStore> highlightVitrinList { get; set; }
        public string storeAbout_dsc { get; set; }
        public long conversationId { get; set; }
        public bool? hasSchedule { get; internal set; }
        public string todaySchedule { get; internal set; }
        public bool? currentShiftStatus { get; internal set; }
        /// <summary>
        /// این فروشگاه توسط کاربر فراخواننده قبلا گزارش شده است؟
        /// </summary>
        public bool? reportedByCaller;
    }
    /// <summary>
    /// مدل سرویس فون
    /// </summary>
    public class Phone
    {
        public string phone { get; set; }
        public bool isDefault { get; set; }
    }
    /// <summary>
    /// مدل گروه های کالایی فروشکاه
    /// </summary>
    public class storeItemGrpModel
    {
        public long itemGrpId { get; set; }
        public string itemGrpTitle { get; set; }
        public string itemGrpImage { get; set; }
        public string itemGrpthumbImage { get; set; }
    }
    /// <summary>
    /// مدل موقعیت
    /// </summary>
    public class locationModel
    {
        /// <summary>
        /// شناسه کشور
        /// </summary>
        public int country_id { get; set; }
        /// <summary>
        /// شناسه استان
        /// </summary>
        public int state_id { get; set; }
        /// <summary>
        /// شناسه شهر
        /// </summary>
        public int city_id { get; set; }
        public string cityTitle { get; set; }
        /// <summary>
        /// آدرس کامل
        /// </summary>
        public string address_full { get; set; }
        /// <summary>
        /// طول جغرافیایی
        /// </summary>
        public float lat { get; set; }
        /// <summary>
        /// عرض جغرافیایی
        /// </summary>
        public float lng { get; set; }
        /// <summary>
        /// آدرس گوگل
        /// </summary>
        public string address { get; set; }
    }
    /// <summary>
    /// مدل واحد پولی
    /// </summary>
    public class currencyModel
    {
        /// <summary>
        /// ای دی ارز
        /// </summary>
        public int id { get; set; }
        /// <summary>
        /// عنوان ارز
        /// </summary>
        public string title { get; set; }
        /// <summary>
        /// سیمبل ارز
        /// </summary>
        public string symbol { get; set; }
    }
    /// <summary>
    /// مدل خروجی سرویس دریافت لیستی از فروشگاه های مرتبط با کاربر
    /// </summary>
    public class UserRelatedStoreModel
    {
        /// <summary>
        /// شناسه فروشگاه
        /// </summary>
        public long storeId { get; set; }
        /// <summary>
        /// عنوان فروشگاه 
        /// </summary>
        public string title { get; set; }
        /// <summary>
        /// سمت کاربر در فروشگاه
        /// </summary>
        public string staffTitle { get; set; }
        public long staffId { get; set; }
        /// <summary>
        /// نام و نام خانوادگی
        /// </summary>
        public string userName { get; set; }
        /// <summary>
        /// تعداد پیام های خوانده نشده شخص
        /// </summary>
        public int unReadMessageCount { get; set; }
        /// <summary>
        /// تعداد سفارش های جدید ثبت شده بدون اقدام
        /// </summary>
        public int newOrderCount { get; set; }
        /// <summary>
        /// وضعیت فروشگاه
        /// </summary>
        public int statusStore { get; set; }
        /// <summary>
        /// شرح وضعیت فروشگاه
        /// </summary>
        public string statusStore_dsc { get; set; }
        /// <summary>
        /// کد وضعیت فروشگاه
        /// </summary>
        public int statusId { get; set; }
        /// <summary>
        /// شماره تماس 
        /// </summary>
        public string mobile { get; set; }
        public int autoSyncTimePeriod { get; set; }

    }
    /// <summary>
    /// مدل تعریف زمانبندی فروشگاه
    /// </summary>
    public class StoreScheduleModel
    {
        public long id { get; set; }
        public short? dayOfWeek { get; set; }
        public TimeSpan isActiveFrom { get; set; }
        public TimeSpan activeUntil { get; set; }
    }
    /// <summary>
    /// شبکه های اجتماعی فروشگاه
    /// </summary>
    public class storeSocialNetworkModel
    {
        /// <summary>
        /// نوع شبکه اجتماعی
        /// </summary>
        public string socialNetworkType { get; set; }
        /// <summary>
        /// اکانت 
        /// </summary>
        public string socialNetworkAccount { get; set; }
    }
    /// <summary>
    /// مدل دریافت لیست کالا(پرسنل) فروشگاه
    /// </summary>
    public class EmployeeStoreModel : searchParameterModel
    {
        /// <summary>
        /// 1 =  دارای نظرسنجی
        /// 2 = فاقد نظرسنجی
        /// </summary>
        public short state { get; set; }
        /// <summary>
        /// نحوه مرتب سازی
        /// 1 = کمترین نمره ارزیابی
        /// 2 = بیشترین نمره ارزیابی
        /// 3 = کمترین رای ارزیابی
        /// 4 = بیشترین رای ارزیابی
        /// 5 = کمترین امتیاز نظرسنجی
        /// 6 = بیشترین امتیاز نظرسنجی
        /// 7 = کمترین رای نظرسنجی
        /// 8 = بیشترین رای نظرسنجی
        /// 9 = جدیدترین رای نظرسنجی
        /// 10 = نزدیک ترین
        /// 11 = دورترین
        /// </summary>
        public short orderType { get; set; }
        /// <summary>
        /// کد پرسنل
        /// </summary>
        public long ItemId { get; set; }
        /// <summary>
        /// شناسه سازمانی
        /// </summary>
        public string loacalBarcode { get; set; }
        /// <summary>
        /// نام و نام خانوادگی
        /// </summary>
        public string itemTitle { get; set; }
        /// <summary>
        /// شناسه یکتا
        /// </summary>
        public string uniqueBarcode { get; set; }
        /// <summary>
        /// قابل مشاهده هست یا خیر
        /// </summary>
        public bool dontShowinginStoreItem { get; set; }
        /// <summary>
        /// عنوان فعالیت
        /// </summary>
        public string technicalTitle { get; set; }
        public IdTitleValue<long> itemGrp { get; set; }
        public List<IdTitleValue<long>> category { get; set; }
        public string unitName { get; set; }
        public int cntOpinion { get; set; }
        public decimal avgOpinion { get; set; }
        public int memberEval { get; set; }
        public decimal rateEval { get; set; }
        public string startOpinion { get; set; }
        public string endOpinion { get; set; }
        public bool showOpinionResult { get; set; }
        public bool hasOpinion { get; set; }
        public string orginalImage { get; set; }
        public string thumbnailImage { get; set; }
        public long opinionPollId { get; set; }
        /// <summary>
        /// فیلتر مربوط به وضعیت نمایش
        /// 1 : نمایش
        /// 2 : عدم نمایش
        /// 0 : همه
        /// </summary>
        public short showInStoreStatus { get; set; }
        /// <summary>
        /// فیلتر مربوط به وضعیت نظرسنجی
        /// 1 : فعال
        /// 2 : غیرفعال
        /// 0 : همه
        /// </summary>
        public short pollStatus { get; set; }
        /// <summary>
        /// فیلتر مربوط به جنسیت
        /// 1: خانم
        /// 2 : آقا
        /// 0 : همه
        /// </summary>
        public short sexStatus { get; set; }
        /// <summary>
        /// فلگ جستجوی پرسنل بر اساس فقط بارکد
        /// </summary>
        public bool findJustBarcode { get; set; }
        public bool isLocked { get; set; }
        public int commentWaitForConfirmCnt { get; set; }
    }



    /// <summary>
    /// مدل دریافت لیست کالاهای یک فروشگاه
    /// </summary>
    public class ItemsOfStoreModel : searchParameterModel
    {
        /// <summary>
        /// کد فروشگاه
        /// </summary>
        public long storeId { get; set; }
        /// <summary>
        /// 0 =  به منزله همه کالا ها (بدون در نظر گرفتن وضعیت موجودی و نقطه سفارشش)
        /// 1 = به منزله کلیه کالا هایی که موجودی دارند
        /// 2 = به منزله کلیه کالا هایی که موجودی آنها صفر است
        /// 3 = به منزله کلیه کالا هایی که برای آنها نقطه سفارش مشخص شده است و موجودی آنها کمتر یا مساوی نقطه سفارش آنها می باشد
        /// </summary>
        public short state { get; set; }
        /// <summary>
        /// نحوه مرتب سازی
        /// 1 = جدیدترین
        /// 2 = کمترین قیمت
        /// 3 = بیشترین قیمت
        /// 4 = کمترین تخفیف
        /// 5 = بیشترین تخفیف
        /// 6 = کمترین موجودی
        /// 7 = بیشترین موجودی
        /// 8 = نزدیک ترین به نقطه سفارش
        /// 9 = بارکد
        /// 10 = شناسه رسمی
        /// 11 = گروه
        /// </summary>
        public short orderType { get; set; }
        /// <summary>
        /// کد کالا
        /// </summary>
        public long ItemId { get; set; }
        /// <summary>
        /// شناسه بارکد محلی
        /// </summary>
        public string loacalBarcode { get; set; }
        /// <summary>
        /// موجودی کالا
        /// </summary>
        public decimal qty { get; set; }
        /// <summary>
        /// نقطه سفارش
        /// </summary>
        public decimal orderPoint { get; set; }
        /// <summary>
        /// عنوان کالا
        /// </summary>
        public string itemTitle { get; set; }
        /// <summary>
        /// فلگ جهت نمایش فقط کالاهای فعال
        /// </summary>
        public bool activeUnit { get; set; } = false;
        /// <summary>
        /// بارکد یکتای کالا
        /// </summary>
        public string uniqueBarcode { get; set; }
        /// <summary>
        /// درصد تخفیف
        /// </summary>
        public string discountPercent_dsc { get; set; }
        /// <summary>
        /// مبلغ اصلی کالا
        /// </summary>
        public string price_dsc { get; set; }
        /// <summary>
        /// مبلغ کالا بعد از اعمال تخفیف
        /// </summary>
        public string priceAfterDiscount_dsc { get; set; }
        /// <summary>
        /// کالا شامل مالیات هست یا خیر
        /// </summary>
        public bool includedTax { get; set; }
        /// <summary>
        /// کالا قابل مشاهده هست یا خیر
        /// </summary>
        public bool dontShowinginStoreItem { get; set; }
        /// <summary>
        /// کالا برای فروش هست یا خیر
        /// </summary>
        public bool isNotForSelling { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string qty_dsc { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string orderPoint_dsc { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string orginalImage { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string thumbnailImage { get; set; }
        public string technicalTitle { get; set; }
        public string itemGrp_dsc { get; set; }
        public long itemGrpId { get; set; }
        public bool isTemplate { get; set; }
        /// <summary>
        /// وضعیت نمایش در لیست کالا
        /// 0 = عدم نمایش
        /// 1 = نمایش
        /// 2 = همه
        /// </summary>
        public short? showItemInStore { get; set; }
        /// <summary>
        /// وضعیت فروش کالا
        /// 0 = غیرقابل فروش
        /// 1 = قابل فروش
        /// 2 = همه
        /// </summary>
        public short? sellItemStatus { get; set; }
        /// <summary>
        /// وضعیت ارزش افزوده
        /// 0 = ندارد
        /// 1 = دارد
        /// 2 = همه
        /// </summary>
        public short? taxItemStatus { get; set; }
        /// <summary>
        /// وضعیت تخفیف
        /// 0 = ندارد
        /// 1 = دارد
        /// 2 = همه
        /// </summary>
        public short? discountItemStatus { get; set; }
        /// <summary>
        /// نوع کالا
        /// 0 = مرجع
        /// 1 = شخصی
        /// 2 = همه
        /// </summary>
        public short? typeItem { get; set; }
        /// <summary>
        /// شناسه نظرسنجی فعال کالا
        /// </summary>
        public long? activeOpinionpollId { get; set; }
        public IdTitleValue<int> itemStatus { get; set; }
        public string barcode { get; set; }
        public string unit_dsc { get; set; }
        public bool isEditable { get; set; }
        public long catId { get; set; }
        public long pollId { get; set; }
        public bool isLocked { get; set; }
        public int commentWaitForConfirmCnt { get; set; }
    }
    /// <summary>
    /// مدل سرویس جستجوی فروشگاه
    /// </summary>
    public class searchStoreModel : searchParameterModel
    {
        public float lat { get; set; }
        public float lng { get; set; }
        public float curLat { get; set; }
        public float curLng { get; set; }
        public long? itemGrpId { get; set; }
        public bool? storeJustOpenState { get; set; }
        public decimal? maxDistanceToStore { get; set; }
        public bool? sortByDistance { get; set; }
        public bool? sortByStoreState { get; set; }
        public bool? sortByAlphabetic { get; set; }
        public int cityId { get; set; }
        public int typeStore { get; set; }
    }
    /// <summary>
    /// مدل خروجی جستجوی فروشگاه
    /// </summary>
    public class searchStoreResult
    {
        /// <summary>
        /// شناسه فروشگاه
        /// </summary>
        public long id { get; set; }
        /// <summary>
        /// عنوان فروشگاه
        /// </summary>
        public string title { get; set; }
        /// <summary>
        /// کد وضعیت فروشگاه
        /// </summary>
        public int stId { get; set; }
        /// <summary>
        /// شرح وضعیت فروشگاه
        /// </summary>
        public string stDesc { get; set; }

        /// <summary>
        /// فاصله تا فروشگاه
        /// </summary>
        public string dist { get; set; }
        /// <summary>
        /// امتیاز فروشگاه
        /// </summary>
        public decimal score { get; set; }
        /// <summary>
        /// کلمات کلیدی فروشگاه
        /// </summary>
        public string keywords { get; set; }
        /// <summary>
        /// لیست حوزه های فعالیت فروشگاه
        /// </summary>
        public List<typStoreExpertiseModel> exper { get; set; }
        /// <summary>
        /// مشخصات جغرافیایی فروشگاه
        /// </summary>
        public locationModel loc { get; set; }

        /// <summary>
        /// فالو شدن توسط کاربر
        /// </summary>
        public bool areYoufollow { get; set; }
        /// <summary>
        /// تعداد فالورهای فروشگاه
        /// </summary>
        public int storeFollowerCount { get; set; }
        public DocumentItemTab storeDefaulDocumnet { get; set; }
        public List<DocumentItemTab> storeDocumnetList { get; set; }
        public DocumentItemTab storeLogo { get; set; }
        public bool onlineGetway { get; set; }
        public bool securePayment { get; set; }
        public bool hasDelivery { get; set; }
        public string opentoday { get; set; }
        public bool openNow { get; set; }
        public string panelCategory { get; set; }
    }
    public class UpdateShiftStoreStatusModel
    {
        public long storeId { get; set; }
        public short shiftStatus { get; set; }
    }
    public class GetItemInfoModel : searchParameterModel
    {
        public long? storeId { get; set; }
        public long itemId { get; set; }
    }
    /// <summary>
    /// مدل ثبت نظر در باره کالا یا فروشگاه
    /// </summary>
    public class AddOpinionModel
    {
        public decimal rate { get; set; }
        /// <summary>
        /// میتواند نال باشد
        /// </summary>
        public long? itemId { get; set; }
        /// <summary>
        /// می تواند نال باشد
        /// </summary>
        public long? storeId { get; set; }
        public string opinion { get; set; }
        public string saveIp { get; set; }
    }
    public class IdTitleValue<T>
    {
        public T id { get; set; }
        public string title { get; set; }
    }
    public class IntTitleValue
    {
        public int? id { get; set; }
        public string title { get; set; }
    }
    public class StoreCertificateModel
    {
        public long id { get; set; }
        public string title { get; set; }
        public string dsc { get; set; }
        public List<DocumentItemTab> documentList { get; set; }
    }
    public class DeliveryTypeModel
    {
        /// <summary>
        /// شناسه طریقه ارسال -  هنگام ویرایش استفاده می شود
        /// </summary>
        public long id { get; set; }
        /// <summary>
        /// عنوان نباید تکراری باشد
        /// </summary>
        public string title { get; set; }
        /// <summary>
        ///خالی نباشد هزینه ارسال
        /// </summary>
        public decimal cost { get; set; }
        /// <summary>
        /// هزینه ارسال روی فاکتور تاثیر بگذارد - خالی نباشد
        /// </summary>
        public bool effectiveDeliveryCostOnInvoce { get; set; }
        /// <summary>
        /// حداکثر فاصله پوشش پیک - خالی نباشد
        /// </summary>
        public int maxSupportedDistancForDelivery { get; set; }
        /// <summary>
        /// حداقل مبلغ برای فعال شدن پیک - خالی نباشد
        /// </summary>
        public decimal minPriceForActiveDeliveryType { get; set; }
        /// <summary>
        /// فعال بودن - میتواند نال باشد
        /// </summary>
        public bool isActive { get; set; }


    }
    public class categoryHeader
    {
        public long categoryId { get; set; }
        public string categoryTitle { get; set; }
        public short categoryType { get; set; }

    }


    #endregion


}
