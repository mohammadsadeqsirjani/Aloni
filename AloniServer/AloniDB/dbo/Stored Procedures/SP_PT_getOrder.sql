CREATE PROCEDURE [dbo].[SP_PT_getOrder]
    @clientLanguage as char(2) = null,
	@appId as tinyint = null,
	@clientIp as varchar(50) = null,
	@orderId as bigint = null,
	@orderHdrId as bigint = null,
	@orderDtlId as bigint = null
AS
BEGIN
	SET NOCOUNT ON;

	if(@orderId IS NOT NULL)
	begin
	select 
	ord.id AS id,
	ord.fk_usr_customerId,
	ISNULL(cust.fname, '') AS fk_usr_customerDsc,
	ord.saveUserIpAddress,
	ord.fk_usr_reviewerUserId,
	ISNULL(usr.fname, '') AS fk_usr_reviewerUserDsc,
	ord.fk_store_storeId,
	ISNULL(s.title, '') AS fk_store_storeDsc,
	ord.fk_status_statusId,
	ISNULL(st.title, '') AS fk_status_statusDsc,
	ord.fk_paymentMethode_id,
	ISNULL(pay.title, '') AS fk_paymentMethode_Dsc,
	ord.isSecurePayment,
	CASE WHEN ord.isSecurePayment = 1 THEN 'پرداخت امن است' WHEN ord.isSecurePayment = 0 THEN 'پرداخت امن نیست' ELSE '' END AS isSecurePaymentDsc,
	ord.isTwoStepPayment,
	CASE WHEN ord.isTwoStepPayment = 1 THEN 'پرداخت دو مرحله ای' WHEN ord.isTwoStepPayment = 0 THEN 'پرداخت یک مرحله ای' ELSE '' END AS isTwoStepPaymentDsc,
	ISNULL(ord.customerMsg, '') AS customerMsg, 
	ISNULL(CAST(dbo.func_udf_Gregorian_To_Persian_withTime(ord.saveDateTime) AS varchar(50)), '') AS saveDateTime,
	ISNULL(CAST(dbo.func_udf_Gregorian_To_Persian_withTime(ord.reviewDateTime) AS varchar(50)), '') AS reviewDateTime
	from TB_ORDER AS ord
	left join TB_USR AS cust on ord.fk_usr_customerId = cust.id
	left join TB_USR AS usr on ord.fk_usr_reviewerUserId = usr.id
	left join TB_STORE AS s on ord.fk_store_storeId = s.id
	left join TB_STATUS AS st on ord.fk_status_statusId = st.id
	left join TB_TYP_PAYMENT_METHODE AS pay on fk_paymentMethode_id = pay.id
	where ord.id = @orderId
	end

	if(@orderHdrId IS NOT NULL)
	begin
	select 
	ordH.id AS id,
	ordH.fk_docType_id,
	ISNULL(dType.title, '') AS fk_docType_Dsc,
	ordH.fk_deliveryTypes_id,
	ISNULL(dlType.title, '') AS fk_deliveryTypes_Dsc,
	ordH.onlinePaymentId,
	ordH.saveIp,
	ordH.isVoid,
	CASE WHEN ordH.isVoid = 1 THEN 'ابطال شده' WHEN ordH.isVoid = 0 THEN 'فعال' ELSE '' END AS isVoidDsc,
	ISNULL(ordA.transfereeName, '') AS transfereeName,
	ISNULL(ordA.transfereeMobile, '') AS transfereeMobile,
	ISNULL(ordA.transfereeTell, '') AS transfereeTell,
	ordA.fk_state_id,
	ISNULL(stat.title, '') AS fk_state_Dsc,
	ordA.fk_city_id,
	ISNULL(c.title, '') AS fk_city_Dsc,
	ordA.fk_usr_id,
	ISNULL(CAST(dbo.func_udf_Gregorian_To_Persian_withTime(ordH.saveDateTime) AS varchar(50)), '') AS saveDateTime,
	ISNULL(usr.fname, '') AS fk_usr_Dsc,
	ISNULL(ordA.postalCode, '') AS postalCode,
	ISNULL(ordA.postalAddress, '') AS postalAddress,
	ISNULL(ordA.nationalCode, '') AS nationalCode,
	ISNULL(ordA.countryCode, '') AS countryCode,
	ordA.location AS [location],
	ISNULL(dbo.func_addThousandsSeperator(ordHB.delivery_amount), '') AS delivery_amount,
	ISNULL(dbo.func_addThousandsSeperator(ordHB.delivery_minOrderCost), '') AS delivery_minOrderCost,
	ISNULL(dbo.func_addThousandsSeperator(ordHB.delivery_radius), '') AS delivery_radius,
	ordHB.delivery_includeCostOnInvoice,
	CASE WHEN ordHB.delivery_includeCostOnInvoice = 0 THEN 'هزینه ارسال بر روی فاکتور حساب نمی شود' WHEN ordHB.delivery_includeCostOnInvoice = 1 THEN 'هزینه ارسال بر روی فاکتور حساب می شود' ELSE '' END AS delivery_includeCostOnInvoiceDsc,
	ordHB.delivery_storeLocation
	from TB_ORDER_HDR AS ordH
	left join TB_TYP_ORDER_DOC_TYPE AS dType on ordH.fk_docType_id = dType.id
	left join TB_STORE_DELIVERYTYPES AS dlType on ordH.fk_deliveryTypes_id = dlType.id
	left join TB_ORDER_HDR_BASE AS ordHB on ordH.id = ordHB.fk_orderHdr_id
	left join TB_ORDER_ADDRESS AS ordA on ordH.fk_address_id = ordA.id
	left join TB_USR AS usr on ordA.fk_usr_id = usr.id
	left join TB_STATE AS stat on ordA.fk_state_id = stat.Id
	left join TB_CITY AS c on ordA.fk_city_id = c.id
	where ordH.id = @orderHdrId
	end

	if(@orderDtlId IS NOT NULL)
	begin
	select
	ordD.id AS id,
	ordD.fk_orderHdr_id,
	ordD.rowId,
	ordD.fk_store_id,
	ISNULL(s.title, '') AS storeTitle,
	ordD.fk_item_id,
	ISNULL(i.title, '') AS itemTitle,
	ordD.vfk_store_item_color_id,
	ISNULL(c.title, '') AS vfk_store_item_color_Title,
	ordD.vfk_store_item_size_id,
	ordD.vfk_store_item_warranty,
	ordD.qty,
	ordD.delivered,
	ordD.isVoid,
	CASE WHEN ordD.isVoid = 0 THEN 'فعال' WHEN ordD.isVoid = 1 THEN 'ابطال شده' ELSE '' END AS Void,
	ordH.fk_docType_id,
	ordDB.canBePurchasedWithoutWarranty,
	CASE WHEN ordDB.canBePurchasedWithoutWarranty = 1 THEN 'امکان فروش بدون گارانتی وجود دارد' WHEN ordDB.canBePurchasedWithoutWarranty = 0 THEN 'امکان فروش بدون گارانتی وجود ندارد' ELSE '' END AS canBePurchasedWithoutWarrantyDsc,
	ISNULL(dbo.func_addThousandsSeperator(ordDB.cost_warranty), '') AS cost_warranty,
	ISNULL(CAST(ordDB.warrantyDays AS varchar(50)), '') AS warrantyDays,
	ISNULL(dbo.func_addThousandsSeperator(ordDB.cost_oneUnit_withoutDiscount), '') AS cost_oneUnit_withoutDiscount,
	ISNULL(dbo.func_addThousandsSeperator(ordDB.discount_minCnt), '') AS discount_minCnt,
	ISNULL(dbo.func_addThousandsSeperator(ordDB.discount_percent), '') AS discount_percent,
	ISNULL(dbo.func_addThousandsSeperator(ordDB.taxRate), '') AS taxRate,
	ordDB.item_includedTax,
	CASE WHEN ordDB.item_includedTax = 1 THEN 'کالا شامل مالیات می باشد' WHEN ordDB.item_includedTax = 0 THEN 'کالا شامل مالیات نمی باشد' ELSE '' END AS item_includedTaxDsc,
	ordDB.store_calculateTax,
	CASE WHEN ordDB.store_calculateTax = 1 THEN 'مالیات بر ارزش افزوده در فاکتور محاسبه می شود' WHEN ordDB.store_calculateTax = 0 THEN 'مالیات بر ارزش افزوده در فاکتور محاسبه نمی شود' ELSE '' END AS store_calculateTaxDsc,
	ISNULL(dbo.func_addThousandsSeperator(ordDB.prepaymentPercent), '') AS prepaymentPercent,
	ISNULL(dbo.func_addThousandsSeperator(ordDB.cancellationPenaltyPercent), '') AS cancellationPenaltyPercent,
	ordDB.validityTimeOfOrder,
	ordDB.store_taxIncludedInPrices,
	CASE WHEN ordDB.store_taxIncludedInPrices = 1 THEN 'مالیات در قیمت لحاظ شده است' WHEN ordDB.store_taxIncludedInPrices = 0 THEN 'مالیات در قیمت  لحاظ نشده است' ELSE '' END AS store_taxIncludedInPricesDsc
	from TB_ORDER_DTL AS ordD
	left join TB_ORDER_DTL_BASE AS ordDB on ordD.fk_order_id = ordDB.orderId and ordD.rowId = ordDB.rowId
	left join TB_ORDER_HDR AS ordH on ordD.fk_orderHdr_id = ordH.id
	left join TB_STORE AS s on ordD.fk_store_id = s.id
	left join TB_ITEM AS i on ordD.fk_item_id = i.id
	left join TB_COLOR AS c on ordD.vfk_store_item_color_id = c.id
	where ordD.id = @orderDtlId
	end


END
