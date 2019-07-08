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
    /// ای پی آی مربوط به کالا
    /// </summary>
    [RoutePrefix("Item")]
    public class ItemController : AdvancedApiController
    {

        /// <summary>
        /// سرویس دریافت لیست تمامی آیتم های ثبت شده در فروشگاه بر اساس نوع
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getItemList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getItemList(searchParameterModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);


            using (var repo = new Repo(this, "SP_getAllStoreItems", "ItemController_getAllStoreItems", initAsReader: true, checkAccess: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@search", model.search.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@type", model.type);
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i =>
                new
                {
                    itemId = Convert.ToInt64(i.Field<object>("pk_fk_item_id")),
                    title = Convert.ToString(i.Field<object>("title")),
                    group = new IdTitleValue<long> { id = Convert.ToInt64(i.Field<object>("grpId")), title = Convert.ToString(i.Field<object>("grpTitle")) },
                    defualtPicture = new DocumentItemTab { downloadLink = Convert.ToString(i.Field<object>("completeLink")), thumbImageUrl = Convert.ToString(i.Field<object>("thumbcompeleteLink")) },
                    type = Convert.ToString(i.Field<object>("itemType"))
                }).ToList()
                    );
            }

        }
        /// <summary>
        /// سرویس دریافت لیست کالاها با  بارکد مشابه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getSameBarcode")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getSameBarcode(BarcodeModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);


            using (var repo = new Repo(this, "SP_barcodeValidation", "ItemController_ValidationBarcode", initAsReader: true, checkAccess: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();

                repo.cmd.Parameters.AddWithValue("@barcode", model.Barcode.getDbValue());
                repo.cmd.Parameters.AddWithValue("@checkLocalBarcode", model.CheckLocalBarcode);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@type", model.type);
                repo.cmd.Parameters.AddWithValue("@searchInMyItems", model.searchInMyItems);
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i =>
                new
                {
                    grouptitle = Convert.ToString(i.Field<object>("grouptitle")),
                    itemId = Convert.ToInt64(i.Field<object>("id")),
                    title = Convert.ToString(i.Field<object>("title")),
                    completeLink = Convert.ToString(i.Field<object>("completeLink")),
                    thumbcompeleteLink = Convert.ToString(i.Field<object>("thumbcompeleteLink")),
                    technicalTitle = Convert.ToString(i.Field<object>("technicalTitle")),
                    price = Convert.ToString(i.Field<object>("price")),
                    isTemplate = Convert.ToBoolean(i.Field<object>("isTemplate") is DBNull ? 0 : i.Field<object>("isTemplate")),
                    matchWithLocalBarcode = Convert.ToBoolean(i.Field<object>("matchWithLocalBarcode")),
                    editable = Convert.ToBoolean(i.Field<object>("editable") is DBNull ? 0 : i.Field<object>("editable"))

                }).ToList()
                    );

            }

        }
        /// <summary>
        /// ثبت کالای شخصی مرحله 2
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addCustomItemLevel2")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addCustomItemLevel2(CustomItemModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addCustomItemLevel2", "ItemController_addCustomItemLevel2"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                //DataTable waranty = GetWarantyDataTable(model.warantiesItem);
                //DataTable technicalInfo = ClassToDatatableConvertor.CreateDataTable(model.techInfoItem);
                //DataTable docInfo = ClassToDatatableConvertor.CreateDataTable(model.docInfoItem);
                DataTable color = ClassToDatatableConvertor.CreateDataTable(model.itemColor);
                DataTable size = ClassToDatatableConvertor.CreateDataTable(model.itemSize);
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@hasWaranty", model.hasWaranty);
                repo.cmd.Parameters.AddWithValue("@purcheseWithoutWaranty", model.purcheseWithoutWaranty);
                repo.cmd.Parameters.AddWithValue("@unitId", model.sohInfoItem.unit.id);
                repo.cmd.Parameters.AddWithValue("@quantity", model.sohInfoItem.quantity);
                repo.cmd.Parameters.AddWithValue("@orderPoint", model.sohInfoItem.orderPoint);
                repo.cmd.Parameters.AddWithValue("@prepaymentPercentage", model.sohInfoItem.prepaymentPercentage);
                repo.cmd.Parameters.AddWithValue("@penaltyCancellationPercentage", model.sohInfoItem.penaltyCancellationPercentage);
                repo.cmd.Parameters.AddWithValue("@price", model.sohInfoItem.price);
                repo.cmd.Parameters.AddWithValue("@periodicValidDayOrder", model.sohInfoItem.periodicValidDayOrder);
                repo.cmd.Parameters.AddWithValue("@discountPerPurcheseNumeric", model.sohInfoItem.discountPerPurcheseNumeric);
                repo.cmd.Parameters.AddWithValue("@discountPerPurchesePercently", model.sohInfoItem.discountPerPurchesePercently);
                repo.cmd.Parameters.AddWithValue("@notForSellingItem", model.sohInfoItem.notForSellingItem);
                repo.cmd.Parameters.AddWithValue("@includesTax", model.sohInfoItem.includesTax);
                repo.cmd.Parameters.AddWithValue("@countryId", model.basicItem.country.id);
                repo.cmd.Parameters.AddWithValue("@manufacturerCo", model.basicItem.manufacturerCo.getDbValue());
                repo.cmd.Parameters.AddWithValue("@importerCo", model.basicItem.importerCo.getDbValue());
                repo.cmd.Parameters.AddWithValue("@review", model.review.getDbValue());
                repo.cmd.Parameters.AddWithValue("@lat", model.commonItem.location.lat.dbNullCheckDouble());
                repo.cmd.Parameters.AddWithValue("@lng", model.commonItem.location.lng.dbNullCheckDouble());
                repo.cmd.Parameters.AddWithValue("@address", model.commonItem.location.address.dbNullCheckString());

                // var param1 = repo.cmd.Parameters.AddWithValue("@waranty", waranty);
                //var param2 = repo.cmd.Parameters.AddWithValue("@TechnicalInfoItem", technicalInfo);
                //var param3 = repo.cmd.Parameters.AddWithValue("@DocInfoItem", docInfo);
                var param4 = repo.cmd.Parameters.AddWithValue("@color", color);
                var param5 = repo.cmd.Parameters.AddWithValue("@size", size);
                //param1.SqlDbType = SqlDbType.Structured;
                //param2.SqlDbType = SqlDbType.Structured;
                //param3.SqlDbType = SqlDbType.Structured;
                param4.SqlDbType = SqlDbType.Structured;
                param5.SqlDbType = SqlDbType.Structured;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { repo.rMsg });
            }

        }
        /// <summary>
        /// سرویس ثبت مشخصه فنی کالای شخصی
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addItemTechnicalInfo")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addItemTechnicalInfo(ItemTechnicalInfoModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addItemTechnicalInfo", "ItemController_addItemTechnicalInfo", checkAccess: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();

                DataTable technicalInfo = ClassToDatatableConvertor.CreateDataTable(model.itemTechnicalInfo);
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId);
                var param2 = repo.cmd.Parameters.AddWithValue("@TechnicalInfoItem", technicalInfo);
                param2.SqlDbType = SqlDbType.Structured;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { repo.rMsg });
            }

        }
        /// <summary>
        /// سرویس حذف مشخصات فنی یک کالا
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("deleteItemTechnicalInfo")]
        [Exception]
        [HttpPost]
        public IHttpActionResult deleteItemTechnicalInfo(ItemTechnicalInfoModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_deleteItemTechnicalInfo", "ItemController_deleteItemTechnicalInfo", checkAccess: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();
                DataTable technicalInfo = ClassToDatatableConvertor.CreateDataTable(model.itemTechnicalInfo);
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId);
                var param2 = repo.cmd.Parameters.AddWithValue("@TechnicalInfoItem", technicalInfo);
                param2.SqlDbType = SqlDbType.Structured;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { repo.rMsg });
            }

        }

        /// <summary>
        /// سرویس ثبت کالای شخصی
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("add")]
        [Exception]
        [HttpPost]

        public IHttpActionResult add(CommonTabItem model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);

            long itemId = 0;
            using (var repo = new Repo(this, "SP_addCustomItem", "ItemController_add", checkAccess: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();

                var outParam = repo.cmd.Parameters.Add("@itemId", SqlDbType.BigInt);
                outParam.Direction = ParameterDirection.Output;
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@itemTitle", model.itemTitle.getDbValue());
                repo.cmd.Parameters.AddWithValue("@technicalItem", model.technicalItem.getDbValue());
                repo.cmd.Parameters.AddWithValue("@itemGroup", model.itemGroup.id);
                repo.cmd.Parameters.AddWithValue("@barcode", model.barcode.getDbValue());
                repo.cmd.Parameters.AddWithValue("@localBarcode", model.localBarcode.getDbValue());
                repo.cmd.Parameters.AddWithValue("@dontShowingStoreItems", model.dontShowingStoreItems);
                repo.cmd.Parameters.AddWithValue("@deliveriable", model.deliveriable);
                repo.cmd.Parameters.AddWithValue("@sex", model.sex);
                repo.cmd.Parameters.AddWithValue("@fk_state", model.state != null ? model.state.id.dbNullCheckInt() : null);
                repo.cmd.Parameters.AddWithValue("@fk_city_id", model.state != null ? model.city.id.dbNullCheckInt() : null);
                repo.cmd.Parameters.AddWithValue("@village", model.village.getDbValue());
                repo.cmd.Parameters.AddWithValue("@unitName", model.unitName.getDbValue());
                repo.cmd.Parameters.AddWithValue("@dontShowUniqBarcode", model.dontShowUniqBarcode);
                repo.cmd.Parameters.AddWithValue("@displayMode", model.displayMode.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@fk_ObjectGrpId", model.fk_ObjectGrpId != null ? model.fk_ObjectGrpId.id.dbNullCheckLong() : null);
                repo.cmd.Parameters.AddWithValue("@itemType", model.itemType.dbNullCheckShort());
                repo.cmd.Parameters.AddWithValue("@lat", model.location != null ? model.location.lat.dbNullCheckDouble() : null);
                repo.cmd.Parameters.AddWithValue("@lng", model.location != null ? model.location.lng.dbNullCheckDouble() : null);
                repo.cmd.Parameters.AddWithValue("@address", model.location != null ? model.location.address.dbNullCheckString() : null);
                repo.cmd.Parameters.AddWithValue("@findJustBarcode", model.findJustBarcode.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@commentCntPerUser", model.commetnCntPerUser.dbNullCheckInt());
                repo.cmd.Parameters.AddWithValue("@commentCntPerDayPerUser", model.commentCntPerDayPerUser.dbNullCheckInt());
                repo.cmd.Parameters.AddWithValue("@fk_education_id", model.education == null ? null : model.education.id.dbNullCheckInt());
                repo.cmd.Parameters.AddWithValue("@isLocked", model.isLocked.dbNullCheckBoolean());
                var param = repo.cmd.Parameters.AddWithValue("@storeCustomCategory", model.storeCustomCategory == null ? null : ClassToDatatableConvertor.CreateDataTable(model.storeCustomCategory));
                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                itemId = (long)outParam.Value;
            }
            return Ok(new { itemId = itemId });
        }
        /// <summary>
        /// سرویس افزودن وارانتی 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addWarranty")]
        [Exception]
        [HttpPost]

        public IHttpActionResult addWarranty(WarrantyItemModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);

            using (var repo = new Repo(this, "SP_addWarranty", "ItemController_addWarranty", checkAccess: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                var param = repo.cmd.Parameters.AddWithValue("@warranty", ClassToDatatableConvertor.CreateDataTable(model.warranties));
                var out_ = repo.cmd.Parameters.Add("@warrantyId", SqlDbType.BigInt);
                out_.Direction = ParameterDirection.Output;
                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg, id = Convert.ToInt64(out_.Value) });
            }

        }
        /// <summary>
        /// سرویس افزودن وارانتی 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addWarranty_V2")]
        [Exception]
        [HttpPost]

        public IHttpActionResult addWarranty_V2(addWarantinBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);

            using (var repo = new Repo(this, "SP_addWarranty", "ItemController_addWarranty", checkAccess: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();
                List<WarantyItemTab> list = new List<WarantyItemTab> { model.warranty };
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                var param = repo.cmd.Parameters.AddWithValue("@warranty", ClassToDatatableConvertor.CreateDataTable(list));
                var out_ = repo.cmd.Parameters.Add("@warrantyId", SqlDbType.BigInt);
                out_.Direction = ParameterDirection.Output;
                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg, id = Convert.ToInt64(out_.Value) });
            }

        }
        /// <summary>
        /// سرویس ویرایش وارانتی
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("updateWarranty")]
        [Exception]
        [HttpPost]

        public IHttpActionResult updateWarranty(WarrantyItemModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);

            using (var repo = new Repo(this, "SP_updateWarranty", "ItemController_updateWarranty", checkAccess: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();

                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                var param = repo.cmd.Parameters.AddWithValue("@warranty", ClassToDatatableConvertor.CreateDataTable(model.warranties));
                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }

        }
        /// <summary>
        /// سرویس حذف وارانتی
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("deleteWarranty")]
        [Exception]
        [HttpPost]

        public IHttpActionResult deleteWarranty(WarrantyItemModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);

            using (var repo = new Repo(this, "SP_deleteWarranty", "ItemController_deleteWarranty", checkAccess: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();
                var param = repo.cmd.Parameters.AddWithValue("@warranty", ClassToDatatableConvertor.CreateDataTable(model.warranties));
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);

                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }

        }
        /// <summary>
        /// سرویس لیست وارانتی
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getItemWarrantyList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getItemWarrantyList(WarrantyItemModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);

            using (var repo = new Repo(this, "SP_getItemWarrantyList", "ItemController_getItemWarrantyList", initAsReader: true, checkAccess: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();

                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteAdapter();
                return Ok(
                    repo.ds.Tables[0].AsEnumerable().Select(row => new WarantyItemTab
                    {
                        warrantyId = Convert.ToInt64(row.Field<object>("id")),
                        WarantyCo = Convert.ToString(row.Field<object>("WarrantyCo")),
                        WarantyPrice = Convert.ToDecimal(row.Field<object>("warrantyCost") is DBNull ? 0 : row.Field<object>("warrantyCost")),
                        WarantyPrice_dsc = Convert.ToString(row.Field<object>("WarantyPrice_dsc")),
                        durationdayWaranty = Convert.ToInt32(row.Field<object>("warrantyDays") is DBNull ? 0 : row.Field<object>("warrantyDays"))

                    }).ToList()
                    );
            }

        }
        /// <summary>
        /// سرویس ویرایش کالای شخصی
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("update")]
        [Exception]
        [HttpPost]
        public IHttpActionResult update(CustomItemModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updateCustomItem", "ItemController_update", checkAccess: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();

                DataTable customCategory = null;

                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@storeId", model.storeId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@hasWaranty", model.hasWaranty.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@purcheseWithoutWaranty", model.purcheseWithoutWaranty.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@review", model.review.getDbValue());

                if (model.commonItem != null)
                {
                    if (model.commonItem.storeCustomCategory == null)
                    {
                        model.commonItem.storeCustomCategory = new List<IdTitleValue<long?>>() { new IdTitleValue<long?> { id = 0 } };
                    }
                    customCategory = ClassToDatatableConvertor.CreateDataTable(model.commonItem.storeCustomCategory);
                    repo.cmd.Parameters.AddWithValue("@itemTitle", model.commonItem.itemTitle.getDbValue());
                    repo.cmd.Parameters.AddWithValue("@technicalItem", model.commonItem.technicalItem.getDbValue());
                    repo.cmd.Parameters.AddWithValue("@itemGroup", model.commonItem.itemGroup != null ? model.commonItem.itemGroup.id.dbNullCheckLong() : null);
                    repo.cmd.Parameters.AddWithValue("@barcode", model.commonItem.barcode.getDbValue());
                    repo.cmd.Parameters.AddWithValue("@localBarcode", model.commonItem.localBarcode.getDbValue());
                    repo.cmd.Parameters.AddWithValue("@dontShowingStoreItems", model.commonItem.dontShowingStoreItems.dbNullCheckBoolean());
                    repo.cmd.Parameters.AddWithValue("@deliveriable", model.commonItem.deliveriable.dbNullCheckBoolean());
                    repo.cmd.Parameters.AddWithValue("@sex", model.commonItem.sex.dbNullCheckBoolean());
                    repo.cmd.Parameters.AddWithValue("@fk_state", model.commonItem.state != null ? model.commonItem.state.id.dbNullCheckInt() : null);
                    repo.cmd.Parameters.AddWithValue("@fk_city_id", model.commonItem.city != null ? model.commonItem.city.id.dbNullCheckInt() : null);
                    repo.cmd.Parameters.AddWithValue("@village", model.commonItem.village.getDbValue());
                    repo.cmd.Parameters.AddWithValue("@unitName", model.commonItem.unitName.getDbValue());
                    repo.cmd.Parameters.AddWithValue("@dontShowUniqBarcode", model.commonItem.dontShowUniqBarcode.dbNullCheckBoolean());
                    repo.cmd.Parameters.AddWithValue("@displayMode", model.commonItem.displayMode.dbNullCheckBoolean());
                    repo.cmd.Parameters.AddWithValue("@itemType", model.commonItem.itemType.dbNullCheckShort());
                    repo.cmd.Parameters.AddWithValue("@lat", model.commonItem.location != null ? model.commonItem.location.lat.dbNullCheckDouble() : null);
                    repo.cmd.Parameters.AddWithValue("@lng", model.commonItem.location != null ? model.commonItem.location.lng.dbNullCheckDouble() : null);
                    repo.cmd.Parameters.AddWithValue("@address", model.commonItem.location != null ? model.commonItem.location.address.dbNullCheckString() : null);
                    repo.cmd.Parameters.AddWithValue("@findJustBarcode", model.commonItem.findJustBarcode.dbNullCheckBoolean());
                    repo.cmd.Parameters.AddWithValue("@commentCntPerDayPerUser", model.commonItem.commentCntPerDayPerUser.dbNullCheckInt());
                    repo.cmd.Parameters.AddWithValue("@commetnCntPerUser", model.commonItem.commetnCntPerUser.dbNullCheckInt());
                    repo.cmd.Parameters.AddWithValue("@fk_education_id", model.commonItem.education == null ? null : model.commonItem.education.id.dbNullCheckInt());
                    repo.cmd.Parameters.AddWithValue("@isLocked", model.commonItem.isLocked.dbNullCheckBoolean());
                }
                if (model.sohInfoItem != null)
                {
                    repo.cmd.Parameters.AddWithValue("@unitId", model.sohInfoItem.unit != null ? model.sohInfoItem.unit.id.dbNullCheckInt() : null);
                    repo.cmd.Parameters.AddWithValue("@quantity", model.sohInfoItem.quantity.dbNullCheckDecimal());
                    repo.cmd.Parameters.AddWithValue("@orderPoint", model.sohInfoItem.orderPoint.dbNullCheckDecimal());
                    repo.cmd.Parameters.AddWithValue("@prepaymentPercentage", model.sohInfoItem.prepaymentPercentage.dbNullCheckInt());
                    repo.cmd.Parameters.AddWithValue("@penaltyCancellationPercentage", model.sohInfoItem.penaltyCancellationPercentage.dbNullCheckInt());
                    repo.cmd.Parameters.AddWithValue("@price", model.sohInfoItem.price.dbNullCheckDecimal());
                    repo.cmd.Parameters.AddWithValue("@periodicValidDayOrder", model.sohInfoItem.periodicValidDayOrder.dbNullCheckInt());
                    repo.cmd.Parameters.AddWithValue("@discountPerPurcheseNumeric", model.sohInfoItem.discountPerPurcheseNumeric.dbNullCheckInt());
                    repo.cmd.Parameters.AddWithValue("@discountPerPurchesePercently", model.sohInfoItem.discountPerPurchesePercently.dbNullCheckDecimal());
                    repo.cmd.Parameters.AddWithValue("@notForSellingItem", model.sohInfoItem.notForSellingItem.dbNullCheckBoolean());
                    repo.cmd.Parameters.AddWithValue("@includesTax", model.sohInfoItem.includesTax.dbNullCheckBoolean());
                }
                if (model.basicItem != null)
                {
                    repo.cmd.Parameters.AddWithValue("@countryId", model.basicItem.country != null ? model.basicItem.country.id.dbNullCheckInt() : null);
                    repo.cmd.Parameters.AddWithValue("@manufacturerCo", model.basicItem.manufacturerCo.getDbValue());
                    repo.cmd.Parameters.AddWithValue("@importerCo", model.basicItem.importerCo.getDbValue());
                }
                DataTable color = ClassToDatatableConvertor.CreateDataTable(model.itemColor == null ? new List<ItemColorModel>() : model.itemColor);
                DataTable size = ClassToDatatableConvertor.CreateDataTable(model.itemSize == null ? new List<ItemSizeModel>() : model.itemSize);
                var param4 = repo.cmd.Parameters.AddWithValue("@color", model.itemColor != null ? color : null);
                var param5 = repo.cmd.Parameters.AddWithValue("@size", model.itemSize != null ? size : null);
                var param6 = repo.cmd.Parameters.AddWithValue("@storeCustomCategory", customCategory);
                param4.SqlDbType = SqlDbType.Structured;
                param5.SqlDbType = SqlDbType.Structured;
                param6.SqlDbType = SqlDbType.Structured;

                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new messageModel(repo.rMsg));
            }
            
        }

        /// <summary>
        /// سرویس ویرایش نقد و بررسی کالای شخصی
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("updateItemReview")]
        [Exception]
        [HttpPost]
        public IHttpActionResult updateItemReview(CustomItemModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updateItemReview", "ItemController_updateItemReview"/*, checkAccess: true)*/))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@review", model.review.getDbValue());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
           
        }
        /// <summary>
        /// سرویس دریافت نقد و بررسی کالای شخصی
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getItemReview")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getItemReview(CustomItemModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getItemReview", "ItemController_updateItemReview",initAsReader:true/*, checkAccess: true)*/))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.dbNullCheckLong());
                repo.ExecuteAdapter();

                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i => new { reviewAddress = Convert.ToString(i.Field<object>("review")) }).FirstOrDefault());
            }
        }
        private DataTable GetWarantyDataTable(List<WarantyItemTab> model)
        {
            DataTable waranty = new DataTable();
            DataRow row;
            waranty.Columns.Add("id");
            waranty.Columns.Add("WarantyCo");
            waranty.Columns.Add("warrantyDays");
            waranty.Columns.Add("warrantyCost");
            int id = 0;
            foreach (var item in model)
            {
                row = waranty.NewRow();
                row["id"] = id;
                row["WarantyCo"] = item.WarantyCo;
                row["warrantyDays"] = item.durationdayWaranty;
                row["warrantyCost"] = item.WarantyPrice;
                id++;
                waranty.Rows.Add(row);
            }
            return waranty;
        }
        /// <summary>
        /// سرویس دریافت لیست مشخصات فنی با ورودی شناسه گروه کالا
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getTechnicalInfoItemList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getTechnicalInfoItemList(LongKeyModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<TechnicalInfoItemTyp> result = new List<TechnicalInfoItemTyp>();
            using (var repo = new Repo(this, "SP_getTechnicalInfoListAboutItem", "ItemController_getTechnicalInfoItemList", initAsReader: true, checkAccess: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@itemGrpId", model.id);
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.ExecuteReader();
                while (repo.sdr.Read())
                {
                    TechnicalInfoItemTyp item = new TechnicalInfoItemTyp();
                    item.technicalInfoId = Convert.ToInt64(repo.sdr["id"]);
                    item.technicalInfoTitle = repo.sdr["title"].ToString();
                    item.type = Convert.ToInt32(repo.sdr["c_type"]);
                    item.childTechnicalInfoId = Convert.ToInt64(repo.sdr["c_id"] is DBNull ? 0 : repo.sdr["c_id"]);
                    item.childTechnicalInfoTitle = Convert.ToString(repo.sdr["c_title"]);
                    item.c_fk_technicalinfo_table_id = Convert.ToInt32(repo.sdr["c_fk_technicalinfo_table_id"] is DBNull ? 0 : repo.sdr["c_fk_technicalinfo_table_id"]);
                    result.Add(item);
                }

            }
            return Ok(result);
        }
        /// <summary>
        /// سرویس لیست مشخصات فنی یک کالا
        /// </summary>
        /// <param name="model">شناسه کالا</param>
        /// <returns></returns>
        [Route("getTechnicalInfoListByItem")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getTechnicalInfoListByItem(LongKeyModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<TechnicalInfoItemTyp> result = new List<TechnicalInfoItemTyp>();
            using (var repo = new Repo(this, "SP_getTechnicalInfoListAndValuesByItem", "ItemController_getTechnicalInfoListByItem", initAsReader: true)) // temp
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                repo.cmd.Parameters.AddWithValue("@item", model.id.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.ExecuteReader();
                while (repo.sdr.Read())
                {
                    TechnicalInfoItemTyp item = new TechnicalInfoItemTyp();
                    item.technicalInfoId = Convert.ToInt64(repo.sdr["id"]);
                    item.technicalInfoTitle = repo.sdr["title"].ToString();
                    item.type = Convert.ToInt32(repo.sdr["c_type"]);
                    item.childTechnicalInfoId = Convert.ToInt64(repo.sdr["c_id"] is DBNull ? 0 : repo.sdr["c_id"]);
                    item.childTechnicalInfoTitle = Convert.ToString(repo.sdr["c_title"]);
                    item.c_fk_technicalinfo_table_id = Convert.ToInt32(repo.sdr["c_fk_technicalinfo_table_id"] is DBNull ? 0 : repo.sdr["c_fk_technicalinfo_table_id"]);
                    item.strValue = Convert.ToString(repo.sdr["strValue"]);
                    item.fk_technicalInfoValues_tblValue = Convert.ToInt64(repo.sdr["fk_technicalInfoValues_tblValue"] is DBNull ? 0 : repo.sdr["fk_technicalInfoValues_tblValue"]);
                    item.fk_technicalInfoValues_tblValue_dsc = Convert.ToString(repo.sdr["fk_technicalInfoValues_tblValue_dsc"]);
                    item.isPublic = Convert.ToBoolean(repo.sdr["isPublic"] is DBNull ? 1 :repo.sdr["isPublic"]);
                    result.Add(item);
                }

            }
            return Ok(result);
        }
        /// <summary>
        /// سرویس لیست مشخصات فنی یک کالا اپ خریدار
        /// </summary>
        /// <param name="model">شناسه کالا</param>
        /// <returns></returns>
        [Route("getTechnicalInfoListByItem_customer")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getTechnicalInfoListByItem_customer(LongKeyModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<TechnicalInfoItemTyp> result = new List<TechnicalInfoItemTyp>();
            using (var repo = new Repo(this, "SP_getTechnicalInfoListAndValuesByItem", "ItemController_getTechnicalInfoListByItem_customer", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                repo.cmd.Parameters.AddWithValue("@item", model.id);
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.ExecuteReader();
                while (repo.sdr.Read())
                {
                    TechnicalInfoItemTyp item = new TechnicalInfoItemTyp();
                    item.technicalInfoId = Convert.ToInt64(repo.sdr["id"]);
                    item.technicalInfoTitle = repo.sdr["title"].ToString();
                    item.type = Convert.ToInt32(repo.sdr["c_type"]);
                    item.childTechnicalInfoId = Convert.ToInt64(repo.sdr["c_id"] is DBNull ? 0 : repo.sdr["c_id"]);
                    item.childTechnicalInfoTitle = Convert.ToString(repo.sdr["c_title"]);
                    item.c_fk_technicalinfo_table_id = Convert.ToInt32(repo.sdr["c_fk_technicalinfo_table_id"] is DBNull ? 0 : repo.sdr["c_fk_technicalinfo_table_id"]);
                    item.strValue = Convert.ToString(repo.sdr["strValue"]);
                    item.fk_technicalInfoValues_tblValue = Convert.ToInt64(repo.sdr["fk_technicalInfoValues_tblValue"] is DBNull ? 0 : repo.sdr["fk_technicalInfoValues_tblValue"]);
                    item.fk_technicalInfoValues_tblValue_dsc = Convert.ToString(repo.sdr["fk_technicalInfoValues_tblValue_dsc"]);
                    result.Add(item);
                }

            }
            return Ok(result);
        }
        /// <summary>
        /// سرویس دریافت لیست مقادیر مربوط به یک مشخصه فنی
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getTechnicalInfoValueList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getTechnicalInfoValueList(LongKeyModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<TechnicalInfoValue> result = new List<TechnicalInfoValue>();
            using (var repo = new Repo(this, "SP_getTechnicalInfoValues", "ItemController_getTechnicalInfoValueList", initAsReader: true, checkAccess: false))
            {
                repo.cmd.Parameters.AddWithValue("@technicalInfoId", model.id);
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.ExecuteReader();
                while (repo.sdr.Read())
                {
                    TechnicalInfoValue item = new TechnicalInfoValue();
                    item.id = Convert.ToInt64(repo.sdr["id"]);
                    item.value = repo.sdr["val"].ToString();
                    result.Add(item);
                }

            }
            return Ok(result);
        }
        /// <summary>
        /// سرویس جستجوی لیست کالاها_شمای 1
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("searchItemListScale1")]
        [Exception]
        [HttpPost]
        public IHttpActionResult SearchItemListLevel1(SearchItemListModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            if (model.type == 0 | model.type == 1 | model.type == null)
            {
                using (var repo = new Repo(this, "SP_searchItemListScale1", "itemController_SearchItemListLevel1", checkAccess: false, initAsReader: true))
                {
                    if (repo.unauthorized)
                        return new UnauthorizedActionResult("Unauthorized!");
                    repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                    repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                    repo.cmd.Parameters.AddWithValue("@itemGrpId", model.itemGrpId.getLongDbValue());
                    repo.cmd.Parameters.AddWithValue("@cityId", model.cityId.getLongDbValue());
                    repo.cmd.Parameters.AddWithValue("@storeId", model.storeId.getLongDbValue());
                    repo.cmd.Parameters.AddWithValue("@justAvailableGoods", model.justAvailableGoods);
                    repo.cmd.Parameters.AddWithValue("@minPrice", model.minPrice);
                    repo.cmd.Parameters.AddWithValue("@maxPrice", model.maxPrice);
                    repo.cmd.Parameters.AddWithValue("@distance", model.distance);
                    repo.cmd.Parameters.AddWithValue("@orderByPrice", model.orderByPrice);
                    repo.cmd.Parameters.AddWithValue("@orderByDistance", model.orderByDistance);
                    repo.cmd.Parameters.AddWithValue("@orderByAlphabetic", model.orderByAlphabetic);
                    repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                    repo.cmd.Parameters.AddWithValue("@curLat", model.curLat.dbNullCheckDouble());
                    repo.cmd.Parameters.AddWithValue("@curLng", model.curLng.dbNullCheckDouble());
                    repo.cmd.Parameters.AddWithValue("@centerLocLat", model.centerLat.dbNullCheckDouble());
                    repo.cmd.Parameters.AddWithValue("@centerLocLng", model.centerLng.dbNullCheckDouble());
                    repo.cmd.Parameters.AddWithValue("@categoryId", model.categoryId.dbNullCheckLong());
                    repo.cmd.Parameters.AddWithValue("@onlyDiscount", model.onlyDiscountItem.dbNullCheckBoolean());
                    repo.cmd.Parameters.AddWithValue("@withMinMaxValues", false);
                    var param = repo.cmd.Parameters.Add("@rcode", SqlDbType.Int);
                    param.Direction = ParameterDirection.Output;
                    repo.ExecuteAdapter();
                    if (Convert.ToInt32(param.Value) == 0)
                        return new NotFoundActionResult("access denied");
                    var result = repo.ds.Tables[0];
                    var opinion = repo.ds.Tables[2];
                    var branch = repo.ds.Tables[3];
                    var docs = repo.ds.Tables[4].AsEnumerable();
                    return Ok(result.AsEnumerable().Select(
                        row => new
                        {
                            location = new
                            {
                                lat = row.Field<object>("lat").dbNullCheckDouble(),
                                lng = row.Field<object>("lng").dbNullCheckDouble() ,
                                //city = new IdTitleValue<int>
                                //{
                                //    id = Convert.ToInt32(row.Field<object>("cityId").dbNullCheckInt()),
                                //    title = Convert.ToString(row.Field<object>("cityTitle").dbNullCheckString())
                                //}
                            },
                            itemId = Convert.ToInt64(row.Field<object>("id") is DBNull ? 0 : row.Field<object>("id")),
                            itemTitle = Convert.ToString(row.Field<object>("title")),
                            itemImageUrl = docs.Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToString(i.Field<object>("ImageUrl"))).FirstOrDefault(),
                            thumbImageUrl = docs.Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToString(i.Field<object>("thumbcompeleteLink"))).FirstOrDefault(),
                            itemTechTitle = Convert.ToString(row.Field<object>("technicalTitle")),
                            minPrice = Convert.ToString(row.Field<object>("minPrice")),
                            type = Convert.ToInt16(row.Field<object>("type")),
                            maxPrice = Convert.ToString(row.Field<object>("maxPrice")),
                            itemGrpDsc = Convert.ToString(row.Field<object>("itemGrpDsc")),
                            maxDiscount = Convert.ToDecimal(row.Field<object>("maxDiscount")),
                            storeCount = repo.ds.Tables[1].AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("pk_fk_item_id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToInt32(i.Field<object>("storeCount"))).FirstOrDefault(),
                            hasOpinion = opinion.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToBoolean(i.Field<object>("hasOpinion"))).FirstOrDefault(),
                            resultIsPublic = opinion.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToBoolean(i.Field<object>("resultIsPublic"))).FirstOrDefault(),
                            avg = opinion.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToDecimal(i.Field<object>("avgOpinions"))).LastOrDefault(),
                            cntPoll = opinion.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToDecimal(i.Field<object>("cntOpinions"))).LastOrDefault(),
                            branchMap_dsc = branch.AsEnumerable().Select(c => c.Field<string>("branchMap_dsc").dbNullCheckString()).FirstOrDefault(),
                            maxStoreId = row.Field<object>("maxStoreId").dbNullCheckLong()
                            ,
                            itemExists = Convert.ToBoolean(row.Field<object>("itemExists") is DBNull ? 0 : row.Field<object>("itemExists")),
                            barcode =  row.Field<object>("barcode").dbNullCheckString(),
                            uniqueBarcode = row.Field<object>("uniqueBarcode").dbNullCheckString()
                        }).ToList()
                        );
                }
            }
            else
            {
                using (var repo = new Repo(this, "SP_searchItemListScale1_COPY", "itemController_SearchItemListLevel1", checkAccess: false, initAsReader: true))
                {
                    if (repo.unauthorized)
                        return new UnauthorizedActionResult("Unauthorized!");
                    repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                    repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                    repo.cmd.Parameters.AddWithValue("@itemGrpId", model.itemGrpId.getLongDbValue());
                    repo.cmd.Parameters.AddWithValue("@cityId", model.cityId.getLongDbValue());
                    repo.cmd.Parameters.AddWithValue("@storeId", model.storeId.getLongDbValue());
                    repo.cmd.Parameters.AddWithValue("@justAvailableGoods", model.justAvailableGoods);
                    repo.cmd.Parameters.AddWithValue("@minPrice", model.minPrice);
                    repo.cmd.Parameters.AddWithValue("@maxPrice", model.maxPrice);
                    repo.cmd.Parameters.AddWithValue("@distance", model.distance);
                    repo.cmd.Parameters.AddWithValue("@orderByPrice", model.orderByPrice);
                    repo.cmd.Parameters.AddWithValue("@orderByDistance", model.orderByDistance);
                    repo.cmd.Parameters.AddWithValue("@orderByAlphabetic", model.orderByAlphabetic);
                    repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                    repo.cmd.Parameters.AddWithValue("@curLat", model.curLat.dbNullCheckDouble());
                    repo.cmd.Parameters.AddWithValue("@curLng", model.curLng.dbNullCheckDouble());
                    repo.cmd.Parameters.AddWithValue("@categoryId", model.categoryId.dbNullCheckLong());
                    repo.cmd.Parameters.AddWithValue("@onlyDiscount", model.onlyDiscountItem.dbNullCheckBoolean());
                    var param = repo.cmd.Parameters.Add("@rcode", SqlDbType.Int);
                    param.Direction = ParameterDirection.Output;
                    repo.ExecuteAdapter();
                    if (Convert.ToInt32(param.Value) == 0)
                        return new NotFoundActionResult("access denied");
                    var result = repo.ds.Tables[0];
                    var opinion = repo.ds.Tables[2];
                    var branch = repo.ds.Tables[3];
                    var docs = repo.ds.Tables[4].AsEnumerable();
                    var evalInfo = repo.ds.Tables[5].AsEnumerable();
                    return Ok(result.AsEnumerable().Select(
                        row => new
                        {
                            location = new
                            {
                                lat = row.Field<object>("lat").dbNullCheckDouble(),
                                lng = row.Field<object>("lng").dbNullCheckDouble(),
                                city = new IdTitleValue<int>
                                {
                                    id = Convert.ToInt32(row.Field<object>("cityId").dbNullCheckInt()),
                                    title = Convert.ToString(row.Field<object>("cityTitle").dbNullCheckString())
                                }
                            },
                            itemId = Convert.ToInt64(row.Field<object>("id") is DBNull ? 0 : row.Field<object>("id")),
                            itemTitle = Convert.ToString(row.Field<object>("title")),
                            itemImageUrl = docs.Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToString(i.Field<object>("ImageUrl"))).FirstOrDefault(),
                            thumbImageUrl = docs.Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToString(i.Field<object>("thumbcompeleteLink"))).FirstOrDefault(),
                            itemTechTitle = Convert.ToString(row.Field<object>("technicalTitle")),
                            minPrice = Convert.ToString(row.Field<object>("minPrice")),
                            type = Convert.ToInt16(row.Field<object>("type")),
                            maxPrice = Convert.ToString(row.Field<object>("maxPrice")),
                            itemGrpDsc = Convert.ToString(row.Field<object>("itemGrpDsc")),
                            maxDiscount = Convert.ToDecimal(row.Field<object>("maxDiscount")),
                            storeCount = repo.ds.Tables[1].AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("pk_fk_item_id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToInt32(i.Field<object>("storeCount"))).FirstOrDefault(),
                            hasOpinion = opinion.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToBoolean(i.Field<object>("hasOpinion"))).FirstOrDefault(),
                            resultIsPublic = opinion.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToBoolean(i.Field<object>("resultIsPublic"))).FirstOrDefault(),
                            avg = opinion.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToDecimal(i.Field<object>("avgOpinions"))).LastOrDefault(),
                            cntPoll = opinion.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToDecimal(i.Field<object>("cntOpinions"))).LastOrDefault(),
                            branchMap_dsc = branch.AsEnumerable().Select(c => c.Field<string>("branchMap_dsc").dbNullCheckString()).FirstOrDefault(),
                            maxStoreId = row.Field<object>("maxStoreId").dbNullCheckLong(),
                            barcode = row.Field<object>("barcode").dbNullCheckString(),
                            uniqueBarcode = row.Field<object>("uniqueBarcode").dbNullCheckString(),
                            evalCnt = evalInfo.Where(m=> Convert.ToInt64(row.Field<object>("id")) == Convert.ToInt64(m.Field<object>("id"))).Select(c=> c.Field<object>("evalCnt").dbNullCheckInt()).FirstOrDefault(),
                            evalAvg = evalInfo.Where(m => Convert.ToInt64(row.Field<object>("id")) == Convert.ToInt64(m.Field<object>("id"))).Select(c => c.Field<object>("evalAvg").dbNullCheckDecimal()).FirstOrDefault(),
                        }).ToList()
                        );
                }
            }
        }
        /// <summary>
        /// سرویس جستجوی لیست کالاها شمای 1 ورژن 2
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("searchItemListScale1_V2")]
        [Exception]
        [HttpPost]
        public IHttpActionResult searchItemListScale1_V2(SearchItemListModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            if (model.type == 0 | model.type == 1 | model.type == null)
            {
                using (var repo = new Repo(this, "SP_searchItemListScale1", "itemController_searchItemListScale1_V2", checkAccess: false, initAsReader: true))
                {
                    if (repo.unauthorized)
                        return new UnauthorizedActionResult("Unauthorized!");
                    repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                    repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                    repo.cmd.Parameters.AddWithValue("@itemGrpId", model.itemGrpId.getLongDbValue());
                    repo.cmd.Parameters.AddWithValue("@cityId", model.cityId.getLongDbValue());
                    repo.cmd.Parameters.AddWithValue("@storeId", model.storeId.getLongDbValue());
                    repo.cmd.Parameters.AddWithValue("@justAvailableGoods", model.justAvailableGoods);
                    repo.cmd.Parameters.AddWithValue("@minPrice", model.minPrice);
                    repo.cmd.Parameters.AddWithValue("@maxPrice", model.maxPrice);
                    repo.cmd.Parameters.AddWithValue("@distance", model.distance);
                    repo.cmd.Parameters.AddWithValue("@orderByPrice", model.orderByPrice);
                    repo.cmd.Parameters.AddWithValue("@orderByDistance", model.orderByDistance);
                    repo.cmd.Parameters.AddWithValue("@orderByAlphabetic", model.orderByAlphabetic);
                    repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                    repo.cmd.Parameters.AddWithValue("@curLat", model.curLat.dbNullCheckDouble());
                    repo.cmd.Parameters.AddWithValue("@curLng", model.curLng.dbNullCheckDouble());
                    repo.cmd.Parameters.AddWithValue("@centerLocLat", model.centerLat.dbNullCheckDouble());
                    repo.cmd.Parameters.AddWithValue("@centerLocLng", model.centerLng.dbNullCheckDouble());
                    repo.cmd.Parameters.AddWithValue("@categoryId", model.categoryId.dbNullCheckLong());
                    repo.cmd.Parameters.AddWithValue("@onlyDiscount", model.onlyDiscountItem.dbNullCheckBoolean());
                    repo.cmd.Parameters.AddWithValue("@searchBarcode", model.searchBarcode.dbNullCheckString());
                    repo.cmd.Parameters.AddWithValue("@withMinMaxValues", model.withMinMax.dbNullCheckBoolean());
                    var param = repo.cmd.Parameters.Add("@rcode", SqlDbType.Int);
                    param.Direction = ParameterDirection.Output;
                    repo.ExecuteAdapter();
                    if (Convert.ToInt32(param.Value) == 0)
                        return new NotFoundActionResult("access denied");
                    var result = repo.ds.Tables[0];
                    var opinion = repo.ds.Tables[2];
                    var branch = repo.ds.Tables[3];
                    var docs = repo.ds.Tables[4].AsEnumerable();
                    return Ok(result.AsEnumerable().Select(
                        row => new
                        {
                            location = new
                            {
                                lat = row.Field<object>("lat").dbNullCheckDouble(),
                                lng = row.Field<object>("lng").dbNullCheckDouble(),
                                //city = new IdTitleValue<int>
                                //{
                                //    id = Convert.ToInt32(row.Field<object>("cityId").dbNullCheckInt()),
                                //    title = Convert.ToString(row.Field<object>("cityTitle").dbNullCheckString())
                                //}
                            },
                            itemId = Convert.ToInt64(row.Field<object>("id") is DBNull ? 0 : row.Field<object>("id")),
                            itemTitle = Convert.ToString(row.Field<object>("title")),
                            itemImageUrl = docs.Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToString(i.Field<object>("ImageUrl"))).FirstOrDefault(),
                            thumbImageUrl = docs.Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToString(i.Field<object>("thumbcompeleteLink"))).FirstOrDefault(),
                            itemTechTitle = Convert.ToString(row.Field<object>("technicalTitle")),
                            minPrice = Convert.ToString(row.Field<object>("minPrice")),
                            type = Convert.ToInt16(row.Field<object>("type")),
                            maxPrice = Convert.ToString(row.Field<object>("maxPrice")),
                            itemGrpDsc = Convert.ToString(row.Field<object>("itemGrpDsc")),
                            maxDiscount = Convert.ToDecimal(row.Field<object>("maxDiscount")),
                            storeCount = repo.ds.Tables[1].AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("pk_fk_item_id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToInt32(i.Field<object>("storeCount"))).FirstOrDefault(),
                            hasOpinion = opinion.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToBoolean(i.Field<object>("hasOpinion"))).FirstOrDefault(),
                            resultIsPublic = opinion.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToBoolean(i.Field<object>("resultIsPublic"))).FirstOrDefault(),
                            avg = opinion.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToDecimal(i.Field<object>("avgOpinions"))).LastOrDefault(),
                            cntPoll = opinion.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToDecimal(i.Field<object>("cntOpinions"))).LastOrDefault(),
                            branchMap_dsc = branch.AsEnumerable().Select(c => c.Field<string>("branchMap_dsc").dbNullCheckString()).FirstOrDefault(),
                            maxStoreId = row.Field<object>("maxStoreId").dbNullCheckLong(),
                            itemExists = Convert.ToBoolean(row.Field<object>("itemExists") is DBNull ? 0 : row.Field<object>("itemExists")),
                            barcode = row.Field<object>("barcode").dbNullCheckString(),
                            uniqueBarcode = row.Field<object>("uniqueBarcode").dbNullCheckString(),
                            promotionDiscount = row.Field<object>("promotionDiscount").dbNullCheckDecimal()

                        }).ToList()
                        );
                }
            }
            else
            {
                using (var repo = new Repo(this, "SP_searchItemListScale1_COPY", "itemController_searchItemListScale1_V2", checkAccess: false, initAsReader: true))
                {
                    if (repo.unauthorized)
                        return new UnauthorizedActionResult("Unauthorized!");
                    repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                    repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                    repo.cmd.Parameters.AddWithValue("@itemGrpId", model.itemGrpId.getLongDbValue());
                    repo.cmd.Parameters.AddWithValue("@cityId", model.cityId.getLongDbValue());
                    repo.cmd.Parameters.AddWithValue("@storeId", model.storeId.getLongDbValue());
                    repo.cmd.Parameters.AddWithValue("@justAvailableGoods", model.justAvailableGoods);
                    repo.cmd.Parameters.AddWithValue("@minPrice", model.minPrice);
                    repo.cmd.Parameters.AddWithValue("@maxPrice", model.maxPrice);
                    repo.cmd.Parameters.AddWithValue("@distance", model.distance);
                    repo.cmd.Parameters.AddWithValue("@orderByPrice", model.orderByPrice);
                    repo.cmd.Parameters.AddWithValue("@orderByDistance", model.orderByDistance);
                    repo.cmd.Parameters.AddWithValue("@orderByAlphabetic", model.orderByAlphabetic);
                    repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                    repo.cmd.Parameters.AddWithValue("@curLat", model.curLat.dbNullCheckDouble());
                    repo.cmd.Parameters.AddWithValue("@curLng", model.curLng.dbNullCheckDouble());
                    repo.cmd.Parameters.AddWithValue("@categoryId", model.categoryId.dbNullCheckLong());
                    repo.cmd.Parameters.AddWithValue("@onlyDiscount", model.onlyDiscountItem.dbNullCheckBoolean());
                    repo.cmd.Parameters.AddWithValue("@searchBarcode", model.searchBarcode.dbNullCheckString());
                    var param = repo.cmd.Parameters.Add("@rcode", SqlDbType.Int);
                    param.Direction = ParameterDirection.Output;
                    repo.ExecuteAdapter();
                    if (Convert.ToInt32(param.Value) == 0)
                        return new NotFoundActionResult("access denied");
                    var result = repo.ds.Tables[0];
                    var opinion = repo.ds.Tables[2];
                    var branch = repo.ds.Tables[3];
                    var docs = repo.ds.Tables[4].AsEnumerable();
                    var evalInfo = repo.ds.Tables[5].AsEnumerable();
                    return Ok(result.AsEnumerable().Select(
                        row => new
                        {
                            location = new
                            {
                                lat = row.Field<object>("lat").dbNullCheckDouble(),
                                lng = row.Field<object>("lng").dbNullCheckDouble(),
                                city = new IdTitleValue<int>
                                {
                                    id = Convert.ToInt32(row.Field<object>("cityId").dbNullCheckInt()),
                                    title = Convert.ToString(row.Field<object>("cityTitle").dbNullCheckString())
                                }
                            },
                            itemId = Convert.ToInt64(row.Field<object>("id") is DBNull ? 0 : row.Field<object>("id")),
                            itemTitle = Convert.ToString(row.Field<object>("title")),
                            itemImageUrl = docs.Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToString(i.Field<object>("ImageUrl"))).FirstOrDefault(),
                            thumbImageUrl = docs.Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToString(i.Field<object>("thumbcompeleteLink"))).FirstOrDefault(),
                            itemTechTitle = Convert.ToString(row.Field<object>("technicalTitle")),
                            minPrice = Convert.ToString(row.Field<object>("minPrice")),
                            type = Convert.ToInt16(row.Field<object>("type")),
                            maxPrice = Convert.ToString(row.Field<object>("maxPrice")),
                            itemGrpDsc = Convert.ToString(row.Field<object>("itemGrpDsc")),
                            maxDiscount = Convert.ToDecimal(row.Field<object>("maxDiscount")),
                            storeCount = repo.ds.Tables[1].AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("pk_fk_item_id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToInt32(i.Field<object>("storeCount"))).FirstOrDefault(),
                            hasOpinion = opinion.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToBoolean(i.Field<object>("hasOpinion"))).FirstOrDefault(),
                            resultIsPublic = opinion.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToBoolean(i.Field<object>("resultIsPublic"))).FirstOrDefault(),
                            avg = opinion.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToDecimal(i.Field<object>("avgOpinions"))).LastOrDefault(),
                            cntPoll = opinion.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToDecimal(i.Field<object>("cntOpinions"))).LastOrDefault(),
                            branchMap_dsc = branch.AsEnumerable().Select(c => c.Field<string>("branchMap_dsc").dbNullCheckString()).FirstOrDefault(),
                            maxStoreId = row.Field<object>("maxStoreId").dbNullCheckLong(),
                            barcode = row.Field<object>("barcode").dbNullCheckString(),
                            uniqueBarcode = row.Field<object>("uniqueBarcode").dbNullCheckString(),
                            evalCnt = evalInfo.Where(m => Convert.ToInt64(row.Field<object>("id")) == Convert.ToInt64(m.Field<object>("id"))).Select(c => c.Field<object>("evalCnt").dbNullCheckInt()).FirstOrDefault(),
                            evalAvg = evalInfo.Where(m => Convert.ToInt64(row.Field<object>("id")) == Convert.ToInt64(m.Field<object>("id"))).Select(c => c.Field<object>("evalAvg").dbNullCheckDecimal()).FirstOrDefault()
                        }).ToList()
                        );
                }
            }
        }
        /// <summary>
        /// سرویس جستجوی لیست کالاها_شمای 1
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("searchItemListScale1_WithMinMaxPrice")]
        [Exception]
        [HttpPost]
        public IHttpActionResult searchItemListScale1_WithMinMaxPrice(SearchItemListModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);

            using (var repo = new Repo(this, "SP_searchItemListScale1", "itemController_searchItemListScale1_WithMinMaxPrice", checkAccess: false, initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                repo.cmd.Parameters.AddWithValue("@itemGrpId", model.itemGrpId.getLongDbValue());
                repo.cmd.Parameters.AddWithValue("@cityId", model.cityId.getLongDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", model.storeId.getLongDbValue());
                repo.cmd.Parameters.AddWithValue("@justAvailableGoods", model.justAvailableGoods.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@minPrice", model.minPrice.dbNullCheckDecimal());
                repo.cmd.Parameters.AddWithValue("@maxPrice", model.maxPrice.dbNullCheckDecimal());
                repo.cmd.Parameters.AddWithValue("@distance", model.distance.dbNullCheckInt());
                repo.cmd.Parameters.AddWithValue("@orderByPrice", model.orderByPrice.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@orderByDistance", model.orderByDistance.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@orderByAlphabetic", model.orderByAlphabetic.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                repo.cmd.Parameters.AddWithValue("@curLat", model.curLat.dbNullCheckDouble());
                repo.cmd.Parameters.AddWithValue("@curLng", model.curLng.dbNullCheckDouble());
                repo.cmd.Parameters.AddWithValue("@centerLocLat", model.centerLat.dbNullCheckDouble());
                repo.cmd.Parameters.AddWithValue("@centerLocLng", model.centerLng.dbNullCheckDouble());
                repo.cmd.Parameters.AddWithValue("@categoryId", model.categoryId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@onlyDiscount", model.onlyDiscountItem.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@withMinMaxValues", true);
                var param = repo.cmd.Parameters.Add("@rcode", SqlDbType.Int);
                param.Direction = ParameterDirection.Output;
                repo.ExecuteAdapter();
                if (Convert.ToInt32(param.Value) == 0)
                    return new NotFoundActionResult("access denied");
                var result = repo.ds.Tables[0];
                var opinion = repo.ds.Tables[2];
                var branch = repo.ds.Tables[3];
                var docs = repo.ds.Tables[4].AsEnumerable();
                return Ok(new
                {
                    items = result.AsEnumerable().Select(
                    row => new
                    {
                        location = new
                        {
                            lat = row.Field<object>("lat").dbNullCheckDouble(),
                            lng = row.Field<object>("lng").dbNullCheckDouble(),
                            //city = new IdTitleValue<int>
                            //{
                            //    id = Convert.ToInt32(row.Field<object>("cityId").dbNullCheckInt()),
                            //    title = Convert.ToString(row.Field<object>("cityTitle").dbNullCheckString())
                            //}
                        },
                        itemId = Convert.ToInt64(row.Field<object>("id") is DBNull ? 0 : row.Field<object>("id")),
                        itemTitle = Convert.ToString(row.Field<object>("title")),
                        itemImageUrl = docs.Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToString(i.Field<object>("ImageUrl"))).FirstOrDefault(),
                        thumbImageUrl = docs.Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToString(i.Field<object>("thumbcompeleteLink"))).FirstOrDefault(),
                        itemTechTitle = Convert.ToString(row.Field<object>("technicalTitle")),
                        minPrice = Convert.ToString(row.Field<object>("minPrice")),
                        type = Convert.ToInt16(row.Field<object>("type")),
                        maxPrice = Convert.ToString(row.Field<object>("maxPrice")),
                        itemGrpDsc = Convert.ToString(row.Field<object>("itemGrpDsc")),
                        maxDiscount = Convert.ToDecimal(row.Field<object>("maxDiscount")),
                        storeCount = repo.ds.Tables[1].AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("pk_fk_item_id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToInt32(i.Field<object>("storeCount"))).FirstOrDefault(),
                        hasOpinion = opinion.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToBoolean(i.Field<object>("hasOpinion"))).FirstOrDefault(),
                        resultIsPublic = opinion.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToBoolean(i.Field<object>("resultIsPublic"))).FirstOrDefault(),
                        avg = opinion.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToDecimal(i.Field<object>("avgOpinions"))).LastOrDefault(),
                        cntPoll = opinion.AsEnumerable().Where(i => Convert.ToInt64(i.Field<object>("id")) == Convert.ToInt64(row.Field<object>("id"))).Select(i => Convert.ToDecimal(i.Field<object>("cntOpinions"))).LastOrDefault(),
                        branchMap_dsc = branch.AsEnumerable().Select(c => c.Field<string>("branchMap_dsc").dbNullCheckString()).FirstOrDefault(),
                        maxStoreId = row.Field<object>("maxStoreId").dbNullCheckLong()
                        ,
                        itemExists = Convert.ToBoolean(row.Field<object>("itemExists") is DBNull ? 0 : row.Field<object>("itemExists")),
                        barcode = row.Field<object>("barcode").dbNullCheckString(),
                        uniqueBarcode = row.Field<object>("uniqueBarcode").dbNullCheckString(),
                        promotionDiscount = row.Field<object>("promotionDiscount").dbNullCheckDecimal()

                    }).ToList(),
                    minprice = repo.ds.Tables[5].AsEnumerable().Select(fa => fa.Field<object>("minPrice_val")).Min(fa => fa),
                    maxprice = repo.ds.Tables[5].AsEnumerable().Select(fa => fa.Field<object>("maxPrice_val")).Max(fa => fa)
                }
                    );
            }

        }
        /// <summary>
        /// سرویس جستجوی لیست کالاها_شمای 2
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("searchItemListScale2")]
        [Exception]
        [HttpPost]
        public IHttpActionResult SearchItemListLevel2(SearchItemListModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_searchItemListScale2", "itemController_SearchItemListLevel2", checkAccess: false, initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                repo.cmd.Parameters.AddWithValue("@itemGrpId", model.itemGrpId.getLongDbValue());
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.getLongDbValue());
                repo.cmd.Parameters.AddWithValue("@cityId", model.cityId.getLongDbValue());
                repo.cmd.Parameters.AddWithValue("@justAvailableGoods", model.justAvailableGoods);
                repo.cmd.Parameters.AddWithValue("@minPrice", model.minPrice);
                repo.cmd.Parameters.AddWithValue("@maxPrice", model.maxPrice);
                repo.cmd.Parameters.AddWithValue("@distance", model.distance);
                repo.cmd.Parameters.AddWithValue("@orderByPrice", model.orderByPrice);
                repo.cmd.Parameters.AddWithValue("@orderByDistance", model.orderByDistance);
                repo.cmd.Parameters.AddWithValue("@orderByAlphabetic", model.orderByAlphabetic);
                repo.cmd.Parameters.AddWithValue("@orderByStoreState", model.orderByStoreState);
                repo.cmd.Parameters.AddWithValue("@justOpenStore", model.justOpenStore);
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                repo.cmd.Parameters.AddWithValue("@curLat", model.curLat.HasValue ? model.curLat : null);
                repo.cmd.Parameters.AddWithValue("@curLng", model.curLng.HasValue ? model.curLng : null);
                repo.ExecuteAdapter();
                var result = repo.ds.Tables[0];

                return Ok(result.AsEnumerable().Select(
                    row => new
                    {
                        itemId = Convert.ToInt64(row.Field<object>("id") is DBNull ? 0 : row.Field<object>("id")),
                        itemTitle = Convert.ToString(row.Field<object>("title")),
                        itemImageUrl = Convert.ToString(row.Field<object>("ImageUrl")),
                        itemTechTitle = Convert.ToString(row.Field<object>("technicalTitle")),
                        price = Convert.ToDecimal(row.Field<object>("price") is DBNull ? 0 : row.Field<object>("price")),
                        price_dsc = Convert.ToString(row.Field<object>("price_dsc")),
                        purePrice = Convert.ToDecimal(row.Field<object>("purePrice") is DBNull ? 0 : row.Field<object>("purePrice")),
                        score = Convert.ToDecimal(row.Field<object>("score") is DBNull ? 0 : row.Field<object>("score")),
                        address = Convert.ToString(row.Field<object>("address")),
                        distance = Convert.ToDecimal(row.Field<object>("distance") is DBNull ? 0 : row.Field<object>("distance")),
                        distance_dsc = Convert.ToString(row.Field<object>("distanc_dsc")),
                        storeLogo = Convert.ToString(row.Field<object>("STOREImageUrl")),
                        statusId = Convert.ToInt32(row.Field<object>("statusId") is DBNull ? 0 : row.Field<object>("statusId")),
                        statusTitle = Convert.ToString(row.Field<object>("statusTitle")),
                        storeTitle = Convert.ToString(row.Field<object>("storeTitle")),
                        storeId = Convert.ToInt64(row.Field<object>("storeId") is DBNull ? 0 : row.Field<object>("storeId")),
                        qty = Convert.ToDecimal(row.Field<object>("qty") is DBNull ? 0 : row.Field<object>("qty")),
                        storeExpertise = Convert.ToString(row.Field<object>("storeExpertise")),
                        barcode = row.Field<object>("barcode").dbNullCheckString(),
                        city = new IdTitleValue<int>
                        {
                            id = Convert.ToInt32(row.Field<object>("cityId").dbNullCheckInt()),
                            title = Convert.ToString(row.Field<object>("cityTitle").dbNullCheckString())
                        }
                    }).ToList()
                    );
            }
        }
        /// <summary>
        /// سرویس دریافت لیست نظرات کاربران در مورد یک کالا
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getOpinionList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getOpinionList(getOpinionItemListModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getOpinionList", "item_controller_getOpinionList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                repo.cmd.Parameters.AddWithValue("@storeId", model.storeId.getLongDbValue());
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@filterStatus", model.filterStatus.dbNullCheckInt());
                repo.ExecuteAdapter();
                DataTable amar = repo.ds.Tables[0];
                DataTable commentInfo = repo.ds.Tables[1];
                var result = amar.AsEnumerable().Select(row => new GetOpinionListResultModel
                {
                    userRateAverrage = Convert.ToDecimal(row.Field<object>(0) is DBNull ? 0 : row.Field<object>(0)),
                    commentMember = Convert.ToInt32(row.Field<object>(1) is DBNull ? 0 : row.Field<object>(1)),
                    opinionInfo = commentInfo.AsEnumerable().Select(i => new EvaluationModel
                    {
                        id = Convert.ToInt64(i.Field<object>("id")),
                        usrName = Convert.ToString(i.Field<object>("usrName")),
                        date = Convert.ToString(i.Field<object>("date")),
                        rate = Convert.ToDecimal(i.Field<object>("rate") is DBNull ? 0 : i.Field<object>("rate")),
                        comment = Convert.ToString(i.Field<object>("comment")),
                        status = new IdTitleValue<long> { id = Convert.ToInt64(i.Field<object>("statusId")),title = Convert.ToString(i.Field<object>("statusTitle"))}
                    }).ToList()
                }).ToList();
                return Ok(result);
            }
        }
        ///// <summary>
        ///// سرویس دریافت لیست رنگ ها
        ///// </summary>
        ///// <param name="model"></param>
        ///// <returns></returns>
        //[Route("getItemColorList")]
        //[Exception]
        //[HttpPost]
        //public IHttpActionResult getColorList(GetItemInfoModel model)
        //{
        //    if (!ModelState.IsValid)
        //        return new BadRequestActionResult(ModelState.Values);
        //    using (var repo = new Repo(this, "SP_getColorList", "itemController_getItemColorList", autenticationMode.NoAuthenticationRequired, initAsReader: true, checkAccess: false))
        //    {
        //        repo.cmd.Parameters.AddWithValue("@storeId", model.storeId);
        //        repo.cmd.Parameters.AddWithValue("@itemId", model.itemId);
        //        repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
        //        repo.ExecuteAdapter();
        //        DataTable result = repo.ds.Tables[0];
        //        return Ok(result.AsEnumerable().Select(row => new ItemColorModel
        //        {
        //            color = Convert.ToString(row.Field<object>("id")),
        //            colorName = Convert.ToString(row.Field<object>("title")),
        //            colorCost = Convert.ToDecimal(row.Field<object>("colorCost"))
        //        }).ToList());
        //    }
        //}
       
        /// <summary>
        /// سرویس دریافت کی و مقادیر مشخصه فنی تیبلی
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getTechnicalTableValueList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getTechnicalTableValueList(IdTitleValue<int> model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getTechnicalTableValueList", "itemController_getTechnicalTableValueList", initAsReader: true))
            {
                repo.cmd.Parameters.AddWithValue("@id", model.id);
                repo.ExecuteAdapter();
                DataTable result = repo.ds.Tables[0];
                return Ok(result.AsEnumerable().Select(row => new IdTitleValue<long> { id = Convert.ToInt64(row.Field<object>("id")), title = Convert.ToString(row.Field<object>("val")) }).ToList());
            }
        }
        /// <summary>
        /// سرویس مقایسه کالا
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("compareItems")]
        [Exception]
        [HttpPost]
        public IHttpActionResult compareItems(List<long> model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_compareItems", "itemController_compareItems", initAsReader: true))
            {
                DataTable dt = new DataTable();
                dt.Columns.Add("id");
                DataRow row;
                foreach (var item in model)
                {
                    row = dt.NewRow();
                    row["id"] = item;
                    dt.Rows.Add(row);
                }
                var param = repo.cmd.Parameters.AddWithValue("@items", dt);
                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i => new
                {
                    itemId = Convert.ToInt64(i.Field<object>("itemId")),
                    technicalInfo = (from c in repo.ds.Tables[1].AsEnumerable()
                                     where c.Field<long>("itemId") == i.Field<long>("itemId")
                                     select new TechnicalInfoItemTyp()
                                     {
                                         technicalInfoId = Convert.ToInt64(c.Field<object>("id")),
                                         technicalInfoTitle = Convert.ToString(c.Field<object>("title")),
                                         type = Convert.ToInt32(c.Field<object>("c_type")),
                                         childTechnicalInfoId = Convert.ToInt64(c.Field<object>("c_id") is DBNull ? 0 : c.Field<object>("c_id")),
                                         childTechnicalInfoTitle = Convert.ToString(c.Field<object>("c_title")),
                                         c_fk_technicalinfo_table_id = Convert.ToInt32(c.Field<object>("c_fk_technicalinfo_table_id") is DBNull ? 0 : c.Field<object>("c_fk_technicalinfo_table_id")),
                                         strValue = Convert.ToString(c.Field<object>("strValue")),
                                         fk_technicalInfoValues_tblValue = Convert.ToInt64(c.Field<object>("fk_technicalInfoValues_tblValue") is DBNull ? 0 : c.Field<object>("fk_technicalInfoValues_tblValue")),
                                         fk_technicalInfoValues_tblValue_dsc = Convert.ToString(c.Field<object>("fk_technicalInfoValues_tblValue_dsc"))
                                     }).ToList()
                }).ToList());
            }
        }
        /// <summary>
        /// سرویس افزودن گروهی کالا بر اساس لیستی از گروه های کالایی
        /// شناسه فروشگاه در هدر ست شود
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addItemsByItemGrp")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addItemsByItemGrp(addItemsByItemGrp model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addItemsByItemGrp", "ItemController_addItemsByItemGrp", checkAccess: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();
                DataTable dtGrpIds = new DataTable();// = ClassToDatatableConvertor.CreateDataTable(model.itemIds);
                dtGrpIds.Columns.Add(new DataColumn("id", typeof(long)));
                DataRow dr;
                foreach (long id in (model.grpIdList ?? new List<long>()))
                {
                    dr = dtGrpIds.NewRow();
                    dr["id"] = id;
                    dtGrpIds.Rows.Add(dr);
                }
                var param = repo.cmd.Parameters.AddWithValue("@StoreGroupingId", dtGrpIds);
                param.SqlDbType = SqlDbType.Structured;
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }

        /// <summary>
        /// سرویس حذف کالا از فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("delete")]
        [Exception]
        [HttpPost]
        public IHttpActionResult delete(ItemModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_deleteItem", "ItemController_delete", checkAccess: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                if (!repo.hasAccess)
                    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@itemId", model.id.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس دریافت لیست نظرات یک موجودیت
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getStoreItemEvaluation")]
        [HttpPost]
        [Exception]
        public IHttpActionResult getStoreItemEvaluation(StoreItemEvaluationBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getStoreItemEvaluation", "itemController_getStoreItemEvaluation", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
              
                    repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                    repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.dbNullCheckLong());
                    repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                    repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                    repo.cmd.Parameters.AddWithValue("@filterByStatus", model.statusId.dbNullCheckInt());
                    repo.cmd.Parameters.AddWithValue("@filterByItemGrp", model.filterByItemGrp.dbNullCheckLong());
                    repo.cmd.Parameters.AddWithValue("@orderType", model.orderType.dbNullCheckInt());
                    repo.ExecuteAdapter();
                    var info = repo.ds.Tables[0].AsEnumerable();
                    return Ok(info.Select(row => new
                    {
                        itemId = row.Field<object>("id"),
                        itemTitle = row.Field<object>("title"),
                        name = row.Field<object>("name"),
                        userId = row.Field<object>("userId"),
                        type = row.Field<object>("itemType"),
                        barcode = row.Field<object>("barcode"),
                        evaluationId = row.Field<object>("evId"),
                        comment = row.Field<object>("comment"),
                        rate = row.Field<object>("rate"),
                        itemGrp = new IdTitleValue<long> { id =Convert.ToInt64(row.Field<object>("itemGrpId") is DBNull ? 0 : row.Field<object>("itemGrpId")), title =Convert.ToString( row.Field<object>("itemGrpTitle")) },
                        status = new IdTitleValue<int> { id =Convert.ToInt32(row.Field<object>("statusId") is DBNull ? 0 : row.Field<object>("statusId")), title =Convert.ToString(row.Field<object>("status_dsc")) },
                        date = row.Field<object>("date_"),
                        thumbcompeleteLink = row.Field<object>("thumbcompeleteLink")
                    }).ToList());
                }
               
            

        }
        /// <summary>
        /// تغییر وضعیت یک نظر در پنل
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("itemEvaluationUpdateStatus")]
        [Exception]
        [HttpPost]
        public IHttpActionResult itemEvaluationUpdateStatus(StoreItemEvaluationBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_itemEvaluationUpdateStatus", "itemController_itemEvaluationUpdateStatus"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@statusId", model.statusId.dbNullCheckInt());
                repo.cmd.Parameters.AddWithValue("@evaluationId", model.evaluationId.dbNullCheckLong());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
                
            }

        }
    }

    /// <summary>
    /// مدل پایه تعریف سایز برای یک کالا
    /// </summary>
    public class addUpdateItemSizeBindingModel
    {
        /// <summary>
        /// شناسه کالا
        /// </summary>
        public long itemId { get; set; }
        /// <summary>
        /// توصیف 
        /// </summary>
        public string sizeInfo { get; set; }
        /// <summary>
        /// فعال/غیرفعال
        /// </summary>
        public bool isActive { get; set; }
        /// <summary>
        /// مشخص کننده مبلغ اضافه شونده به مبلغ پایه کالا
        /// </summary>
        public decimal sizeCost { get; set; }
    }
    /// <summary>
    /// مدل پایه سرویس های مربوط به ارزیابی موجودیت ها
    /// </summary>
    public class StoreItemEvaluationBindingModel:searchParameterModel
    {
        /// <summary>
        /// شناسه موجودیت
        /// </summary>
        public long itemId { get; set; }
        /// <summary>
        /// منتشر شده : 106
        /// در انتظار بررسی : 107
        /// عدم نمایش : 108
        /// </summary>
        public int statusId { get; set; }
        /// <summary>
        /// بر اساس جدید ترین : 0
        /// بر اساس امتیاز : 1
        /// </summary>
        public int orderType { get; set; }
        /// <summary>
        /// فیلتر شناسه گروه
        /// </summary>
        public long filterByItemGrp { get; set; }
        /// <summary>
        /// شناسه ارزیابی
        /// </summary>
        public long evaluationId { get; set; }
    }
    /// <summary>
    /// مدل پایه افزودن گروهی آیتم ها به پنل
    /// </summary>
    public class addItemsByItemGrp
    {
        /// <summary>
        /// لیست شناسه های ایتم
        /// </summary>
        public List<long> grpIdList { get; set; }
    }

    /// <summary>
    /// مدل مربوط به اطلاعات کالای شخصی
    /// </summary>
    public class CustomItemModel
    {
        /// <summary>
        /// کد کالا
        /// </summary>
        public long itemId { get; set; }
        /// <summary>
        /// کد فروشگاه
        /// </summary>
        public long storeId { get; set; }
        /// <summary>
        /// عنوان فروشگاه
        /// </summary>
        public string storeTitle { get; set; }
        /// <summary>
        /// گارانتی دارد ؟
        /// </summary>
        public bool hasWaranty { get; set; }
        /// <summary>
        /// امکان خرید بدون گارانتی؟
        /// </summary>
        public bool purcheseWithoutWaranty { get; set; }
        /// <summary>
        /// تعداد موجود در سفارش
        /// </summary>
        public int inCartCnt { get; set; }
        /// <summary>
        ///  32  is joined
        ///  33  isLeft
        ///  34  isBlocked
        ///  43  isRemoved
        ///  44  pendingToReview
        ///  0   no Membership
        /// </summary>
        public int userMembershipStatus { get; set; }
        /// <summary>
        /// نوع پنل
        /// 1. عمومی
        /// 2. خصوصی
        /// </summary>
        public int storeType { get; set; }
        /// <summary>
        /// مدل مربوط به تب عمومی 
        /// </summary>
        public CommonTabItem commonItem { get; set; }
        /// <summary>
        /// مدل مربوط به قیمت و موجودی
        /// </summary>
        public SohInfoTabItem sohInfoItem { get; set; }
        /// <summary>
        /// مدل مربوط به اطلاعات پایه
        /// </summary>
        public BasicItemTab basicItem { get; set; }
        /// <summary>
        /// کالای پیش فرض
        /// </summary>
        public bool isTemplate { get; set; } = false;
        /// <summary>
        /// لیستی از گارانتی های کالا
        /// </summary>
        public List<WarantyItemTab> warantiesItem { get; set; }
        /// <summary>
        /// لیستی از مشخصات کالا
        /// </summary>
        public List<TechnicalInfoItemTab> techInfoItem { get; set; }
        /// <summary>
        /// لیستی از تصاویر و مستندات کالا
        /// </summary>
        public List<DocumentItemTab> docInfoItem { get; set; }
        /// <summary>
        /// لیستی از رنگ های کالا
        /// </summary>
        public List<ItemColorModel> itemColor { get; set; }
        /// <summary>
        /// لیستی از سایزها
        /// </summary>
        public List<ItemSizeModel> itemSize { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string review { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string reviewAddress { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public opnionPollModel opinionPoll { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public bool voted { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public bool editable { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public IntTitleValue education { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public bool isCallerFavorite { get; set; }

    }
    /// <summary>
    /// مدل پایه مکان موجودیت
    /// </summary>
    public class ItemLocation
    {
        /// <summary>
        /// طول جغرافیایی
        /// Nullable
        /// </summary>
        public double? lat { get; set; }
        /// <summary>
        /// عرض جغرافیایی
        /// Nullable
        /// </summary>
        public double? lng { get; set; }
        /// <summary>
        /// آدرس 
        /// </summary>
        public string address { get; set; }
    }
    /// <summary>
    /// مدل پایه نظرسنجی
    /// </summary>
    public class opnionPollModel
    {
        /// <summary>
        /// شناسه
        /// Nullable
        /// </summary>
        public long? id { get; set; }
        /// <summary>
        /// عنوان نظرسنجی
        /// </summary>
        public string title { get; set; }
        //createDateTime { get; set; }
        //                                                                store_id { get; set; }
        //                                                                store_title  { get; set; }
        //                                                                store_titleSecond{ get; set; }
        //                                                                startDate { get; set; }
        //                                                                endDate { get; set; }



        //startDateTime { get; set; }
        //endDateTime{ get; set; }

        //isActive { get; set; }
        //publish { get; set; }
        /// <summary>
        /// فلگ نظرسنجی در حال اجراست یا خیر
        /// Nullable
        /// </summary>
        public bool? opinionPollIsRunning { get; set; }
        /// <summary>
        /// فلگ مشخص کننده نتایج نظرسنجی قابل مشاهده عموم هست یا خیر
        /// Nullable
        /// </summary>
        public bool? resultIsPublic { get; set; }
        //itemId { get; set; }
        //itemBarcode { get; set; }
        //item_title { get; set; }
        //itemGrp_title { get; set; }
        //picUrl_thumb { get; set; }
        //picUrl_full { get; set; }
        /// <summary>
        /// میانگین نظرسنجی
        /// Nullable
        /// </summary>
        public decimal? totalAvg { get; set; }
        /// <summary>
        /// میزان مشارکت کننده
        /// Nullable
        /// </summary>
        public int? countOfparticipants { get; set; }
    }
    /// <summary>
    /// مدل پایه تب عمومی
    /// </summary>
    public class CommonTabItem
    {
        /// <summary>
        /// عنوان کالا
        /// </summary>
        public string itemTitle { get; set; }
        /// <summary>
        /// توضیحات فنی کالا
        /// </summary>
        public string technicalItem { get; set; }
        /// <summary>
        /// گروه کالا
        /// </summary>
        public IdTitleValue<long> itemGroup { get; set; }
        /// <summary>
        /// نوع گروه کالا
        /// 1. kala
        /// 2. persenel
        /// 3. job
        /// 4. object
        /// 5. organize
        /// 6. branch
        /// </summary>
        [Obsolete(message: "depricated. use itemType instead. this one will be removed.")]
        public short grpType { get; set; }
        /// <summary>
        /// بارکد رسمی کالا
        /// </summary>
        public string barcode { get; set; }
        /// <summary>
        /// بارکد محلی کالا در فروشگاه
        /// </summary>
        public string localBarcode { get; set; }
        /// <summary>
        /// کالا در لیست کالاهای فروشگاه نشان داده شود یا خیر؟
        /// </summary>
        public bool dontShowingStoreItems { get; set; }
        /// <summary>
        /// امکان ارسال کالا با پیک؟
        /// </summary>
        public bool deliveriable { get; set; }
        /// <summary>
        /// بارکد یکتا
        /// </summary>
        public string uniqueBarcode { get; set; }
        /// <summary>
        /// jensiat 
        /// 0 : zan
        /// 1 : mard
        /// </summary>
        public bool? sex { get; set; } = null;
        /// <summary>
        /// ostan
        /// </summary>
        public IntTitleValue state { get; set; } = null;
        /// <summary>
        /// مدل شهر
        /// </summary>
        public IntTitleValue city { get; set; } = null;
        /// <summary>
        /// تحصیلات پرسنل
        /// </summary>
        public IdTitleValue<int?> education { get; set; }
        /// <summary>
        /// شهرستان / روستا
        /// </summary>
        public string village { get; set; } = null;
        /// <summary>
        /// واحد خدمت
        /// </summary>
        public string unitName { get; set; } = null;
        /// <summary>
        /// فلگ نمایش/عدم نمایش شناسه یکتا
        /// Nullable
        /// </summary>
        public bool? dontShowUniqBarcode { get; set; } = false;
        /// <summary>
        /// کاربردی ندارد - حذف میشود به زودی
        /// </summary>
        public bool? displayMode { get; set; } = false;
        /// <summary>
        /// مدل مکان
        /// </summary>
        public ItemLocation location { get; set; }
        /// <summary>
        /// مدل جدول TYP_OBJECT_GRP
        /// </summary>
        public IdTitleValue<long?> fk_ObjectGrpId { get; set; }
        /// <summary>
        /// نوع کالا
        /// </summary>
        public short itemType { get; set; }
        /// <summary>
        /// دسته بندی داخلی (شخصی) کالا
        /// </summary>
        public List<IdTitleValue<long?>> storeCustomCategory { get; set; }
        /// <summary>
        /// برنامه حضور دارد؟
        /// </summary>
        public bool? hasSchedule { get; internal set; }
        /// <summary>
        /// برنامه امروز
        /// </summary>
        public string todaySchedule { get; internal set; }
        /// <summary>
        /// در حال حاضر حضور دارد
        /// </summary>
        public bool? currentShiftStatus { get; internal set; }
        /// <summary>
        /// پارامتر تعیین کننده برای پرسنل برای جستجو در سرویس سطح 1
        /// </summary>
        public bool findJustBarcode { get; set; }
        /// <summary>
        /// حداکثر تعداد نظرات مجاز یک کاربر برای یک کالا
        /// میتواند نال باشد
        /// </summary>
        public int? commetnCntPerUser { get; set; }
        /// <summary>
        /// حداکثر تعداد نظرات مجاز یک کاربر در طول یک روز برای یک کالا
        /// میتواند نال باشد
        /// </summary>
        public int? commentCntPerDayPerUser { get; set; }
        /// <summary>
        /// امکان ویرایش کالای مرجع
        /// </summary>
        public bool canUpdateAccessLevel { get; set; }
        /// <summary>
        /// قفل کردن آیتم و جلوگیری از ویرایش
        /// </summary>
        public bool isLocked { get; set; }

    }
    /// <summary>
    /// مدل موجودی و قیمت
    /// </summary>
    public class SohInfoTabItem
    {
        /// <summary>
        /// واحد سنجش کالا
        /// </summary>
        public IdTitleValue<int> unit { get; set; }
        /// <summary>
        /// تعداد
        /// </summary>
        public decimal quantity { get; set; }
        /// <summary>
        /// نقطه سفارش
        /// </summary>
        public decimal orderPoint { get; set; }
        /// <summary>
        /// درصد پیش پرداخت
        /// </summary>
        public int prepaymentPercentage { get; set; }
        /// <summary>
        /// درصد جریمه کنسلی 
        /// حداکثر تا 50 درصد
        /// </summary>
        public int penaltyCancellationPercentage { get; set; }
        /// <summary>
        /// مبلغ پایه
        /// </summary>
        public decimal price { get; set; }
        /// <summary>
        /// تاریخ اعتبار سفارش (تعداد روز)
        /// </summary>
        public int periodicValidDayOrder { get; set; }
        /// <summary>
        /// تعداد تخفیف بر پایه خرید
        /// </summary>
        public int discountPerPurcheseNumeric { get; set; }
        /// <summary>
        /// درصد تخفیف بر پایه خرید
        /// </summary>
        public decimal discountPerPurchesePercently { get; set; }
        /// <summary>
        /// فلگ غیرقابل فروش
        /// </summary>
        public bool notForSellingItem { get; set; }
        /// <summary>
        /// شامل مالیات می شود؟
        /// </summary>
        public bool includesTax { get; set; }
        /// <summary>
        /// مبلغ پایه به همراه واحد ارزی
        /// </summary>
        public string price_dsc { get; set; }
        /// <summary>
        /// مبلغ تخفیف به همراه واحد ارزی
        /// </summary>
        public string discountprice_dsc { get; set; }
        /// <summary>
        /// درصد تخفیف عمومی
        /// </summary>
        public decimal promotionPercent { get; set; }
        /// <summary>
        /// مبلغ تخفیف عمومی به همراه واحد ارزی
        /// </summary>
        public string promotionDsc { get; set; }
    }
    /// <summary>
    /// مدل اطلاعات پایه
    /// </summary>
    public class BasicItemTab
    {
        /// <summary>
        /// مدل کشور تولید کننده
        /// </summary>
        public IdTitleValue<int> country { get; set; }
        /// <summary>
        /// نام شرکت سازنده
        /// </summary>
        public string manufacturerCo { get; set; }
        /// <summary>
        /// نام شرکت وارد کننده
        /// </summary>
        public string importerCo { get; set; }
    }
    /// <summary>
    /// مدل گارانتی
    /// </summary>
    public class WarantyItemTab
    {
        /// <summary>
        /// شناسه گارانتی
        /// </summary>
        public long warrantyId { get; set; }
        /// <summary>
        /// نام شرکت گارانتی کننده
        /// </summary>
        public string WarantyCo { get; set; }
        /// <summary>
        /// مدت زمان گارانتی تعداد روز
        /// </summary>
        public int durationdayWaranty { get; set; }
        /// <summary>
        /// مبلغ گارانتی
        /// </summary>
        public decimal WarantyPrice { get; set; }
        /// <summary>
        /// مبلغ گارانتی به همراه واحد ارزی
        /// </summary>
        public string WarantyPrice_dsc { get; set; }
    }
    /// <summary>
    /// مدل مشخصات فنی
    /// </summary>
    public class TechnicalInfoItemTab
    {
        /// <summary>
        /// شناسه مشخصه فنی
        /// </summary>
        public int technicalInfoId { get; set; }
        /// <summary>
        /// مقدار مشخصه فنی
        /// </summary>
        public string strValue { get; set; }
        /// <summary>
        /// شناسه ارتباطی با مشخصه فنی جدولی
        /// </summary>
        public long technicalTableValueId { get; set; }
        /// <summary>
        /// کلید مشخصه
        /// </summary>
        public string key { get; set; }
        /// <summary>
        /// مقدار 
        /// </summary>
        public string val { get; set; }
        /// <summary>
        /// توضیحات در رابطه با مشخصه فنی
        /// </summary>
        public string description { get; set; }
        /// <summary>
        /// عنوان مشخصه فنی
        /// </summary>
        public string title { get; set; }
        /// <summary>
        /// نوع مشخصه فنی :
        /// 1. حروفی
        /// 2.عددی
        /// 3.انتخابی
        /// 4.جدولی
        /// 5.سرفصل
        /// </summary>
        public int type { get; set; }
        /// <summary>
        /// ترتیب نمایش 
        /// </summary>
        public int? order { get; set; }
    }
    /// <summary>
    /// مدل پایه اسناد و تصاویر آیتم
    /// </summary>
    public class DocumentItemTab
    {
        /// <summary>
        /// شناسه
        /// </summary>
        public Guid uid { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public Guid id { get; set; }
        /// <summary>
        /// تصویر پیشفرض
        /// </summary>
        public bool isDefault { get; set; }
        /// <summary>
        /// لینک دانلود
        /// </summary>
        public string downloadLink { get; set; }
        /// <summary>
        /// لینک دانلود تصویر بندانگشتی
        /// </summary>
        public string thumbImageUrl { get; set; }

    }
    /// <summary>
    /// 
    /// </summary>
    public class StringModel
    {
        /// <summary>
        /// 
        /// </summary>
        public string str { get; set; }
    }
    /// <summary>
    /// مدل مشخصات فنی کالا
    /// </summary>
    public class TechnicalInfoItemTyp
    {
        /// <summary>
        /// شناسه مشخصه
        /// </summary>
        public long technicalInfoId { get; set; }
        /// <summary>
        /// عنوان مشخصه
        /// </summary>
        public string technicalInfoTitle { get; set; }
        /// <summary>
        /// نوع مشخصه
        /// </summary>
        public int type { get; set; }
        /// <summary>
        /// شناسه مشخصه فنی فرزند
        /// </summary>
        public long childTechnicalInfoId { get; set; }
        /// <summary>
        /// عنوان مشخصه فنی فرزند
        /// </summary>
        public string childTechnicalInfoTitle { get; set; }
        /// <summary>
        /// شناسه مشخصه فنی جدولی
        /// </summary>
        public int c_fk_technicalinfo_table_id { get; set; }
        /// <summary>
        /// Nullable
        /// </summary>
        public long? fk_technicalInfoValues_tblValue { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string strValue { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string fk_technicalInfoValues_tblValue_dsc { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public bool isPublic { get; set; }

    }
    /// <summary>
    /// مدل مقادیر مشخصات فنی کالا
    /// </summary>
    public class TechnicalInfoValue
    {
        /// <summary>
        /// شناسه مقدار
        /// </summary>
        public long id { get; set; }
        /// <summary>
        /// توضیحات
        /// </summary>
        public string value { get; set; }
    }
    /// <summary>
    /// مدل سرویس های جستجوی لیست کالا
    /// </summary>
    public class SearchItemListModel : searchParameterModel
    {
        /// <summary>
        /// شناسه گروه
        /// </summary>
        public long? itemGrpId { get; set; }

        /// <summary>
        /// شناسه کالا
        /// </summary>
        public long? itemId { get; set; }

        /// <summary>
        /// شناسه فروشگاه
        /// </summary>
        public long? cityId { get; set; }

        /// <summary>
        /// شناسه شهر
        /// </summary>
        public long? storeId { get; set; }

        /// <summary>
        /// فقط فروشگاه های موجودی دار
        /// </summary>
        public bool justAvailableGoods { get; set; }
        /// <summary>
        /// کف قیمت
        /// </summary>
        public decimal? minPrice { get; set; }
        /// <summary>
        /// سقف قیمت
        /// </summary>
        public decimal maxPrice { get; set; }
        /// <summary>
        /// حداکثر فاصله تا فروشگاه
        /// </summary>
        public int? distance { get; set; }
        /// <summary>
        /// مرتب سازی بر اساس قیمت
        /// </summary>
        public bool? orderByPrice { get; set; }
        /// <summary>
        /// مرتب سازی بر اساس فاصله
        /// </summary>
        public bool? orderByDistance { get; set; }
        /// <summary>
        /// مرتب سازی بر اساس حروف الفبا
        /// </summary>
        public bool? orderByAlphabetic { get; set; }
        /// <summary>
        /// در جستجوی لیست کالای شماره 2 استفاده می شود
        /// </summary>
        public bool orderByStoreState { get; set; }
        /// <summary>
        /// در جستجوی لیست کالای شماره 2 استفاده می شود
        /// </summary>
        public bool justOpenStore { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public float? curLat { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public float? curLng { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public float? centerLat { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public float? centerLng { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public long categoryId { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public bool onlyDiscountItem { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string searchBarcode { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public bool withMinMax { get; set; }
    }
    /// <summary>
    /// 
    /// </summary>
    public class getOpinionItemListModel : searchParameterModel
    {
        /// <summary>
        /// 
        /// </summary>
        public long itemId { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public long? storeId { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int filterStatus { get; set; }
    }
    /// <summary>
    /// 
    /// </summary>
    public class ItemColorModel
    {
        /// <summary>
        /// شناسه رنگ کالا
        /// </summary>
        public string color { get; set; }
        /// <summary>
        /// نام رنگ ، فقط در هنگام سرویس نمایش اطلاعات کالا استفاده می شود
        /// </summary>
        public string colorName { get; set; }
        /// <summary>
        /// فعال بودن یا نبودن
        /// </summary>
        public bool isActive { get; set; }
        /// <summary>
        /// مشخص کننده مبلغ مازاد بر مبلغ پایه
        /// </summary>
        public decimal colorCost { get; set; }
    }
    /// <summary>
    /// مدل پایه اندازه
    /// </summary>
    public class ItemSizeModel
    {
        /// <summary>
        /// اطلاعات سایز
        /// </summary>
        public string sizeInfo { get; set; }
        /// <summary>
        /// فعال/غیرفعال
        /// </summary>
        public bool isActive { get; set; }
        /// <summary>
        /// مشخص کننده مبلغ مازاد بر مبلغ پایه
        /// </summary>
        public decimal sizeCost { get; set; }
    }
    /// <summary>
    /// مدل پایه سرویس دریافت نظرسنجی
    /// </summary>
    public class GetOpinionListResultModel
    {
        /// <summary>
        /// میانگین امتیاز
        /// </summary>
        public decimal userRateAverrage { get; set; }
        /// <summary>
        /// تعداد نظرات
        /// </summary>
        public int commentMember { get; set; }
        /// <summary>
        /// اطلاعات ارزیابی
        /// </summary>
        public List<EvaluationModel> opinionInfo { get; set; }

    }
    /// <summary>
    /// مدل ارزیابی
    /// </summary>
    public class EvaluationModel
    {
        /// <summary>
        /// شناسه
        /// </summary>
        public long id { get; set; }
        /// <summary>
        /// نام شرکت کننده
        /// </summary>
        public string usrName { get; set; }
        /// <summary>
        /// تاریخ
        /// </summary>
        public string date { get; set; }
        /// <summary>
        /// امتیاز
        /// </summary>
        public decimal rate { get; set; }
        /// <summary>
        /// متن نظر
        /// </summary>
        public string comment { get; set; }
        /// <summary>
        /// مدل وضعیت
        /// </summary>
        public IdTitleValue<long> status { get; set; }
    }
    /// <summary>
    /// مدل پایه سرویس افزودن به مشخصه فنی کالا
    /// </summary>
    public class ItemTechnicalInfoModel
    {
        /// <summary>
        /// 
        /// </summary>
        public List<TechnicalInfoItemTyp> itemTechnicalInfo { get; set; }
        /// <summary>
        /// شناسه آیتم
        /// </summary>
        public long itemId { get; set; }
       
    }
    /// <summary>
    /// 
    /// </summary>
    public class WarrantyItemModel
    {
        /// <summary>
        /// لیست از گارانتی ها
        /// </summary>
        public List<WarantyItemTab> warranties { get; set; }
        /// <summary>
        /// شناسه آیتم
        /// </summary>
        public long itemId { get; set; }
    }
    public class addWarantinBindingModel
    {
        /// <summary>
        ///  گارانتی 
        /// </summary>
        public WarantyItemTab warranty { get; set; }
        /// <summary>
        /// شناسه آیتم
        /// </summary>
        public long itemId { get; set; }
    }
    /// <summary>
    /// مدل بارکد
    /// </summary>
    public class BarcodeModel : searchParameterModel
    {
        /// <summary>
        /// بارکد رسمی
        /// </summary>
        public string Barcode { get; set; }
        /// <summary>
        /// بارکد محلی چک شود یا خیر ؟
        /// </summary>
        public bool CheckLocalBarcode { get; set; } = false;
        /// <summary>
        /// جستجو فقط در لیست کالاهای پنل
        /// </summary>
        public bool? searchInMyItems { get; set; }
    }



}
