CREATE PROCEDURE [dbo].[SP_order_getListOfSpecificStore] 
     @clientLanguage AS CHAR(2)
	,@appId AS TINYINT
	,@clientIp AS VARCHAR(50)
	,@pageNo AS INT
	,@search AS NVARCHAR(100)
	,@parent AS VARCHAR(20)
	,@userId AS BIGINT
	,@statuses AS dbo.IntType readonly
	,@orderId AS bigint
	,@storeId AS BIGINT 
	,@includeDtls as bit
	,@isReviewed as bit
	,@sortType as tinyint = 1
	,@f_hasSentPackage as bit = null
	AS
SET NOCOUNT ON;


WITH BASEDATAT
AS (
	SELECT 
		 o.id as orderId
	     ,o.id_str as orderId_str
	    --,null as lastOrderHdrId --co.lastOrderHdrId as lastOrderHdrId
		,co.countOfActiveDtls
		,dbo.func_getDateByLanguage(@clientLanguage, o.submitDateTime, 0) AS orderDate
		,SUBSTRING(CAST(CAST(o.submitDateTime AS TIME) AS NVARCHAR(50)), 0, 6) AS orderTime



			,dbo.func_getDateByLanguage(@clientLanguage,o.submitDateTime,1) as orderSubmitDateTime
			,o.fk_paymentMethode_id as paymentMethode
	        ,ISNULL(pmtr.title,pm.title) as paymentMethode_dsc
			,[dbo].[func_order_calcPaymentStatus](co.total_payment_payable,co.total_paid) as paymentStatus
			--,[dbo].[func_order_calcPaymentStatusDsc](co.total_payment_payable,co.total_paid,@clientLanguage) as paymentStatus_dsc
			,o.isTwoStepPayment
			,o.isSecurePayment --ohdr.securePaymentRequested as isSecurePayment
			,o.customerMsg as dsc



		,[dbo].[func_getPriceAsDisplayValue_v2](co.sum_cost_payable_withTax_withoutDiscount, @clientLanguage, o.fk_store_storeId,ISNULL(crncy_trn.title , crncy.Symbol)) AS sum_cost_payable_withTax_withoutDiscount
		,[dbo].[func_getPriceAsDisplayValue_v2](co.sum_cost_payable_withTax_withDiscount, @clientLanguage, o.fk_store_storeId,ISNULL(crncy_trn.title , crncy.Symbol)) AS sum_cost_payable_withTax_withDiscount
		,[dbo].[func_getPriceAsDisplayValue_v2](co.sum_cost_payable_withoutTax_withoutDiscount, @clientLanguage, o.fk_store_storeId,ISNULL(crncy_trn.title , crncy.Symbol)) AS sum_cost_payable_withoutTax_withoutDiscount
		,[dbo].[func_getPriceAsDisplayValue_v2](co.total_payment_payable, @clientLanguage, o.fk_store_storeId,ISNULL(crncy_trn.title , crncy.Symbol)) AS total_payment_payable
		,[dbo].[func_getPriceAsDisplayValue_v2](co.sum_cost_delivery_remaining, @clientLanguage, o.fk_store_storeId,ISNULL(crncy_trn.title , crncy.Symbol)) AS sum_cost_delivery_remaining
		,[dbo].[func_getPriceAsDisplayValue_v2](co.sum_cost_totalTax_info, @clientLanguage, o.fk_store_storeId,ISNULL(crncy_trn.title , crncy.Symbol)) AS sum_cost_totalTax_info
		--,[dbo].[func_getPriceAsDisplayValue_v2](co.sum_cost_discount, @clientLanguage, o.fk_store_storeId,ISNULL(crncy_trn.title , crncy.Symbol)) AS sum_cost_discount
		,REPLACE( [dbo].[func_getPriceAsDisplayValue_v2](co.sum_cost_discount, @clientLanguage, o.fk_store_storeId,ISNULL(crncy_trn.title , crncy.Symbol)),'-','') AS sum_cost_discount
		,[dbo].[func_getPriceAsDisplayValue_v2](co.total_remaining_payment_payable, @clientLanguage, o.fk_store_storeId,ISNULL(crncy_trn.title , crncy.Symbol)) AS total_remaining_payment_payable
		,co.storeId AS storeId
		--,oh.deliveryAddress
		--,oh.deliveryLoc.Lat AS deliveryLoc_Lat
		--,oh.deliveryLoc.Long AS deliveryLoc_Lng
		--,oh.delivery_postalCode AS deliveryLoc_postalCode
		--,oh.delivery_callNo AS deliveryLoc_callNo
		--,oh.fk_city_deliveryCityId AS deliveryLoc_city
		--,oh.fk_state_deliveryStateId AS deliveryLoc_state
		,oa.postalAddress as deliveryAddress
		,oa.location.Lat AS deliveryLoc_Lat
		,oa.location.Long AS deliveryLoc_Lng
		,oa.postalCode AS deliveryLoc_postalCode
		,case when oa.transfereeTell is null or oa.transfereeTell = '' then cstmr.mobile else oa.transfereeTell end AS deliveryLoc_callNo
		,oa.fk_city_id AS deliveryLoc_city
		,oa.fk_state_id AS deliveryLoc_state
		,oh.fk_deliveryTypes_id AS deliveryType
		,dbo.func_getDateByLanguage(@clientLanguage, o.reviewDateTime, 1) AS reviewDateTime
		,co.sum_cost_payable_withTax_withDiscount as price -- جهت استفاده مرتب سازی بر اساس قیمت
	,CASE 
		WHEN us.loc IS NULL
			OR s.location IS NULL
			THEN 'نامشخص'
		ELSE dbo.func_calcDistance(@clientLanguage, us.loc, s.location)
		END AS distance
	,city.title AS deliveryLoc_city_dsc
	,stat.title AS deliveryLoc_state_dsc
	,dt.title AS deliveryType_dsc
	,dbo.func_getOrderStatus(o.id, o.fk_status_statusId,o.lastDeliveryDateTime) as [status]
	--,ISNULL(os_trn.title,os.title) as status_dsc
	,isnull(cstmr.fname,'') + ' ' + isnull(cstmr.lname,'') as cstmrName
	,co.sum_sendRemaining
	,co.sum_deliveryRemaining
	,ISNULL(crncy_trn.title , crncy.Symbol) as currency
	,(select count(1) from TB_ORDER_CORRESPONDENCE as oc where oc.fk_order_orderId = o.id and oc.isTicket = 1 and oc.controlDateTime is null and oc.fk_usr_senderUserId = o.fk_usr_customerId) as newTicketCount
	,[dbo].[func_getPriceAsDisplayValue_v2](co.sum_cost_delivery, @clientLanguage, o.fk_store_storeId,ISNULL(crncy_trn.title , crncy.Symbol)) AS sum_cost_delivery
	,o.submitDateTime
	FROM 
	  dbo.TB_ORDER as o 
	inner join TB_STORE AS s WITH (NOLOCK) ON o.fk_store_storeId = s.id
	inner join TB_COUNTRY as cnty  WITH (NOLOCK) ON s.fk_country_id = cnty.id
	inner join TB_CURRENCY as crncy  WITH (NOLOCK) ON cnty.fk_currency_id = crncy.id
	left join TB_CURRENCY_TRANSLATIONS as crncy_trn  ON cnty.fk_currency_id = crncy_trn.id and crncy_trn.lan = @clientLanguage
	  left join dbo.[func_getOrderHdrs](@orderId) AS co on  o.id = co.orderId
	left JOIN TB_ORDER_HDR AS oh ON dbo.func_getMinOrderHdrIdOfOrder(o.id) = oh.id --co.lastOrderHdrId = oh.id
		left join TB_ORDER_ADDRESS as oa on oh.fk_address_id = oa.id
LEFT JOIN TB_STORE_DELIVERYTYPES AS dt WITH (NOLOCK) ON oh.fk_deliveryTypes_id = dt.id
LEFT JOIN TB_STATE AS stat WITH (NOLOCK) ON oa.fk_state_id = stat.id
LEFT JOIN TB_CITY AS city WITH (NOLOCK) ON oa.fk_city_id = city.id
--LEFT join TB_STATUS as os on o.fk_status_statusId = os.id
--LEFT join TB_STATUS_TRANSLATIONS as os_trn on o.fk_status_statusId = os_trn.id and os_trn.lan = @clientLanguage
LEFT JOIN TB_USR_SESSION AS us ON oh.fk_usrSession_id = us.id
	left join TB_USR as cstmr on o.fk_usr_customerId = cstmr.id
	left join TB_TYP_PAYMENT_METHODE as pm on o.fk_paymentMethode_id = pm.id
	left join TB_TYP_PAYMENT_METHODE_TRANSLATIONS as pmtr on o.fk_paymentMethode_id = pmtr.id and pmtr.lan = @clientLanguage

	WHERE (
			(
				NOT EXISTS (
					SELECT 1
					FROM @statuses
					)
				OR dbo.func_getOrderStatus(o.id,o.fk_status_statusId,o.lastDeliveryDateTime) IN (--TODO: استفاده از این تابع در اینجا بهینه است؟!
					SELECT id
					FROM @statuses
					)
				)
				and
				(@orderId is null or o.id = @orderId)
				and
				(@search is null or @search = '' or cstmr.fname like '%' + @search + '%' or cstmr.lname like '%' + @search + '%' or o.id_str like '%' + @search + '%')
				and
				o.fk_store_storeId = @storeId
				and
				(@isReviewed is null or (@isReviewed = 1 and o.reviewDateTime is not null) or (@isReviewed = 0 and o.reviewDateTime is null))
				and
				(@f_hasSentPackage is null or (@f_hasSentPackage = 1 and isnull(co.sum_sent,0) > 0) or (@f_hasSentPackage = 0 and isnull(co.sum_sent,0) = 0))
			)
	)
SELECT *
INTO #TEMP
FROM BASEDATAT

--اطلاعات اصلی
SELECT 
 b.*
,ISNULL(ps_trn.title,ps.title) as paymentStatus_dsc
,ISNULL(os_trn.title,os.title) as status_dsc
,case when @orderId is null then null else 0 end as isMultiPartDelivery
,case when b.sum_sendRemaining = 0 then 1 else 0 end as isSent
,case when b.sum_deliveryRemaining = 0 then 1 else 0 end as isDelivered
FROM #TEMP as b
left join TB_STATUS as ps on b.paymentStatus = ps.id
left join TB_STATUS_TRANSLATIONS as ps_trn on b.paymentStatus = ps_trn.id and ps_trn.lan = @clientLanguage
LEFT join TB_STATUS as os on b.[status] = os.id
LEFT join TB_STATUS_TRANSLATIONS as os_trn on b.[status] = os_trn.id and os_trn.lan = @clientLanguage

ORDER BY
 case when @sortType = 1 then b.submitDateTime else 0 end DESC,
 case when @sortType = 2 then b.submitDateTime  else 0  end ASC,
 case when @sortType = 3 then b.price else 0  end ASC,
 case when @sortType = 4 then b.price else 0  end DEsC,
 case when @sortType = 5 then b.countOfActiveDtls else 0  end ASC,
 case when @sortType = 6 then b.countOfActiveDtls else 0  end DESC
 OFFSET(@pageNo * 10) ROWS
 fetch next 10 rows only
	if(@orderId is not null or (@includeDtls is not null and @includeDtls = 1))
	begin
--اطلاعات ردیف های سفارش



SELECT
     --t.lastOrderHdrId
	 dtl.rowId AS orderDtlRowId
	,i.id as itemId
	,i.title AS itemTitle
	,i.technicalTitle
	,d.image_thumbUrl AS itemPic_thumb
	,d.imageUrl AS itemPic
	,dtl.sum_qty as qty
	--,[dbo].[func_getPriceAsDisplayValue_v2](dtl.cost_oneUnit_withoutDiscount,@clientLanguage,t.storeId,t.currency) as cost_oneUnit_withoutDiscount --dbo.func_addThousandsSeperator(dtl.cost_oneUnit_withoutDiscount) + ' ' + dbo.func_getCurrencyTitleByLanguage(@clientLanguage, H.fk_store_id, 1) cost_oneUnit_withoutDiscount
	--,[dbo].[func_getPriceAsDisplayValue_v2](dtl.cost_oneUnit_withDiscount,@clientLanguage,t.storeId,t.currency) as cost_oneUnit_withDiscount--dbo.func_addThousandsSeperator(dtl.cost_oneUnit_withDiscount) + ' ' + dbo.func_getCurrencyTitleByLanguage(@clientLanguage, H.fk_store_id, 1) cost_oneUnit_withDiscount
	,[dbo].[func_getPriceAsDisplayValue_v2](dtl.cost_payable_withoutTax_withoutDiscount, @clientLanguage, t.storeId,t.currency) AS payableAmountWithoutTaxWithoutDiscount
	,[dbo].[func_getPriceAsDisplayValue_v2](dtl.cost_discount * -1, @clientLanguage, t.storeId,t.currency) AS discountVal --dbo.func_addThousandsSeperator(dtl.cost_discount) + ' ' + dbo.func_getCurrencyTitleByLanguage(@clientLanguage, H.fk_store_id, 1) cost_discount
	,[dbo].[func_getPriceAsDisplayValue_v2](dtl.cost_payable_withoutTax, @clientLanguage, t.storeId,t.currency) AS payableAmountWithoutTax
	,[dbo].[func_getPriceAsDisplayValue_v2](dtl.cost_totalTax_info,@clientLanguage,t.storeId,t.currency) as cost_totalTax_info--dbo.func_addThousandsSeperator(cost_totalTax_info) + ' ' + dbo.func_getCurrencyTitleByLanguage(@clientLanguage, H.fk_store_id, 1) cost_totalTax_info
	--,[dbo].[func_getPriceAsDisplayValue_v2](cost_payable_withTax_withDiscount_totalPaid,@clientLanguage,t.storeId,t.currency) as cost_payable_withTax_withDiscount_totalPaid--dbo.func_addThousandsSeperator(cost_payable_withTax_withDiscount_totalPaid) + ' ' + dbo.func_getCurrencyTitleByLanguage(@clientLanguage, H.fk_store_id, 1) cost_payable_withTax_withDiscount_totalPaid
	,dtl.colorId AS color
	,ISNULL(cr.title, c.title) AS color_dsc
	--,iz.pk_sizeInfo
	,dtl.sizeId as size
	,dtl.warrantyId AS warranty
	,w.title as warranty_dsc
	--,sd.title deliverType
	--,SIQ.qty maxQtyOrder
	,ISNULL(siq.ManufacturerCo,i.manufacturerCo) as ManufacturerCo
	,ISNULL(siq.importerCo,i.importerCo) as importerCo
	,t.orderId
    ,dtl.cost_oneUnit_withoutDiscount
	,[dbo].[func_getPriceAsDisplayValue_v2](dtl.cost_oneUnit_withoutDiscount, @clientLanguage, t.storeId,t.currency) AS cost_oneUnit_withoutDiscount_dsc
	,[dbo].[func_getPriceAsDisplayValue_v2](dtl.cost_payable_withTax_withDiscount,@clientLanguage,t.storeId,t.currency) as cost_payable_withTax_withDiscount
	,case when dtl.discount_percent is null then 0 else dtl.discount_percent end discount_percent
	,dtl.taxRate
	,ISNULL(tu_trn.title,tu.title) as unitDsc
	,i.barcode
	,siq.localBarcode
FROM #TEMP AS t
INNER JOIN dbo.func_getOrderDtls(@orderId,null) AS dtl ON t.orderId = dtl.orderId
LEFT JOIN TB_STORE_ITEM_QTY AS siq ON dtl.itemId = siq.pk_fk_item_id AND t.storeId = siq.pk_fk_store_id
LEFT JOIN TB_ITEM AS i ON dtl.itemId = i.id
LEFT JOIN TB_COLOR AS C ON dtl.colorId = c.id
LEFT JOIN TB_COLOR_TRANSLATIONS cr ON c.id = cr.id
LEFT JOIN dbo.func_getItemDefaultImage(2) as d on d.itemId = dtl.itemId
--LEFT JOIN TB_STORE_ITEM_SIZE as IZ ON dtl.vfk_store_item_size_id = IZ.pk_sizeInfo AND dtl.fk_item_id = iz.pk_fk_item_id AND dtl.fk_store_id = iz.pk_fk_store_id
--LEFT JOIN TB_DOCUMENT_ITEM AS di ON dtl.itemId = di.pk_fk_item_id AND di.isDefault = 1
--JOIN TB_DOCUMENT AS d ON di.pk_fk_document_id = d.id and d.fk_documentType_id = 2
--LEFT JOIN TB_STORE_DELIVERYTYPES as SD ON SD.id = t.fk_deliveryTypes_id
--LEFT JOIN TB_STORE_ITEM_WARRANTY AS siw ON dtl.vfk_store_item_warranty = siw.pk_fk_storeWarranty_id	AND siw.pk_fk_store_id = dtl.fk_store_id	AND siw.pk_fk_item_id = dtl.fk_item_id
left join TB_STORE_WARRANTY as w with(nolock) on dtl.warrantyId = w.id
left join TB_TYP_UNIT as tu on tu.id = i.fk_unit_id
left join TB_TYP_UNIT_TRANSLATIONS as tu_trn on tu_trn.id = i.fk_unit_id and tu_trn.lan = @clientLanguage
--WHERE dtl.isVoid = 0 and dtl.fk_status_id <> 41
WHERE dtl.sum_qty > 0
end
RETURN 0