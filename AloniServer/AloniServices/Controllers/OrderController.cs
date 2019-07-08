using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// oreder api
    /// </summary>
    [RoutePrefix("Order")]
    public class OrderController : AdvancedApiController
    {
        /// <summary>
        /// سرویس اضافه کردن / ویرایش کالا (ردیف) به سبد خرید
        /// </summary>
        /// <param name="model">
        /// 
        /// </param>
        /// <returns></returns>
        [Route("cart_addUpdateItem")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addUpdateItem(cart_addUpdateItemBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_cart_addUpdateItem", "OrderController_cart_addUpdateItem", checkAccess: false))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //repo.cmd.Parameters.AddWithValue("@customerUserId", model.customerUserId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", model.storeId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@colorId", model.colorId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@sizeId", model.sizeId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@warrantyId", model.warrantyId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@qty", model.qty.getDbValue());
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId.getDbValue());


                var sqlparam_orderId = repo.cmd.Parameters.Add("@orderId", SqlDbType.BigInt);
                sqlparam_orderId.Direction = ParameterDirection.Output;



                var sqlparam_orderId_str = repo.cmd.Parameters.Add("@orderId_str", SqlDbType.VarChar, 36);
                sqlparam_orderId_str.Direction = ParameterDirection.Output;


                var sqlparam_orderDtlRowId = repo.cmd.Parameters.Add("@orderDtlRowId", SqlDbType.Int);
                sqlparam_orderDtlRowId.Direction = ParameterDirection.Output;
                //sqlparam_orderId.Value = model.orderId.getDbValue();

                var sqlparam_orderHdrId = repo.cmd.Parameters.Add("@orderHdrId", SqlDbType.BigInt);
                sqlparam_orderHdrId.Direction = ParameterDirection.Output;
                //sqlparam_orderHdrId.Value = model.orderHdrId.getDbValue();


                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { orderId = sqlparam_orderId.Value.dbNullCheckLong(), orderId_str = sqlparam_orderId_str.Value.dbNullCheckString(), orderHdrId = sqlparam_orderHdrId.Value.dbNullCheckLong(), orderDtlRowId = sqlparam_orderDtlRowId.Value });
            }

        }
        /// <summary>
        /// سرویس حذف آیتم از سبد خرید
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("cart_removeItem")]
        [Exception]
        [HttpPost]
        public IHttpActionResult cart_removeItem(cart_removeItemBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_cart_removeItem", "OrderController_cart_removeItem"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (repo.accessDenied)
                //    return new ForbiddenActionResult();
                //repo.cmd.Parameters.AddWithValue("@orderId", model.orderId);
                repo.cmd.Parameters.AddWithValue("@rowId", model.rowId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId.getDbValue());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }

        }
        /// <summary>
        /// سرویس حذف سبد خرید کاربر
        /// </summary>
        /// <param name="model">
        /// str : شناسه مرجع سفارش
        /// </param>
        /// <returns></returns>
        [Route("cart_remove")]
        [Exception]
        [HttpPost]
        public IHttpActionResult cart_remove(cart_removeBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_cart_remove", "OrderController_cart_remove"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (repo.accessDenied)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId.getDbValue());
                //repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }

        }
        /// <summary>
        /// بروز رسانی اطلاعات روش ارسال مرسوله قبل از ثبت نهایی سفارش در اپ خریدار
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("cart_setDeliveryMethode")]
        [Exception]
        [HttpPost]
        public IHttpActionResult cart_setDeliveryMethode(cart_setDeliveryMethodeBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_cart_setDeliveryMethode", "OrderController_cart_setDeliveryMethode"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@userSessionId", sessionId.getDbValue());
                //repo.cmd.Parameters.AddWithValue("@orderId", model.orderId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId);
                repo.cmd.Parameters.AddWithValue("@deliveryTypeId", model.deliveryTypeId.getDbValue());
                //repo.cmd.Parameters.AddWithValue("@deliveryLoc_lat", model.deliveryLoc_lat.getDbValue());
                //repo.cmd.Parameters.AddWithValue("@deliveryLoc_lng", model.deliveryLoc_lng.getDbValue());
                //repo.cmd.Parameters.AddWithValue("@deliveryAddress", model.deliveryAddress.getDbValue());
                //repo.cmd.Parameters.AddWithValue("@fk_state_deliveryStateId", model.fk_state_deliveryStateId.getDbValue());
                //repo.cmd.Parameters.AddWithValue("@fk_city_deliveryCityId", model.fk_city_deliveryCityId.getDbValue());
                //repo.cmd.Parameters.AddWithValue("@delivery_postalCode", model.delivery_postalCode.getDbValue());
                //repo.cmd.Parameters.AddWithValue("@delivery_callNo", model.delivery_callNo.getDbValue());
                repo.cmd.Parameters.AddWithValue("@fk_orderAddress_id", model.fk_orderAddress_id.dbNullCheckLong());

                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }

        }
        /// <summary>
        /// دریافت لیست آدرس های تحویل که در سفارشات پیشین مشخص شده اند.
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addressGetList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addressGetList(searchParameterModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);

            var retlist = new List<string>();
            using (var repo = new Repo(this, "SP_order_addressGetList", "OrderController_addressGetList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.ExecuteReader();

                while (repo.sdr.Read())
                    retlist.Add(repo.sdr["deliveryAddress"].dbNullCheckString());
            }
            return Ok(new { addresses = retlist });
        }
        /// <summary>
        /// ردیافت روش های مجاز برای پرداخت
        /// و همچنین انواع حالات پرداخت از لحاظ کامل / پیش پرداخت
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("cart_getPaymentTypes")]
        [Exception]
        [HttpPost]
        public IHttpActionResult cart_getPaymentTypes(cart_getPaymentTypesBindingModel model)
        {
            //if (model.orderId == null)
            //    return new BadRequestActionResult("order id must be set!");
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_cart_getPaymentTypes", "OrderController_cart_getPaymentTypes", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId.getDbValue());
                repo.ExecuteReader();
                if (repo.sdr.Read())
                {
                    return Ok(new
                    {
                        hasPrePayment = repo.sdr["hasPrePayment"].dbNullCheckBoolean(),
                        cash = repo.sdr["cash"].dbNullCheckBoolean(),
                        credit = repo.sdr["credit"].dbNullCheckBoolean(),
                        online = repo.sdr["online"].dbNullCheckBoolean(),
                    });
                }
                else return new NotFoundActionResult("");

                //repo.ExecuteAdapter();
                //var result = repo.ds.Tables.Count > 0 ? repo.ds.Tables[0] : null;
                //if (result != null)
                //{
                //    return Ok(result.AsEnumerable().Select(row =>
                //    new
                //    {
                //        name = Convert.ToString(row.Field<object>("name")),
                //        staff = Convert.ToString(row.Field<object>("staff")),
                //        actionType = Convert.ToString(row.Field<object>("actiontype")),
                //        dateTime = Convert.ToString(row.Field<object>("date_time"))
                //    }).ToList());
                //}
                //return Ok(new { msg = "no result" });
            }
        }
        /// <summary>
        /// تایید سبد خرید
        /// در صورتی که نوع پرداخت آنلاین انتخاب شده باشد
        /// آدرس صفحه پرداخت در خروجی ظاهر می شود.
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("cart_submit")]
        [Exception]
        [HttpPost]
        public IHttpActionResult cart_submit(cart_submitBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_cart_submit", "OrderController_cart_submit"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (repo.accessDenied)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@userSessionId", sessionId.getDbValue());
                //repo.cmd.Parameters.AddWithValue("@orderId", model.orderId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@OrderId", model.orderId);
                repo.cmd.Parameters.AddWithValue("@paymentMethode", model.paymentMethode.getDbValue());
                repo.cmd.Parameters.AddWithValue("@paymentType", model.paymentType.getDbValue());

                var sqlparam_paymentUrl = repo.cmd.Parameters.Add("@paymentUrl", SqlDbType.VarChar, 255);
                sqlparam_paymentUrl.Direction = ParameterDirection.Output;



                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg, paymentUr = sqlparam_paymentUrl.Value.dbNullCheckString() });
            }
        }
        /// <summary>
        /// سوابق خرید در اپ خریدار : دریافت لیست سفارشات در جریان کاربر
        /// سفارشاتی که هنوز مانده تحویل نشده دارند
        /// لغو نشده اند
        /// و یا از دوره ضمانت پرداخت امن آنها زمان باقی است
        /// </summary>
        /// <returns></returns>
        //[Route("getUserActiveOrderList")]
        [Exception]
        [HttpPost]
        [Obsolete]
        public IHttpActionResult getUserActiveOrderList()
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getUserOrderList", "OrderController_getUserActiveOrderList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@activeOrder", true);
                repo.ExecuteAdapter();
                var result = repo.ds.Tables.Count > 0 ? repo.ds.Tables[0] : null;
                if (result != null)
                {
                    return Ok(result.AsEnumerable().Select(row =>
                    new userOrderModel()
                    {
                        date = Convert.ToString(row.Field<object>("date")),
                        price = Convert.ToString(row.Field<object>("mabFactor")),
                        storeTitle = Convert.ToString(row.Field<object>("title")),
                        orderId = Convert.ToString(row.Field<object>("orderId")),
                        status = new IdTitleValue<int> { id = Convert.ToInt32(row.Field<object>("statusId") is DBNull ? 0 : row.Field<object>("statusId")), title = Convert.ToString(row.Field<object>("status_dsc")) },
                        details = repo.ds.Tables[1].AsEnumerable().Select(i =>
                        new orderDtlModel { color = Convert.ToString(i.Field<object>("color")), itemName = Convert.ToString(i.Field<object>("title")), warranty = Convert.ToString(i.Field<object>("warranty")), qty = Convert.ToDecimal(i.Field<object>("deciaml")), image = Convert.ToString(i.Field<object>("image_")), thumbImage = Convert.ToString(i.Field<object>("thumbcompeleteLink")) }).ToList()
                    }).ToList());
                }
                return Ok(new { msg = "no result" });
            }

        }
        ///// <summary>
        ///// سوابق خرید در اپ خریدار : دریافت لیست سفارشات قبلی (مختومه) کاربر
        ///// </summary>
        ///// <returns></returns>
        ////[Route("getUserOldOrderList")]
        //[Exception]
        //[HttpPost]
        //[Obsolete]
        //public IHttpActionResult getHistoryOrderList()
        //{

        //    if (!ModelState.IsValid)
        //        return new BadRequestActionResult(ModelState.Values);
        //    using (var repo = new Repo(this, "SP_getUserOrderList", "OrderController_getUserActiveOrderList", initAsReader: true))
        //    {
        //        if (repo.unauthorized)
        //            return new UnauthorizedActionResult("Unauthorized!");
        //        //if (!repo.hasAccess)
        //        //    return new ForbiddenActionResult();
        //        repo.ExecuteAdapter();
        //        var result = repo.ds.Tables.Count > 0 ? repo.ds.Tables[0] : null;
        //        if (result != null)
        //        {
        //            return Ok(result.AsEnumerable().Select(row =>
        //            new userOrderModel()
        //            {
        //                date = Convert.ToString(row.Field<object>("date")),
        //                price = Convert.ToString(row.Field<object>("mabFactor")),
        //                storeTitle = Convert.ToString(row.Field<object>("title")),
        //                orderId = Convert.ToString(row.Field<object>("orderId")),
        //                status = new IdTitleValue<int> { id = Convert.ToInt32(row.Field<object>("statusId") is DBNull ? 0 : row.Field<object>("statusId")), title = Convert.ToString(row.Field<object>("status_dsc")) },
        //                details = repo.ds.Tables[1].AsEnumerable().Select(i => new orderDtlModel { color = Convert.ToString(i.Field<object>("color")), itemName = Convert.ToString(i.Field<object>("title")), warranty = Convert.ToString(i.Field<object>("warranty")), qty = Convert.ToDecimal(i.Field<object>("deciaml")), image = Convert.ToString(i.Field<object>("image_")) }).ToList()
        //            }).ToList());
        //        }
        //        return Ok(new { msg = "no result" });
        //    }

        //}
        ///// <summary>
        ///// سرویس دریافت لیست سفارشات فروشگاه
        ///// در اپ فروشنده
        ///// </summary>
        ///// <returns></returns>
        ////[Route("getStoreOrderList")]
        //[Exception]
        //[HttpPost]
        //[Obsolete]
        //public IHttpActionResult getStoreOrderList(getStoreOrderList model)
        //{

        //    if (!ModelState.IsValid)
        //        return new BadRequestActionResult(ModelState.Values);
        //    using (var repo = new Repo(this, "SP_getStoreActiveOrderList", "OrderController_getStoreActiveOrderList", initAsReader: true))
        //    {
        //        if (repo.unauthorized)
        //            return new UnauthorizedActionResult("Unauthorized!");
        //        //if (!repo.hasAccess)
        //        //    return new ForbiddenActionResult();
        //        repo.cmd.Parameters.AddWithValue("@storeId", storeId);
        //        repo.cmd.Parameters.AddWithValue("@search", model.search);
        //        repo.cmd.Parameters.AddWithValue("@state", model.state);
        //        repo.ExecuteAdapter();
        //        var result = repo.ds.Tables.Count > 0 ? repo.ds.Tables[0] : null;
        //        if (result != null)
        //        {
        //            return Ok(result.AsEnumerable().Select(row =>
        //            new
        //            {
        //                customerName = Convert.ToString(row.Field<object>("customerName")),
        //                date = Convert.ToString(row.Field<object>("date_")),
        //                price = Convert.ToString(row.Field<object>("mabFactor")),
        //                orderId = Convert.ToString(row.Field<object>("orderId")),
        //                status = new IdTitleValue<int> { id = Convert.ToInt32(row.Field<object>("statusId") is DBNull ? 0 : row.Field<object>("statusId")), title = Convert.ToString(row.Field<object>("status_dsc")) },
        //                paymentSatus = Convert.ToString(row.Field<object>("paymentSatus")),
        //                delivery = Convert.ToBoolean(row.Field<object>("delivery")),
        //                id = Convert.ToInt64(row.Field<object>("id")),
        //                details = (from a in repo.ds.Tables[0].AsEnumerable() join b in repo.ds.Tables[1].AsEnumerable() on Convert.ToInt64(a.Field<object>("id")) equals Convert.ToInt64(b.Field<object>("fk_orderHdr_id")) select Convert.ToInt32(b.Field<object>("countItem"))).FirstOrDefault()
        //            }).ToList());
        //        }
        //        return Ok(new { msg = "no result" });
        //    }

        //}
        /// <summary>
        /// depricated. pls use the latest version.
        /// دریافت لیست سفارشات یک فروشگاه خاص (اپ مارکتر)
        /// </summary>
        /// <returns></returns>
        [Route("getListOfSpecificStore")]
        [Exception]
        [HttpPost]
        [Obsolete(message: "depricated. pls use the latest version.")]
        public IHttpActionResult getListOfSpecificStore(order_getListOfSpecificStoreBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_getListOfSpecificStore", "OrderController_getListOfSpecificStore", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                DataTable dtStatuses = new DataTable();
                DataRow row_;
                dtStatuses.Columns.Add("id");
                foreach (var item in model.statuses)
                {
                    row_ = dtStatuses.NewRow();
                    row_["id"] = item;
                    dtStatuses.Rows.Add(row_);
                }

                //repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@includeDtls", model.includeDtls.getDbValue());
                repo.cmd.Parameters.AddWithValue("@isReviewed", model.isReviewed.getDbValue());
                repo.cmd.Parameters.AddWithValue("@sortType", model.sortType.dbNullCheckShort());

                var param = repo.cmd.Parameters.AddWithValue("@statuses", dtStatuses);
                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteAdapter();
                var tb_base = repo.ds.Tables[0];
                var tb_dtls = repo.ds.Tables.Count >= 2 ? repo.ds.Tables[1] : null;
                //var storeInfo = repo.ds.Tables[1];
                //var storephone = repo.ds.Tables[2];
                //var itemInfo = repo.ds.Tables[3];
                return Ok(
                    tb_base.AsEnumerable().Select(b => new
                    {
                        orderId = b.Field<object>("orderId"),
                        orderId_str = b.Field<object>("orderId_str"),
                        //lastOrderHdrId = b.Field<object>("lastOrderHdrId"),
                        countOfActiveDtls = b.Field<object>("countOfActiveDtls"),
                        orderDate = b.Field<object>("orderDate"),
                        orderTime = b.Field<object>("orderTime"),
                        orderSubmitDateTime = b.Field<object>("orderSubmitDateTime"),
                        paymentMethode = b.Field<object>("paymentMethode"),
                        paymentMethode_dsc = b.Field<object>("paymentMethode_dsc"),
                        paymentStatus = b.Field<object>("paymentStatus"),
                        paymentStatus_dsc = b.Field<object>("paymentStatus_dsc"),
                        isTwoStepPayment = b.Field<object>("isTwoStepPayment"),
                        isSecurePayment = b.Field<object>("isSecurePayment"),
                        dsc = b.Field<object>("dsc"),
                        totalAmountWithTax_withoutDiscount = b.Field<object>("sum_cost_payable_withTax_withoutDiscount"),
                        totalAmountWithTax_withDiscount = b.Field<object>("sum_cost_payable_withTax_withDiscount"),
                        totalAmountWithoutTax_withoutDiscount = b.Field<object>("sum_cost_payable_withoutTax_withoutDiscount"),
                        total_payment_payable = b.Field<object>("total_payment_payable"),
                        cost_Delivery = b.Field<object>("sum_cost_delivery_remaining"),
                        totalTaxAmount = b.Field<object>("sum_cost_totalTax_info"),
                        totalDiscount = b.Field<object>("sum_cost_discount"),
                        totalPayableAmount = b.Field<object>("total_remaining_payment_payable"),
                        reviewDateTime = b.Field<object>("reviewDateTime"),
                        //storeId = b.Field<object>("storeId"),
                        //storeTitle = b.Field<object>("storeTitle"),
                        //sroeTitle_second = b.Field<object>("sroeTitle_second"),
                        //storeLogo = b.Field<object>("storeLogo"),
                        //storeLogo_thumb = b.Field<object>("storeLogo_thumb"),
                        //storeAddress = b.Field<object>("storeAddress"),
                        //storePhone = b.Field<object>("storePhone"),
                        //storeLoc_Lat = b.Field<object>("storeLoc_Lat"),
                        //soreLoc_Lon = b.Field<object>("soreLoc_Lon"),
                        //storePic = b.Field<object>("storePic"),
                        //storePic_thumb = b.Field<object>("storePic_thumb"),
                        deliveryAddress = b.Field<object>("deliveryAddress"),
                        deliveryLoc_Lat = b.Field<object>("deliveryLoc_Lat"),
                        deliveryLoc_Lng = b.Field<object>("deliveryLoc_Lng"),
                        distance = b.Field<object>("distance"),
                        deliveryLoc_postalCode = b.Field<object>("deliveryLoc_postalCode"),
                        deliveryLoc_callNo = b.Field<object>("deliveryLoc_callNo"),
                        deliveryLoc_city = b.Field<object>("deliveryLoc_city"),
                        deliveryLoc_state = b.Field<object>("deliveryLoc_state"),
                        //cartIsShareable = b.Field<object>("cartIsShareable"),
                        deliveryType = b.Field<object>("deliveryType"),

                        deliveryLoc_city_dsc = b.Field<object>("deliveryLoc_city_dsc"),
                        deliveryLoc_state_dsc = b.Field<object>("deliveryLoc_state_dsc"),
                        deliveryType_dsc = b.Field<object>("deliveryType_dsc"),
                        status = b.Field<object>("status"),
                        status_dsc = b.Field<object>("status_dsc"),
                        cstmrName = b.Field<object>("cstmrName"),
                        isMultiPartDelivery = b.Field<object>("isMultiPartDelivery").dbNullCheckBoolean(),
                        isSent = b.Field<object>("isSent").dbNullCheckBoolean(),
                        isDelivered = b.Field<object>("isDelivered").dbNullCheckBoolean(),
                        currency = b.Field<object>("currency"),
                        newTicketCount = b.Field<object>("newTicketCount"),

                        sum_sendRemaining = b.Field<object>("sum_sendRemaining"),
                        sum_deliveryRemaining = b.Field<object>("sum_deliveryRemaining"),
                        dtls = tb_dtls == null ? null : from d in tb_dtls.AsEnumerable()
                                                        where d.Field<long>("orderId") == b.Field<long>("orderId")
                                                        select new
                                                        {
                                                            //orderDtlId = d.Field<object>("orderDtlId"),
                                                            orderDtlRowId = d.Field<object>("orderDtlRowId"),
                                                            itemId = d.Field<object>("itemId"),
                                                            itemTitle = d.Field<object>("itemTitle"),
                                                            technicalTitle = d.Field<object>("technicalTitle"),
                                                            itemPic_thumb = d.Field<object>("itemPic_thumb"),
                                                            itemPic = d.Field<object>("itemPic"),
                                                            qty = d.Field<object>("qty"),
                                                            payableAmountWithoutTaxWithoutDiscount = d.Field<object>("payableAmountWithoutTaxWithoutDiscount"),
                                                            discountVal = d.Field<object>("discountVal"),
                                                            payableAmountWithoutTax = d.Field<object>("payableAmountWithoutTax"),
                                                            color = d.Field<object>("color"),
                                                            color_dsc = d.Field<object>("color_dsc"),
                                                            size = d.Field<object>("size"),
                                                            warranty = d.Field<object>("warranty"),
                                                            warranty_dsc = d.Field<object>("warranty_dsc"),
                                                            ManufacturerCo = d.Field<object>("ManufacturerCo"),
                                                            importerCo = d.Field<object>("importerCo"),
                                                            cost_oneUnit_withoutDiscount = d.Field<object>("cost_oneUnit_withoutDiscount"),
                                                            cost_oneUnit_withoutDiscount_dsc = d.Field<object>("cost_oneUnit_withoutDiscount_dsc"),
                                                            discount_percent = d.Field<object>("discount_percent"),
                                                            taxRate = d.Field<object>("taxRate"),
                                                            cost_totalTax_info = d.Field<object>("cost_totalTax_info"),
                                                            unitDsc = d.Field<object>("unitDsc"),
                                                        }
                    })
                    );
            }

        }
        /// <summary>
        /// depricated. pls use latest version of getListOfSpecificCstmr service instead
        /// سرویس دریافت لیست سفارشات / سبد های خرید کاربر فراخواننده
        /// برای اپ خریدار
        /// دریافت لیست سبد های خرید و سفارشات
        /// </summary>
        /// <param name="model">
        /// لیستی از وضعیت های سفارشات که میتواند نال باشد
        /// شناسه فروشگاه که می تواند نال باشد - در هدر ست شود
        /// </param>
        /// <returns></returns>
        [Route("getOrderList")]
        [Exception]
        [HttpPost]
        [Obsolete("depricated. pls use latest version of getListOfSpecificCstmr service instead.", false)]
        public IHttpActionResult getOrderList(getListOfSpecificCstmrBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_getListOfSpecificCstmr", "OrderController_getListOfSpecificCstmr", initAsReader: true, checkAccess: false))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                DataTable dtStatuses = new DataTable();
                DataRow row_;
                dtStatuses.Columns.Add("id");
                foreach (var item in model.statuses)
                {
                    row_ = dtStatuses.NewRow();
                    row_["id"] = item;
                    dtStatuses.Rows.Add(row_);
                }


                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", model.storeId.getDbValue());
                //repo.cmd.Parameters.AddWithValue("@customerId", model.customerId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@includeDtls", model.includeDtls.getDbValue());

                repo.cmd.Parameters.AddWithValue("@includeStatusList", model.includeStatusList.getDbValue());
                var param = repo.cmd.Parameters.AddWithValue("@statuses", dtStatuses);
                param.SqlDbType = System.Data.SqlDbType.Structured;
                repo.ExecuteAdapter();
                var tb_base = repo.ds.Tables[0];
                var tb_dtls = model.includeDtls.HasValue && model.includeDtls.Value ? repo.ds.Tables[1] : null;
                var tb_status = model.includeStatusList.HasValue && model.includeStatusList.Value ? (tb_dtls == null ? repo.ds.Tables[1] : repo.ds.Tables[2]) : null;
                //var storeInfo = repo.ds.Tables[1];
                //var storephone = repo.ds.Tables[2];
                //var itemInfo = repo.ds.Tables[3];
                return Ok(
                    tb_base.AsEnumerable().Select(b => new
                    {
                        orderId = b.Field<object>("orderId"),
                        //lastOrderHdrId = b.Field<object>("lastOrderHdrId"),
                        orderId_str = b.Field<object>("orderId_str"),
                        countOfActiveDtls = b.Field<object>("countOfActiveDtls"),
                        orderDate = b.Field<object>("orderDate"),
                        orderTime = b.Field<object>("orderTime"),
                        totalAmountWithTax_withoutDiscount = b.Field<object>("sum_cost_payable_withTax_withoutDiscount"),
                        totalAmountWithTax_withDiscount = b.Field<object>("sum_cost_payable_withTax_withDiscount"),
                        totalAmountWithoutTax_withoutDiscount = b.Field<object>("sum_cost_payable_withoutTax_withoutDiscount"),
                        cost_Delivery = b.Field<object>("sum_cost_delivery_remaining"),
                        totalTaxAmount = b.Field<object>("sum_cost_totalTax_info"),
                        totalDiscount = b.Field<object>("sum_cost_discount"),
                        totalPayableAmount = b.Field<object>("total_remaining_payment_payable"),
                        storeId = b.Field<object>("storeId"),
                        storeTitle = b.Field<object>("storeTitle"),
                        sroeTitle_second = b.Field<object>("sroeTitle_second"),
                        storeLogo = b.Field<object>("storeLogo"),
                        storeLogo_thumb = b.Field<object>("storeLogo_thumb"),
                        storeAddress = b.Field<object>("storeAddress"),
                        storePhone = b.Field<object>("storePhone"),
                        storeLoc_Lat = b.Field<object>("storeLoc_Lat"),
                        soreLoc_Lon = b.Field<object>("soreLoc_Lon"),
                        storePic = b.Field<object>("storePic"),
                        storePic_thumb = b.Field<object>("storePic_thumb"),
                        deliveryAddress = b.Field<object>("deliveryAddress"),
                        deliveryLoc_Lat = b.Field<object>("deliveryLoc_Lat"),
                        deliveryLoc_Lng = b.Field<object>("deliveryLoc_Lng"),
                        distance = b.Field<object>("distance"),
                        deliveryLoc_postalCode = b.Field<object>("deliveryLoc_postalCode"),
                        deliveryLoc_callNo = b.Field<object>("deliveryLoc_callNo"),
                        deliveryLoc_city = b.Field<object>("deliveryLoc_city"),
                        deliveryLoc_state = b.Field<object>("deliveryLoc_state"),
                        cartIsShareable = b.Field<object>("cartIsShareable"),
                        deliveryType = b.Field<object>("deliveryType"),
                        deliveryTransfereeName = b.Field<object>("transfereeName"),
                        deliveryLoc_city_dsc = b.Field<object>("deliveryLoc_city_dsc"),
                        deliveryLoc_state_dsc = b.Field<object>("deliveryLoc_state_dsc"),
                        deliveryType_dsc = b.Field<object>("deliveryType_dsc"),
                        status = b.Field<object>("status"),
                        status_dsc = b.Field<object>("status_dsc"),
                        currency = b.Field<object>("currency"),
                        addressId = b.Field<object>("addressId"),
                        newTicketCount = b.Field<object>("newTicketCount"),
                        sum_sendRemaining = b.Field<object>("sum_sendRemaining"),
                        sum_deliveryRemaining = b.Field<object>("sum_deliveryRemaining"),
                        isReceived = b.Field<object>("isReceived"),

                        dtls = tb_dtls == null ? null : from d in tb_dtls.AsEnumerable()
                                                        where d.Field<long>("orderId") == b.Field<long>("orderId")
                                                        select new
                                                        {
                                                            //orderDtlId = d.Field<object>("orderDtlId"),
                                                            orderDtlRowId = d.Field<object>("orderDtlRowId"),
                                                            itemId = d.Field<object>("itemId"),
                                                            itemTitle = d.Field<object>("itemTitle"),
                                                            technicalTitle = d.Field<object>("technicalTitle"),
                                                            itemPic_thumb = d.Field<object>("itemPic_thumb"),
                                                            itemPic = d.Field<object>("itemPic"),
                                                            qty = d.Field<object>("qty"),
                                                            payableAmountWithoutTaxWithoutDiscount = d.Field<object>("payableAmountWithoutTaxWithoutDiscount"),
                                                            discountVal = d.Field<object>("discountVal"),
                                                            payableAmountWithoutTax = d.Field<object>("payableAmountWithoutTax"),
                                                            color = d.Field<object>("color"),
                                                            color_dsc = d.Field<object>("color_dsc"),
                                                            size = d.Field<object>("size"),
                                                            warranty = d.Field<object>("warranty"),
                                                            warranty_dsc = d.Field<object>("warranty_dsc"),
                                                            ManufacturerCo = d.Field<object>("ManufacturerCo"),
                                                            importerCo = d.Field<object>("importerCo"),
                                                            cost_oneUnit_withoutDiscount_dsc = d.Field<object>("cost_oneUnit_withoutDiscount_dsc"),
                                                            discount_percent = d.Field<object>("discount_percent"),
                                                            taxRate = d.Field<object>("taxRate"),
                                                            cost_totalTax_info = d.Field<object>("cost_totalTax_info"),
                                                            unitDsc = d.Field<object>("unitDsc"),
                                                            barcode = d.Field<object>("barcode")
                                                            //currency = d.Field<object>("currency"),
                                                        },
                        statuses = tb_status == null ? null : from s in tb_status.AsEnumerable()
                                                              where s.Field<long>("orderId") == b.Field<long>("orderId")
                                                              select new
                                                              {
                                                                  ord = s.Field<object>("ord"),
                                                                  title = s.Field<object>("title"),
                                                                  stat = s.Field<object>("stat")
                                                              }
                    })
                    );
            }

        }
        /// <summary>
        /// دریافت لیست سفارشات یک فروشگاه خاص (اپ مارکتر)
        /// </summary>
        /// <returns></returns>
        [Route("getListOfSpecificStore/v2")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getListOfSpecificStore_v2(order_getListOfSpecificStoreBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_getListOfSpecificStore", "OrderController_getListOfSpecificStore", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                DataTable dtStatuses = new DataTable();
                DataRow row_;
                dtStatuses.Columns.Add("id");
                foreach (var item in model.statuses)
                {
                    row_ = dtStatuses.NewRow();
                    row_["id"] = item;
                    dtStatuses.Rows.Add(row_);
                }

                //repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@includeDtls", model.includeDtls.getDbValue());
                repo.cmd.Parameters.AddWithValue("@isReviewed", model.isReviewed.getDbValue());
                repo.cmd.Parameters.AddWithValue("@sortType", model.sortType.getDbValue());
                repo.cmd.Parameters.AddWithValue("@f_hasSentPackage", model.f_hasSentPackage.getDbValue());
                var param = repo.cmd.Parameters.AddWithValue("@statuses", dtStatuses);
                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteAdapter();
                var tb_base = repo.ds.Tables[0];
                var tb_dtls = repo.ds.Tables.Count >= 2 ? repo.ds.Tables[1] : null;
                //var storeInfo = repo.ds.Tables[1];
                //var storephone = repo.ds.Tables[2];
                //var itemInfo = repo.ds.Tables[3];
                return Ok(
                    tb_base.AsEnumerable().Select(b => new
                    {
                        orderId = b.Field<object>("orderId"),
                        orderId_str = b.Field<object>("orderId_str"),
                        //lastOrderHdrId = b.Field<object>("lastOrderHdrId"),
                        countOfActiveDtls = b.Field<object>("countOfActiveDtls"),
                        orderDate = b.Field<object>("orderDate"),
                        orderTime = b.Field<object>("orderTime"),
                        orderSubmitDateTime = b.Field<object>("orderSubmitDateTime"),
                        paymentMethode = b.Field<object>("paymentMethode"),
                        paymentMethode_dsc = b.Field<object>("paymentMethode_dsc"),
                        paymentStatus = b.Field<object>("paymentStatus"),
                        paymentStatus_dsc = b.Field<object>("paymentStatus_dsc"),
                        isTwoStepPayment = b.Field<object>("isTwoStepPayment"),
                        isSecurePayment = b.Field<object>("isSecurePayment"),
                        dsc = b.Field<object>("dsc"),
                        sum_cost_payable_withTax_withoutDiscount = b.Field<object>("sum_cost_payable_withTax_withoutDiscount"),
                        sum_cost_payable_withTax_withDiscount = b.Field<object>("sum_cost_payable_withTax_withDiscount"),
                        sum_cost_payable_withoutTax_withoutDiscount = b.Field<object>("sum_cost_payable_withoutTax_withoutDiscount"),
                        total_payment_payable = b.Field<object>("total_payment_payable"),
                        sum_cost_delivery_remaining = b.Field<object>("sum_cost_delivery_remaining"),
                        sum_cost_delivery = b.Field<object>("sum_cost_delivery"),
                        sum_cost_totalTax_info = b.Field<object>("sum_cost_totalTax_info"),
                        sum_cost_discount = b.Field<object>("sum_cost_discount"),
                        total_remaining_payment_payable = b.Field<object>("total_remaining_payment_payable"),
                        reviewDateTime = b.Field<object>("reviewDateTime"),
                        //storeId = b.Field<object>("storeId"),
                        //storeTitle = b.Field<object>("storeTitle"),
                        //sroeTitle_second = b.Field<object>("sroeTitle_second"),
                        //storeLogo = b.Field<object>("storeLogo"),
                        //storeLogo_thumb = b.Field<object>("storeLogo_thumb"),
                        //storeAddress = b.Field<object>("storeAddress"),
                        //storePhone = b.Field<object>("storePhone"),
                        //storeLoc_Lat = b.Field<object>("storeLoc_Lat"),
                        //soreLoc_Lon = b.Field<object>("soreLoc_Lon"),
                        //storePic = b.Field<object>("storePic"),
                        //storePic_thumb = b.Field<object>("storePic_thumb"),
                        deliveryAddress = b.Field<object>("deliveryAddress"),
                        deliveryLoc_Lat = b.Field<object>("deliveryLoc_Lat"),
                        deliveryLoc_Lng = b.Field<object>("deliveryLoc_Lng"),
                        distance = b.Field<object>("distance"),
                        deliveryLoc_postalCode = b.Field<object>("deliveryLoc_postalCode"),
                        deliveryLoc_callNo = b.Field<object>("deliveryLoc_callNo"),
                        deliveryLoc_city = b.Field<object>("deliveryLoc_city"),
                        deliveryLoc_state = b.Field<object>("deliveryLoc_state"),
                        //cartIsShareable = b.Field<object>("cartIsShareable"),
                        deliveryType = b.Field<object>("deliveryType"),

                        deliveryLoc_city_dsc = b.Field<object>("deliveryLoc_city_dsc"),
                        deliveryLoc_state_dsc = b.Field<object>("deliveryLoc_state_dsc"),
                        deliveryType_dsc = b.Field<object>("deliveryType_dsc"),
                        status = b.Field<object>("status"),
                        status_dsc = b.Field<object>("status_dsc"),
                        cstmrName = b.Field<object>("cstmrName"),
                        isMultiPartDelivery = b.Field<object>("isMultiPartDelivery").dbNullCheckBoolean(),
                        isSent = b.Field<object>("isSent").dbNullCheckBoolean(),
                        isDelivered = b.Field<object>("isDelivered").dbNullCheckBoolean(),
                        currency = b.Field<object>("currency"),
                        newTicketCount = b.Field<object>("newTicketCount"),

                        sum_sendRemaining = b.Field<object>("sum_sendRemaining"),
                        sum_deliveryRemaining = b.Field<object>("sum_deliveryRemaining"),
                        dtls = tb_dtls == null ? null : from d in tb_dtls.AsEnumerable()
                                                        where d.Field<long>("orderId") == b.Field<long>("orderId")
                                                        select new
                                                        {
                                                            //orderDtlId = d.Field<object>("orderDtlId"),
                                                            orderDtlRowId = d.Field<object>("orderDtlRowId"),
                                                            itemId = d.Field<object>("itemId"),
                                                            itemTitle = d.Field<object>("itemTitle"),
                                                            technicalTitle = d.Field<object>("technicalTitle"),
                                                            itemPic_thumb = d.Field<object>("itemPic_thumb"),
                                                            itemPic = d.Field<object>("itemPic"),
                                                            qty = d.Field<object>("qty"),
                                                            payableAmountWithoutTaxWithoutDiscount = d.Field<object>("payableAmountWithoutTaxWithoutDiscount"),
                                                            discountVal = d.Field<object>("discountVal"),
                                                            payableAmountWithoutTax = d.Field<object>("payableAmountWithoutTax"),
                                                            color = d.Field<object>("color"),
                                                            color_dsc = d.Field<object>("color_dsc"),
                                                            size = d.Field<object>("size"),
                                                            warranty = d.Field<object>("warranty"),
                                                            warranty_dsc = d.Field<object>("warranty_dsc"),
                                                            ManufacturerCo = d.Field<object>("ManufacturerCo"),
                                                            importerCo = d.Field<object>("importerCo"),
                                                            cost_oneUnit_withoutDiscount = d.Field<object>("cost_oneUnit_withoutDiscount"),
                                                            cost_oneUnit_withoutDiscount_dsc = d.Field<object>("cost_oneUnit_withoutDiscount_dsc"),
                                                            discount_percent = d.Field<object>("discount_percent"),
                                                            taxRate = d.Field<object>("taxRate"),
                                                            cost_totalTax_info = d.Field<object>("cost_totalTax_info"),
                                                            unitDsc = d.Field<object>("unitDsc"),
                                                            barcode = d.Field<object>("barcode"),
                                                            localBarcode = d.Field<object>("localBarcode")
                                                        }
                    })
                    );
            }

        }
        /// <summary>
        /// سرویس دریافت لیست سفارشات / سبد های خرید کاربر فراخواننده
        /// برای اپ خریدار
        /// دریافت لیست سبد های خرید و سفارشات
        /// </summary>
        /// <param name="model">
        /// لیستی از وضعیت های سفارشات که میتواند نال باشد
        /// شناسه فروشگاه که می تواند نال باشد - در هدر ست شود
        /// </param>
        /// <returns></returns>
        [Route("getListOfSpecificCstmr")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getListOfSpecificCstmr(getListOfSpecificCstmrBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_getListOfSpecificCstmr", "OrderController_getListOfSpecificCstmr", initAsReader: true, checkAccess: false))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                DataTable dtStatuses = new DataTable();
                DataRow row_;
                dtStatuses.Columns.Add("id");
                foreach (var item in model.statuses)
                {
                    row_ = dtStatuses.NewRow();
                    row_["id"] = item;
                    dtStatuses.Rows.Add(row_);
                }


                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", model.storeId.getDbValue());
                //repo.cmd.Parameters.AddWithValue("@customerId", model.customerId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@includeDtls", model.includeDtls.getDbValue());
                repo.cmd.Parameters.AddWithValue("@orderByDate", model.orderByDateAsc.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@includeStatusList", model.includeStatusList.getDbValue());
                var param = repo.cmd.Parameters.AddWithValue("@statuses", dtStatuses);
                param.SqlDbType = System.Data.SqlDbType.Structured;
                repo.ExecuteAdapter();
                var tb_base = repo.ds.Tables[0];
                var tb_dtls = model.includeDtls.HasValue && model.includeDtls.Value ? repo.ds.Tables[1] : null;
                var tb_status = model.includeStatusList.HasValue && model.includeStatusList.Value ? (tb_dtls == null ? repo.ds.Tables[1] : repo.ds.Tables[2]) : null;
                //var storeInfo = repo.ds.Tables[1];
                //var storephone = repo.ds.Tables[2];
                //var itemInfo = repo.ds.Tables[3];
                return Ok(
                    tb_base.AsEnumerable().Select(b => new
                    {
                        orderId = b.Field<object>("orderId"),
                        //lastOrderHdrId = b.Field<object>("lastOrderHdrId"),
                        orderId_str = b.Field<object>("orderId_str"),
                        countOfActiveDtls = b.Field<object>("countOfActiveDtls"),
                        orderDate = b.Field<object>("orderDate"),
                        orderTime = b.Field<object>("orderTime"),
                        sum_cost_payable_withTax_withoutDiscount = b.Field<object>("sum_cost_payable_withTax_withoutDiscount"),
                        sum_cost_payable_withTax_withDiscount = b.Field<object>("sum_cost_payable_withTax_withDiscount"),
                        sum_cost_payable_withoutTax_withoutDiscount = b.Field<object>("sum_cost_payable_withoutTax_withoutDiscount"),
                        sum_cost_delivery_remaining = b.Field<object>("sum_cost_delivery_remaining"),
                        sum_cost_totalTax_info = b.Field<object>("sum_cost_totalTax_info"),
                        sum_cost_discount = b.Field<object>("sum_cost_discount"),
                        total_remaining_payment_payable = b.Field<object>("total_remaining_payment_payable"),
                        storeId = b.Field<object>("storeId"),
                        storeTitle = b.Field<object>("storeTitle"),
                        sroeTitle_second = b.Field<object>("sroeTitle_second"),
                        storeLogo = b.Field<object>("storeLogo"),
                        storeLogo_thumb = b.Field<object>("storeLogo_thumb"),
                        storeAddress = b.Field<object>("storeAddress"),
                        storePhone = b.Field<object>("storePhone"),
                        storeLoc_Lat = b.Field<object>("storeLoc_Lat"),
                        soreLoc_Lon = b.Field<object>("soreLoc_Lon"),
                        storePic = b.Field<object>("storePic"),
                        storePic_thumb = b.Field<object>("storePic_thumb"),
                        deliveryAddress = b.Field<object>("deliveryAddress"),
                        deliveryLoc_Lat = b.Field<object>("deliveryLoc_Lat"),
                        deliveryLoc_Lng = b.Field<object>("deliveryLoc_Lng"),
                        distance = b.Field<object>("distance"),
                        deliveryLoc_postalCode = b.Field<object>("deliveryLoc_postalCode"),
                        deliveryLoc_callNo = b.Field<object>("deliveryLoc_callNo"),
                        deliveryLoc_city = b.Field<object>("deliveryLoc_city"),
                        deliveryLoc_state = b.Field<object>("deliveryLoc_state"),
                        cartIsShareable = b.Field<object>("cartIsShareable"),
                        deliveryType = b.Field<object>("deliveryType"),
                        deliveryTransfereeName = b.Field<object>("transfereeName"),
                        deliveryLoc_city_dsc = b.Field<object>("deliveryLoc_city_dsc"),
                        deliveryLoc_state_dsc = b.Field<object>("deliveryLoc_state_dsc"),
                        deliveryType_dsc = b.Field<object>("deliveryType_dsc"),
                        status = b.Field<object>("status"),
                        status_dsc = b.Field<object>("status_dsc"),
                        currency = b.Field<object>("currency"),
                        addressId = b.Field<object>("addressId"),
                        newTicketCount = b.Field<object>("newTicketCount"),
                        sum_sendRemaining = b.Field<object>("sum_sendRemaining"),
                        sum_deliveryRemaining = b.Field<object>("sum_deliveryRemaining"),
                        isReceived = b.Field<object>("isReceived"),
                        isAbleToReceivePackage = b.Field<object>("isAbleToReceivePackage").dbNullCheckBoolean(),
                        total_payment_payable = b.Field<object>("total_payment_payable"),
                        currentShiftStatus = b.Field<object>("currentShiftStatus").dbNullCheckBoolean(),
                        dtls = tb_dtls == null ? null : from d in tb_dtls.AsEnumerable()
                                                        where d.Field<long>("orderId") == b.Field<long>("orderId")
                                                        select new
                                                        {
                                                            //orderDtlId = d.Field<object>("orderDtlId"),
                                                            orderDtlRowId = d.Field<object>("orderDtlRowId"),
                                                            itemId = d.Field<object>("itemId"),
                                                            itemTitle = d.Field<object>("itemTitle"),
                                                            technicalTitle = d.Field<object>("technicalTitle"),
                                                            itemPic_thumb = d.Field<object>("itemPic_thumb"),
                                                            itemPic = d.Field<object>("itemPic"),
                                                            qty = d.Field<object>("qty"),
                                                            payableAmountWithoutTaxWithoutDiscount = d.Field<object>("payableAmountWithoutTaxWithoutDiscount"),
                                                            discountVal = d.Field<object>("discountVal"),
                                                            payableAmountWithoutTax = d.Field<object>("payableAmountWithoutTax"),
                                                            color = d.Field<object>("color"),
                                                            color_dsc = d.Field<object>("color_dsc"),
                                                            size = d.Field<object>("size"),
                                                            warranty = d.Field<object>("warranty"),
                                                            warranty_dsc = d.Field<object>("warranty_dsc"),
                                                            ManufacturerCo = d.Field<object>("ManufacturerCo"),
                                                            importerCo = d.Field<object>("importerCo"),
                                                            cost_oneUnit_withoutDiscount_dsc = d.Field<object>("cost_oneUnit_withoutDiscount_dsc"),
                                                            discount_percent = d.Field<object>("discount_percent"),
                                                            taxRate = d.Field<object>("taxRate"),
                                                            cost_totalTax_info = d.Field<object>("cost_totalTax_info"),
                                                            unitDsc = d.Field<object>("unitDsc"),
                                                            barcode = d.Field<object>("barcode")
                                                            //currency = d.Field<object>("currency"),
                                                        },
                        statuses = tb_status == null ? null : from s in tb_status.AsEnumerable()
                                                              where s.Field<long>("orderId") == b.Field<long>("orderId")
                                                              select new
                                                              {
                                                                  ord = s.Field<object>("ord"),
                                                                  title = s.Field<object>("title"),
                                                                  stat = s.Field<object>("stat")
                                                              }
                    })
                    );
            }

        }

































        /// <summary>
        /// تعیین وضعیت بررسی سفارش به بررسی شده
        /// </summary>
        /// <returns></returns>
        [Route("setReviewStatus")]
        [Exception]
        [HttpPost]
        public IHttpActionResult setReviewStatus(getListOfSpecificStore model)
        {
            //if (!ModelState.IsValid)
            //    return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_setReviewStatus", "OrderController_setReviewStatus"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if(repo.accessDenied)
                //    return new ForbiddenActionResult();

                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId);
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// اعلام ارسال بسته به مشتری در اپ فروشنده
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("package_send")]
        [Exception]
        [HttpPost]
        public IHttpActionResult package_send(package_sendBindingModel model)
        {
            //if (!ModelState.IsValid)
            //    return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_package_send", "OrderController_package_send"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if(repo.accessDenied)
                //    return new ForbiddenActionResult();
                DataTable dtPackage = ClassToDatatableConvertor.CreateDataTable(model.sentPackage ?? new List<order_package_SendTypeModel>());
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId);
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@setAllSent", model.setAllSent.getDbValue());
                repo.cmd.Parameters.AddWithValue("@ignoreIfOrderIsNotPaid", model.ignoreIfOrderIsNotPaid.getDbValue());
                var par_package = repo.cmd.Parameters.AddWithValue("@package", dtPackage);
                par_package.SqlDbType = SqlDbType.Structured;

                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// اعلام تحویل بسته به مشتری در اپ فروشنده
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("package_delivery")]
        [Exception]
        [HttpPost]
        public IHttpActionResult package_delivery(package_deliveryBindingModel model)
        {
            //if (!ModelState.IsValid)
            //    return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_package_delivery", "OrderController_package_delivery"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if(repo.accessDenied)
                //    return new ForbiddenActionResult();
                DataTable dtPackageIds = ClassToDatatableConvertor.CreateDataTable(model.deliveryPackages ?? new List<order_package_deliveryTypeModel>());
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId);
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@setAllSentPackagesDelivered", model.setAllSentPackagesDelivered.getDbValue());
                var par_package = repo.cmd.Parameters.AddWithValue("@packageIds", dtPackageIds);
                par_package.SqlDbType = SqlDbType.Structured;

                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }



        /// <summary>
        /// اعلام دریافت بسته از فروشگاه توسط اپ مشتری
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("package_receive")]
        [Exception]
        [HttpPost]
        public IHttpActionResult package_receive(package_receiveBindingModel model)
        {
            //if (!ModelState.IsValid)
            //    return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_package_receive", "OrderController_package_receive"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if(repo.accessDenied)
                //    return new ForbiddenActionResult();
                DataTable dtPackageIds = ClassToDatatableConvertor.CreateDataTable(model.deliveryPackages ?? new List<order_package_receiveTypeModel>());
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId);
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                //repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@setAllDeliveredPackagesReceived", model.setAllDeliveredPackagesReceived.getDbValue());
                var par_package = repo.cmd.Parameters.AddWithValue("@packageIds", dtPackageIds);
                par_package.SqlDbType = SqlDbType.Structured;

                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }

        /// <summary>
        /// اعلام پرداخت مبلغ سفارش به صورت نقدی در اپ فروشنده
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("setPaidAsCash")]
        [Exception]
        [HttpPost]
        public IHttpActionResult setPaidAsCash(setPaidAsCashBindingModel model)
        {
            //if (!ModelState.IsValid)
            //    return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_setPaidAsCash", "OrderController_setPaidAsCash"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if(repo.accessDenied)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId);
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId.getDbValue());

                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// ویرایش سفارش در اپ فروشنده
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("update")]
        [Exception]
        [HttpPost]
        public IHttpActionResult update(orderUpdateBindingModel model)
        {
            //if (!ModelState.IsValid)
            //    return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_update", "OrderController_update"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if(repo.accessDenied)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId);
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);

                DataTable dtInputDtls = ClassToDatatableConvertor.CreateDataTable(model.dtls ?? new List<orderUpdateDtlModel>());
                var par_package = repo.cmd.Parameters.AddWithValue("@inputDtls", dtInputDtls);
                par_package.SqlDbType = SqlDbType.Structured;

                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }

        /// <summary>
        /// ثبت یک پیام در لیست مکاتبات پیرامون یک سفارش
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("correspondenceAdd")]
        [Exception]
        [HttpPost]
        public IHttpActionResult correspondenceAdd(order_correspondenceAddBindingModel model)
        {
            //if (!ModelState.IsValid)
            //    return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_correspondenceAdd", "OrderController_correspondenceAdd"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if(repo.accessDenied)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId);
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@message", model.message);
                repo.cmd.Parameters.AddWithValue("@isTicket", model.isTicket);


                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// دریافت لیست مکاتبات پیرو یک سفارش)
        /// </summary>
        /// <returns></returns>
        [Route("correspondenceGetList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult correspondenceGetList(order_correspondenceGetListBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_correspondenceGetList", "OrderController_correspondenceGetList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@isTicket", model.isTicket.getDbValue());
                repo.ExecuteAdapter();
                var tb_base = repo.ds.Tables[0];
                return Ok(
                    tb_base.AsEnumerable().Select(b => new
                    {
                        id = b.Field<object>("id"),
                        senderUserId = b.Field<object>("senderUserId"),
                        senderUserName = b.Field<object>("senderUserName"),
                        isTicket = b.Field<bool>("isTicket"),
                        message = b.Field<object>("message"),
                        saveDateTime = b.Field<object>("saveDateTime"),
                        saveDateTime_dsc = b.Field<object>("saveDateTime_dsc"),
                        callerIsOwner = b.Field<object>("callerIsOwner"),
                        cstmrIsOwner = b.Field<object>("cstmrIsOwner"),
                        isSeen = b.Field<object>("isSeen")

                    })
                    );
            }

        }

        /// <summary>
        /// اعلام مشاهده و بررسی تیکت سفارش در اپ فروشنده
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("correspondence_ticket_setAsControlled")]
        [Exception]
        [HttpPost]
        public IHttpActionResult correspondence_ticket_setAsControlled(correspondence_ticket_setAsControlledBindingModel model)
        {
            //if (!ModelState.IsValid)
            //    return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_correspondence_ticket_setAsControlled", "OrderController_correspondence_ticket_setAsControlled"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if(repo.accessDenied)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId);
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@ticketId", model.ticketId);


                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }




        /// <summary>
        /// دریافت اطلاعات فاکتور یک سفارش
        /// </summary>
        /// <returns></returns>
        [Route("invoiceGet")]
        [Exception]
        [HttpPost]
        public IHttpActionResult invoiceGet(order_invoiceGetBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_invoiceGet", "OrderController_invoiceGet", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                //repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId.getDbValue());
                repo.ExecuteAdapter();
                var b_items = repo.ds.Tables[0];
                var tb_sum = repo.ds.Tables[1];
                var tb_crn = repo.ds.Tables[2];
                //var storeInfo = repo.ds.Tables[1];
                //var storephone = repo.ds.Tables[2];
                //var itemInfo = repo.ds.Tables[3];
                return Ok(new
                {
                    items =
                    b_items.AsEnumerable().Select(b => new
                    {
                        rowId = b.Field<object>("rowId"),
                        qty = b.Field<object>("qty"),
                        title = b.Field<object>("title"),
                        debit = b.Field<object>("debit"),
                        credit = b.Field<object>("credit"),
                        debit_val = b.Field<object>("debit_val"),
                        credit_val = b.Field<object>("credit_val"),
                        unit_title = b.Field<object>("unit_title"),
                    }),

                    sum = tb_sum.AsEnumerable().Select(f => f.Field<object>(0)).FirstOrDefault(),
                    CurrencyTitle = tb_crn.AsEnumerable().Select(f => f.Field<object>(0)).FirstOrDefault()
                }

                    );
            }

        }




        /// <summary>
        /// لغو سفارش در اپ فروشنده
        /// </summary>
        /// <param name="model"> در صورت لغو توسط خریدار کد 103 و در صورت لغو توسط فروشنده کد 104 وارد شود. به صورت پیشفرض اگر مقدار دهی نشود لغو توسط فروشنده لخاظ می شود</param>
        /// <returns></returns>
        [Route("cancel")]
        [Exception]
        [HttpPost]
        public IHttpActionResult cancel(cancelBindingModel model)
        {
            //if (!ModelState.IsValid)
            //    return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_cancel", "OrderController_cancel"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if(repo.accessDenied)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId);
                repo.cmd.Parameters.AddWithValue("@cancelStatus", model.cancelStatus.getDbValue());
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId.getDbValue());

                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }




        /// <summary>
        /// سرویس دریافت تاریخچه تغییرات یک سفارش
        /// در اپ فروشنده
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getChangeHistory")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getChangeHistory(orderModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_order_getChangeHistory", "OrderController_getChangeHistory", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId.getDbValue());
                repo.ExecuteAdapter();
                var result = repo.ds.Tables.Count > 0 ? repo.ds.Tables[0] : null;
                if (result != null)
                {
                    return Ok(result.AsEnumerable().Select(row =>
                    new
                    {
                        userName = Convert.ToString(row.Field<object>("userName")),
                        userStaff = Convert.ToString(row.Field<object>("userStaff")),
                        actionType_dsc = Convert.ToString(row.Field<object>("actionType_dsc")),
                        changeDateTime = Convert.ToString(row.Field<object>("changeDateTime_dsc")),
                        changeDtls = Convert.ToString(row.Field<object>("changeDtls"))
                    }).ToList());
                }
                return Ok(new { msg = "no result" });
            }

        }



        //اشتراک گذاری سبد خرید با خانواده در اپ خریدار
        //ایجاد سفارش جدید از روی سفارش قبلی در اپ خریدار
        //ثبت اعتراض به سفارش در پرداخت امن در اپ خریدار
        //شارژ کیف پول خانواده؟
        //سرویس ایجاد بسته در اپ فروشنده
        //سرویس دریافت لیست بسته های سفارش در اپ فروشنده
        //سرویس ویرایش وضعیت بسته در اپ فروشنده (آماده شد ، ارسال شد، تحویل شد)
        //سرویس تایید تحویل بسته (ویرایش وضعیت بسته) در اپ خریدار
        //دریافت جزئیات سفارش در سرویس های مجزا
        //سرویس های نظر سنجی

















        //////////////////////////////////////////////////////








        ///// <summary>
        ///// سرویس نهایی کردن سفارش
        ///// </summary>
        ///// <param name="model"></param>
        ///// <returns></returns>
        //[Route("confirm")]
        //[Exception]
        //[HttpPost]
        //public IHttpActionResult confirm(confirmModel model)
        //{
        //    if (!ModelState.IsValid)
        //        return new BadRequestActionResult(ModelState.Values);
        //    using (var repo = new Repo(this, "SP_order_confirm", "OrderController_confirm"))
        //    {
        //        if (repo.unauthorized)
        //            return new UnauthorizedActionResult("Unauthorized!");
        //        //if (!repo.hasAccess)
        //        //    return new ForbiddenActionResult();
        //        repo.cmd.Parameters.AddWithValue("@userSessionId", sessionId.getDbValue());
        //        repo.cmd.Parameters.AddWithValue("@orderId", model.orderId.getDbValue());
        //        repo.cmd.Parameters.AddWithValue("@lastOrderHdrId", model.lastOrderHdrId);
        //        repo.cmd.Parameters.AddWithValue("@deliveryTypeId", model.deliveryTypeId.getDbValue());
        //        repo.cmd.Parameters.AddWithValue("@securePaymentRequested", model.securePaymentRequested.getDbValue());
        //        repo.cmd.Parameters.AddWithValue("@deliveryLoc_lat", model.deliveryLoc_lat.getDbValue());
        //        repo.cmd.Parameters.AddWithValue("@deliveryLoc_lng", model.deliveryLoc_lng.getDbValue());
        //        repo.cmd.Parameters.AddWithValue("@deliveryAddress", model.deliveryAddress.getDbValue());
        //        repo.cmd.Parameters.AddWithValue("@fk_state_deliveryStateId", model.fk_state_deliveryStateId.getDbValue());
        //        repo.cmd.Parameters.AddWithValue("@fk_city_deliveryCityId", model.fk_city_deliveryCityId.getDbValue());
        //        repo.cmd.Parameters.AddWithValue("@delivery_postalCode", model.delivery_postalCode.getDbValue());
        //        repo.cmd.Parameters.AddWithValue("@delivery_callNo", model.delivery_callNo.getDbValue());

        //        repo.ExecuteNonQuery();
        //        if (repo.rCode != 1)
        //            return new NotFoundActionResult(repo.rMsg);
        //        return Ok(new { msg = repo.rMsg });
        //    }

        //}




        /// <summary>
        /// سرویس "بسته را تحویل گرفتم"
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        //[Route("deliveredMyPack")]
        [Exception]
        [HttpPost]
        public IHttpActionResult deliveredMyPack(orderDtlModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_deliveredMyPack", "OrderController_deliveredMyPack"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                repo.cmd.Parameters.AddWithValue("@id", model.id);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }

        }
        /// <summary>
        /// سرویس دریافت جزئیات بسته های سفارش
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        //[Route("getMultiPartOrderDetailList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getMultiPartOrderDetailList(LongKeyModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getMultiPartOrderDetailList", "OrderController_getMultiPartOrderDetailList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                repo.cmd.Parameters.AddWithValue("@orderId", model.id);
                repo.ExecuteAdapter();

                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i => new
                {
                    orderId = Convert.ToString(i.Field<object>("orderId")),
                    date = Convert.ToString(i.Field<object>("DATE")),
                    statusId = Convert.ToInt32(i.Field<object>("statusId")),
                    status_dsc = Convert.ToString(i.Field<object>("status_dsc")),
                    itemDtlId = repo.ds.Tables[1].AsEnumerable().Select(c => new
                    {
                        id = Convert.ToInt64(c.Field<object>("id")),
                        title = Convert.ToString(c.Field<object>("title")),
                        delivered = Convert.ToDecimal(c.Field<object>("delivered")),
                        cstmrAcknowledgmentOnDelivery = Convert.ToBoolean(c.Field<object>("cstmrAcknowledgmentOnDelivery"))

                    }).ToList()

                }).ToList());
            }

        }
        // /// <summary>
        // /// سرویس جزییات سفارش
        // /// </summary>
        // /// <param name="model"></param>
        // /// <returns></returns>
        //// [Route("getOrderDetail")]
        // [Exception]
        // [HttpPost]
        // [Obsolete]
        // public IHttpActionResult getOrderDetail(LongKeyModel model)
        // {
        //     if (!ModelState.IsValid)
        //         return new BadRequestActionResult(ModelState.Values);
        //     using (var repo = new Repo(this, "SP_getOrderDetail", "OrderController_getOrderDetail", initAsReader: true))
        //     {
        //         if (repo.unauthorized)
        //             return new UnauthorizedActionResult("Unauthorized!");
        //         repo.cmd.Parameters.AddWithValue("@orderId", model.id);
        //         repo.ExecuteAdapter();

        //         return Ok(repo.ds.Tables[0].AsEnumerable().Select(i => new
        //         {
        //             orderId = Convert.ToInt64(i.Field<object>("orderId")),
        //             customerName = Convert.ToString(i.Field<object>("customerName")),
        //             paymentStatus = Convert.ToString(i.Field<object>("paymentStatus")),
        //             paymentMethod = Convert.ToString(i.Field<object>("paymentMethod")),
        //             status = new IdTitleValue<int>() { id = Convert.ToInt32(i.Field<object>("statusId")), title = Convert.ToString(i.Field<object>("status_dsc")) },
        //             datetime = Convert.ToString(i.Field<object>("time_")),
        //             customer_dsc = Convert.ToString(i.Field<object>("customer_dsc")),
        //             itemDtlId = repo.ds.Tables[1].AsEnumerable().Select(c => new
        //             {
        //                 id = Convert.ToInt64(c.Field<object>("id")),
        //                 title = Convert.ToString(c.Field<object>("itemTitle")),
        //                 title_dsc = Convert.ToString(c.Field<object>("title_dsc")),
        //                 itemGrpId = Convert.ToInt64(c.Field<object>("groupId")),
        //                 qty = Convert.ToDecimal(c.Field<object>("qty")),
        //                 qty_dsc = Convert.ToString(c.Field<object>("qty_dsc")),
        //                 orginalPrice_dsc = Convert.ToString(c.Field<object>("orginalPrice_dsc")),
        //                 priceAfterDiscount_dsc = Convert.ToString(c.Field<object>("priceAfterDiscount_dsc"))

        //             }).ToList(),
        //             factorTab = repo.ds.Tables[2].AsEnumerable().Select(c => new
        //             {
        //                 qty = Convert.ToDecimal(c.Field<object>("qty")),
        //                 title = Convert.ToString(c.Field<object>("title")),
        //                 discount = Convert.ToDecimal(c.Field<object>("discount")),
        //                 debit = Convert.ToDecimal(c.Field<object>("debit")),
        //                 credit = Convert.ToDecimal(c.Field<object>("credit")),
        //                 regardDsc = Convert.ToString(c.Field<object>("regardDsc")),
        //                 cost_payable_withTax_withDiscount_remaining = Convert.ToDecimal(c.Field<object>("cost_payable_withTax_withDiscount_remaining"))
        //             }).ToList(),
        //             deliveryTab = repo.ds.Tables[3].AsEnumerable().Select(c => new
        //             {
        //                 title = Convert.ToString(c.Field<object>("title")),
        //                 sum_delivered = Convert.ToDecimal(c.Field<object>("sum_delivered")),
        //                 price = Convert.ToString(c.Field<object>("price"))
        //             }).ToList(),
        //             hsitoryTab = repo.ds.Tables[4].AsEnumerable().Select(c => new
        //             {
        //                 name = Convert.ToString(c.Field<object>("name")),
        //                 staff = Convert.ToString(c.Field<object>("staff")),
        //                 actionType = Convert.ToString(c.Field<object>("actionType")),
        //                 date_time = Convert.ToString(c.Field<object>("date_time")),
        //             }).ToList(),
        //             conversationTab = repo.ds.Tables[5].AsEnumerable().Select(c => new
        //             {
        //                 message = Convert.ToString(c.Field<object>("message")),
        //                 sender = Convert.ToString(c.Field<object>("sender")),
        //                 dest = Convert.ToString(c.Field<object>("dest")),
        //                 senderStaff = Convert.ToString(c.Field<object>("senderStaff")),
        //                 destStaff = Convert.ToString(c.Field<object>("destStaff")),
        //                 date_ = Convert.ToString(c.Field<object>("date_"))
        //             }).ToList(),
        //             ticketTab = repo.ds.Tables[6].AsEnumerable().Select(c => new
        //             {
        //                 message = Convert.ToString(c.Field<object>("message")),
        //                 sender = Convert.ToString(c.Field<object>("sender")),
        //                 dest = Convert.ToString(c.Field<object>("dest")),
        //                 senderStaff = Convert.ToString(c.Field<object>("senderStaff")),
        //                 destStaff = Convert.ToString(c.Field<object>("destStaff")),
        //                 date_ = Convert.ToString(c.Field<object>("date_"))
        //             }).ToList()
        //         }).ToList());
        //     }

        // }
        /// <summary>
        /// سرویس جستجوی کالاهای موجود در یک سفارش
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        //[Route("searchItemInOrder")]
        [Exception]
        [HttpPost]
        [Obsolete]
        public IHttpActionResult searchItemInOrder(LongKeyModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_searchItemInOrder", "OrderController_searchItemInOrder", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                repo.cmd.Parameters.AddWithValue("@orderId", model.id);
                repo.cmd.Parameters.AddWithValue("@search", model.search);
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i => new
                {
                    item = new IdTitleValue<long>()
                    {
                        id = Convert.ToInt64(i.Field<object>("id")),
                        title = Convert.ToString(i.Field<object>("title"))
                    }
                }
                ).ToList());
            }

        }
        /// <summary>
        /// سرویس جستجوی آیتم های سفارش بر اساس بارکد
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        //[Route("searchItemInOrderByBarcode")]
        [Exception]
        [HttpPost]
        [Obsolete]
        public IHttpActionResult searchItemInOrderByBarcode(LongKeyModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_searchItemInOrder", "OrderController_searchItemInOrderByBarcode", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                repo.cmd.Parameters.AddWithValue("@orderId", model.id);
                repo.cmd.Parameters.AddWithValue("@search", model.search);
                repo.cmd.Parameters.AddWithValue("@state", 1);
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
                    matchWithLocalBarcode = Convert.ToBoolean(i.Field<object>("matchWithLocalBarcode"))

                }).ToList()
                    );
            }

        }

    }

    public class cart_submitBindingModel
    {
        /// <summary>
        /// شناسه سفارش
        /// </summary>
        [Required(ErrorMessage = "the {0} is required.")]
        [Display(Name = "شناسه سفارش")]
        public long orderId { get; set; }
        /// <summary>
        /// روش پرداخت : 
        /// 1 : نقدی
        /// 2 : اعتباری (کیف پول مجازی)
        /// 3 : آنلاین
        /// </summary>
        //[Required(ErrorMessage = "the {0} is required.")]
        //[Display(Name = "روش پرداخت")]
        public byte paymentMethode { get; set; }
        /// <summary>
        /// نوع پرداخت :
        /// 1 : پرداخت به صورت کامل
        /// 2 : پرداخت پیش پرداخت
        /// </summary>
        //[Required(ErrorMessage = "the {0} is required.")]
        //[Display(Name = "نوع پرداخت")]
        public byte paymentType { get; set; }
    }
    /// <summary>
    /// مدل ورودی جهت دریافت  روش ها و تایپ های مجاز پرداخت برای یک سفارش
    /// </summary>
    public class cart_getPaymentTypesBindingModel
    {
        /// <summary>
        /// شناسه سفارش
        /// </summary>
        [Required(ErrorMessage = "orderId is required.")]
        public long orderId { get; set; }
    }
    /// <summary>
    /// مدل سرویس اضافه کردن به سبد خرید
    /// </summary>
    public class cart_addUpdateItemBindingModel
    {
        ///// <summary>
        ///// شناسه سفارش - در زمان افزودن به سبد خرید می تواند نال باشد
        ///// </summary>
        ////public string orderId { get; set; }
        ///// <summary>
        ///// شناسه سربرگ سند سفارش- در زمان افزودن به سبد خرید می تواند نال باشد
        ///// </summary>
        //public long? orderHdrId { get; set; }
        ///// <summary>
        ///// شناسه مشتری
        ///// </summary>
        //public long? customerUserId { get; set; }
        /// <summary>
        /// شناسه فروشگاه. هنگام افزودن به سبد خرید نیاز به ست شدن نیست و تنها کافیست شناسه فروشگاه در هدر ست شود
        /// </summary>
        public long storeId { get; set; }
        /// <summary>
        /// شناسه کالا
        /// </summary>
        public long itemId { get; set; }
        /// <summary>
        /// رنگ
        /// </summary>
        public string colorId { get; set; }
        /// <summary>
        /// سایز
        /// </summary>
        public string sizeId { get; set; }
        /// <summary>
        /// کدوم وارانتی ؟
        /// </summary>
        public long? warrantyId { get; set; }
        /// <summary>
        /// تعداد
        /// </summary>
        public decimal qty { get; set; }

    }
    /// <summary>
    ///  مدل سرویس دریافت لیست سفارشات کاربر 
    /// </summary>
    public class getListOfSpecificCstmrBindingModel : searchParameterModel
    {
        /// <summary>
        /// لیستی از وضعیت های سفارشات
        /// وضعیت ها
        /// 100 : در انتظار قطعي شدن
        /// 101 : در جريان
        /// 102 : خاتمه يافته
        /// 103 : لغو از سوي خريدار
        /// 104 : لغو از سوي فروشنده
        /// </summary>
        public List<int> statuses { get; set; }
        ///// <summary>
        ///// فیلتر_شناسه مشتری
        ///// </summary>
        //public long? customerId { get; set; }
        /// <summary>
        /// فیلتر_شناسه سفارش 
        /// </summary>
        public string orderId { get; set; }
        /// <summary>
        /// فیلتر_شناسه فروشگاه.در هدینگ هم بذارید اوکیه.
        /// </summary>
        public long? storeId { get; set; }
        /// <summary>
        /// ردیف ها در خروجی بیایند؟
        /// </summary>
        public bool? includeDtls { get; set; }
        /// <summary>
        /// لیست وضعیت سفارش در خروجی بیاید؟
        /// </summary>
        public bool? includeStatusList { get; set; }
        /// <summary>
        /// مرنب سازی بر اساس تاریخ سفارش
        /// صعودی : true
        /// نزولی : false
        /// عدم در نظر گرفتن  : NULL
        /// </summary>
        public bool? orderByDateAsc { get; set; }
    }
    public class order_getListOfSpecificStoreBindingModel : searchParameterModel
    {
        /// <summary>
        /// لیستی از وضعیت های سفارشات
        /// وضعیت ها
        /// 100 : در انتظار قطعي شدن
        /// 101 : در جريان
        /// 102 : خاتمه يافته
        /// 103 : لغو از سوي خريدار
        /// 104 : لغو از سوي فروشنده
        /// </summary>
        public List<int> statuses { get; set; }
        ///// <summary>
        ///// فیلتر_شناسه مشتری
        ///// </summary>
        //public long? customerId { get; set; }
        /// <summary>
        /// فیلتر_شناسه سفارش 
        /// </summary>
        public long? orderId { get; set; }
        /// <summary>
        /// ردیف ها در خروجی بیایند؟
        /// </summary>
        public bool? includeDtls { get; set; }
        /// <summary>
        /// فیلتر_وضعیت بررسی سفارش
        /// </summary>
        public bool? isReviewed { get; set; }
        /// <summary>
        /// مرتب سازی براساس
        /// 1. جدیدترین
        /// 2. قدیمی ترین
        /// 3. کمترین قیمت
        /// 4. بیشترین قیمت
        /// 5. کمترین تعداد اقلام
        /// 6. بیشترین تعداد اقلام
        /// </summary>
        public short sortType { get; set; }
        /// <summary>
        /// فیلتر_حداقل یک بسته ارسالی داشته باشد،یا نداشته باشد
        /// </summary>
        public bool? f_hasSentPackage { get; set; }
    }
    public class order_correspondenceGetListBindingModel : searchParameterModel
    {
        /// <summary>
        /// شناسه سفارش - اجباری
        /// </summary>
        public long? orderId { get; set; }
        /// <summary>
        /// فیلتر_دریافت لیست تیکت ها - در اپ فروشنده الزاما باید ست شود
        /// </summary>
        public bool? isTicket { get; set; }
    }
    public class order_correspondenceAddBindingModel
    {
        /// <summary>
        /// شناسه سفارش - اجباری
        /// </summary>
        public long? orderId { get; set; }

        /// <summary>
        /// ذخیره به عنوان تیکت؟ - در اپ فروشنده الزاما باید ست شود
        /// </summary>
        public bool? isTicket { get; set; }
        /// <summary>
        /// متن پیام
        /// </summary>
        public string message { get; set; }
    }

    public class correspondence_ticket_setAsControlledBindingModel
    {
        /// <summary>
        /// شناسه سفارش
        /// </summary>
        public long orderId { get; set; }
        /// <summary>
        /// شناسه آخرین تیکت مشاهده شده
        /// </summary>
        public long ticketId { get; set; }
    }

    /// <summary>
    /// مدل سرویس نهایی کردن سفارش
    /// </summary>
    public class cart_setDeliveryMethodeBindingModel
    {
        /// <summary>
        /// شناسه سفارش - در سرویس نهایی کردن سفارش استفاده می شود
        /// </summary>
        //public string orderId { get; set; }
        /// <summary>
        /// شناسه سفارش
        /// </summary>
        [Required(ErrorMessage = "orderHdrId is required.")]
        public long orderId { get; set; }
        /// <summary>
        /// شناسه نحوه ارسال
        /// </summary>
        public int? deliveryTypeId { get; set; }
        /// <summary>
        /// پرداخت امن مقتضی است؟
        /// </summary>      
        public bool? securePaymentRequested { get; set; }
        /// <summary>
        /// طول جغرافیایی محل تحویل کالا
        /// </summary>
        public float? deliveryLoc_lat { get; set; }
        /// <summary>
        /// عرض جغرافیایی محل تحویل کالا
        /// </summary>
        public float? deliveryLoc_lng { get; set; }
        /// <summary>
        /// آدرس محل تحویل کالا
        /// </summary>
        public string deliveryAddress { get; set; }
        /// <summary>
        /// شناسه استان محل تحویل کالا
        /// </summary>
        public int? fk_state_deliveryStateId { get; set; }
        /// <summary>
        /// شناسه شهر محل تحویل کالا
        /// </summary>
        public int? fk_city_deliveryCityId { get; set; }
        /// <summary>
        /// کد پستی محل تحویل کالا
        /// </summary>
        public string delivery_postalCode { get; set; }
        /// <summary>
        /// تلفن تماس محل تحویل کالا
        /// </summary>
        public string delivery_callNo { get; set; }
        public long fk_orderAddress_id { get; set; }
    }
    /// <summary>
    /// مدل سرویس حذف آیتم از سبد خرید
    /// </summary>
    public class cart_removeItemBindingModel
    {
        ///// <summary>
        ///// شناسه سفارش
        ///// </summary>
        //public string orderId { get; set; }
        /// <summary>
        /// شناسه کالا
        /// </summary>
        public int? rowId { get; set; }
        /// <summary>
        /// شناسه سفارش
        /// </summary>
        public long? orderId { get; set; }
    }
    /// <summary>
    /// مدل ورودی سرویس حذف سبد خرید
    /// </summary>
    public class cart_removeBindingModel
    {
        /// <summary>
        /// شناسه سفارش
        /// </summary>
        public long orderId { get; set; }
    }
    /// <summary>
    /// مدل سرویس تاریخچه سفارش
    /// </summary>
    public class orderModel
    {
        /// <summary>
        /// شناسه سفارش
        /// </summary>
        public long orderId { get; set; }
    }
    public class getListOfSpecificStore
    {
        /// <summary>
        /// شناسه سفارش
        /// </summary>
        public long orderId { get; set; }
    }
    /// <summary>
    /// مدل ارسال بسته کالا به مشتری
    /// </summary>
    public class package_sendBindingModel
    {
        /// <summary>
        /// شناسه سفارش
        /// </summary>
        public long orderId { get; set; }
        /// <summary>
        /// جزئیات بسته ارسالی
        /// </summary>
        public List<order_package_SendTypeModel> sentPackage { get; set; }
        /// <summary>
        /// تمامی مانده های ارسال نشده از سفارش ارسال شدند؟
        /// </summary>
        public bool? setAllSent { get; set; }
        /// <summary>
        /// نادیده گرفتن هشدار / خطای مانده دار بودن فاکتور جهت ثبت سند
        /// </summary>
        public bool? ignoreIfOrderIsNotPaid { get; set; }

    }
    /// <summary>
    /// مدل ورودی سرویس تحویل بسته های سفارش
    /// </summary>
    public class package_deliveryBindingModel
    {
        /// <summary>
        /// شناسه سفارش
        /// </summary>
        public long orderId { get; set; }
        /// <summary>
        /// لیست شناسه بسته های تحویل شده
        /// </summary>
        public List<order_package_deliveryTypeModel> deliveryPackages { get; set; }
        /// <summary>
        /// تمامی بسته های ارسالی تحویل شده اند؟
        /// </summary>
        public bool? setAllSentPackagesDelivered { get; set; }
    }
    /// <summary>
    /// مدل ورودی سرویس دریافت بسته های سفارش
    /// </summary>
    public class package_receiveBindingModel
    {
        /// <summary>
        /// شناسه سفارش
        /// </summary>
        public long orderId { get; set; }
        /// <summary>
        /// لیست شناسه بسته های دریافت شده
        /// </summary>
        public List<order_package_receiveTypeModel> deliveryPackages { get; set; }
        /// <summary>
        /// تمامی بسته های تحویلی دریافت شده اند؟
        /// </summary>
        public bool? @setAllDeliveredPackagesReceived { get; set; }
    }
    public class setPaidAsCashBindingModel
    {
        /// <summary>
        /// شناسه سفارش
        /// </summary>
        public long orderId { get; set; }
    }
    public class cancelBindingModel
    {
        /// <summary>
        /// شناسه سفارش
        /// </summary>
        public long orderId { get; set; }
        /// <summary>
        /// کد وضعیت لغو
        /// لغو از سوی خریدار : 103
        /// لغو از سوی فروشنده : 104
        /// </summary>
        public int? cancelStatus { get; set; }
    }

    /// <summary>
    /// مدل بسته ارسال کالا
    /// </summary>
    public class order_package_SendTypeModel
    {
        public int rowId { get; set; }
        public decimal sendQty { get; set; }
    }
    /// <summary>
    /// مدل لیست شناسه بسته های تحویل شده
    /// </summary>
    public class order_package_deliveryTypeModel
    {
        /// <summary>
        /// شناسه بسته (شناسه سربرگ سند ارسال بسته)
        /// </summary>
        public long packageId { get; set; }
    }
    /// <summary>
    /// مدل لیست شناسه بسته های دریافت شده
    /// </summary>
    public class order_package_receiveTypeModel
    {
        /// <summary>
        /// شناسه بسته (شناسه سربرگ سند تحویل بسته)
        /// </summary>
        public long packageId { get; set; }
    }

    public class orderUpdateDtlModel
    {
        //public int rowId { get; set; }
        public long itemId { get; set; }
        public string colorId { get; set; }
        public string sizeId { get; set; }
        public long? warrantyId { get; set; }
        public decimal qty { get; set; }
    }

    public class orderUpdateBindingModel
    {
        /// <summary>
        /// شناسه سفارش
        /// </summary>
        public long orderId { get; set; }
        /// <summary>
        /// ردیف های ویرایش شده
        /// </summary>
        public List<orderUpdateDtlModel> dtls { get; set; }
    }

    /// <summary>
    /// مدل سرویس های سفارشات در جریان و قبلی کاربر
    /// </summary>
    public class userOrderModel
    {
        public string orderId { get; set; }
        public string storeTitle { get; set; }
        public string date { get; set; }
        public string price { get; set; }
        public IdTitleValue<int> status { get; set; }
        public List<orderDtlModel> details { get; set; }
    }
    /// <summary>
    /// مدل مربوط به جزئیات سفارش
    /// </summary>
    public class orderDtlModel
    {
        public long id { get; set; }
        public string itemName { get; set; }
        public string color { get; set; }
        public decimal qty { get; set; }
        public string warranty { get; set; }
        public string image { get; set; }
        public string thumbImage { get; set; }
    }
    /// <summary>
    /// مدل پایه سفارشات فروشگاه
    /// </summary>
    public class getStoreOrderList : searchParameterModel
    {
        /// <summary>
        /// 0: همه سفارشات بذون در نظر گرفتن وضعیت
        /// 1: فقط سفارشات در جریان
        /// </summary>
        public int state { get; set; }
    }
    public class getInfoGeneralBindingModel
    {
        /// <summary>
        /// شناسه سفارش
        /// </summary>
        [Required(ErrorMessage = "orderId is required")]
        public long orderId { get; set; }

    }
    public class order_invoiceGetBindingModel
    {
        /// <summary>
        /// شناسه سفارش
        /// </summary>
        public long? orderId { get; set; }
    }

}