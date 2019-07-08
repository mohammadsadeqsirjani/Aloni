CREATE PROCEDURE [dbo].[SP_order_getListOfSpecificCstmr] 
     @clientLanguage AS CHAR(2)
	,@appId AS TINYINT
	,@clientIp AS VARCHAR(50)
	,@pageNo AS INT
	,@search AS NVARCHAR(100)
	,@parent AS VARCHAR(20)
	,@userId AS BIGINT
	,@statuses AS dbo.IntType readonly
	--,@customerId AS BIGINT
	,@orderId AS bigint
	,@storeId AS BIGINT 
	,@includeDtls as bit
	,@includeStatusList as bit = 0
	,@orderByDate as bit = NULL

	AS
SET NOCOUNT ON;



--IF (@appId = 2)
--BEGIN
--	SET @customerId = @userId;
--END;

WITH
latestOrderLoc
AS
(
select top 1 oa.[location] as loc
from TB_ORDER as o
join TB_ORDER_HDR as oh on o.id = oh.fk_order_orderId
join TB_ORDER_ADDRESS as oa on oh.fk_address_id = oa.id
where o.fk_usr_customerId = @userId and oh.fk_address_id is not null
order by o.id desc
),

BASEDATAT
AS (
	SELECT 
		 o.id as orderId
	    ,o.id_str as orderId_str
	    --,null as lastOrderHdrId --co.lastOrderHdrId as lastOrderHdrId
		,co.countOfActiveDtls
		,dbo.func_getDateByLanguage(@clientLanguage, o.submitDateTime, 0) AS orderDate
		,SUBSTRING(CAST(CAST(o.submitDateTime AS TIME) AS NVARCHAR(50)), 0, 6) AS orderTime
		,[dbo].[func_getPriceAsDisplayValue_v2](co.sum_cost_payable_withTax_withoutDiscount, @clientLanguage, o.fk_store_storeId,ISNULL(crncy_trn.title , crncy.Symbol)) AS sum_cost_payable_withTax_withoutDiscount
		,[dbo].[func_getPriceAsDisplayValue_v2](co.sum_cost_payable_withTax_withDiscount, @clientLanguage, o.fk_store_storeId,ISNULL(crncy_trn.title , crncy.Symbol)) AS sum_cost_payable_withTax_withDiscount
		,[dbo].[func_getPriceAsDisplayValue_v2](co.sum_cost_payable_withoutTax_withoutDiscount, @clientLanguage, o.fk_store_storeId,ISNULL(crncy_trn.title , crncy.Symbol)) AS sum_cost_payable_withoutTax_withoutDiscount
		,[dbo].[func_getPriceAsDisplayValue_v2](co.total_payment_payable, @clientLanguage, o.fk_store_storeId,ISNULL(crncy_trn.title , crncy.Symbol)) AS total_payment_payable
		,[dbo].[func_getPriceAsDisplayValue_v2](co.sum_cost_delivery_remaining, @clientLanguage, o.fk_store_storeId,ISNULL(crncy_trn.title , crncy.Symbol)) AS sum_cost_delivery_remaining
		,[dbo].[func_getPriceAsDisplayValue_v2](co.sum_cost_totalTax_info, @clientLanguage, o.fk_store_storeId,ISNULL(crncy_trn.title , crncy.Symbol)) AS sum_cost_totalTax_info
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
		,oa.id as addressId
		,oa.postalAddress as deliveryAddress
		,oa.location.Lat AS deliveryLoc_Lat
		,oa.location.Long AS deliveryLoc_Lng
		,oa.postalCode AS deliveryLoc_postalCode
		,oa.transfereeTell AS deliveryLoc_callNo
		,oa.fk_city_id AS deliveryLoc_city
		,oa.fk_state_id AS deliveryLoc_state
		,CASE 
			WHEN EXISTS (
					SELECT F.id
					FROM TB_USR_FAMILY as F WITH (NOLOCK)
					WHERE (
							f.fk_usr_requester_usr_id = @userId
							OR f.fk_usr_id = @userId
							)
						AND fk_status_id = 46
					)
				THEN 1
			ELSE 0
			END AS cartIsShareable
		,oh.fk_deliveryTypes_id AS deliveryType
	--,oh.fk_status_paymentStatusId as paymentStatus

	,s.title AS storeTitle
	,s.title_second AS sroeTitle_second
	,d_storeLogo.imageUrl AS storeLogo
	,d_storeLogo.image_thumbUrl AS storeLogo_thumb
	,isnull(s.address_full,s.[address]) AS storeAddress
	,CASE 
	WHEN not exists (select 1 from @statuses where id = 100) then null
		WHEN (select top 1 loc from latestOrderLoc) IS NULL
			OR s.[location] IS NULL
			THEN 'نامشخص'
		ELSE dbo.func_calcDistance(@clientLanguage, (select top 1 loc from latestOrderLoc), s.[location])
		END AS distance
	,s.[location].Lat AS storeLoc_Lat
	,s.[location].Long AS soreLoc_Lon
	,d_storePic.imageUrl AS storePic
	,d_storePic.image_thumbUrl AS storePic_thumb
	--,ISNULL(status_paymentStatus_trn.title,status_paymentStatus.title) as paymentStatus_dsc
	,city.title AS deliveryLoc_city_dsc
	,stat.title AS deliveryLoc_state_dsc
	,dt.title AS deliveryType_dsc
	--,us.loc AS saveUserLoc
	,sp.phone as storePhone
	,os.id as [status]
	,ISNULL(os_trn.title,os.title) as status_dsc
	,ISNULL(crncy_trn.title , crncy.Symbol) as currency
	,(select count(1) from TB_ORDER_CORRESPONDENCE as oc where oc.fk_order_orderId = o.id and oc.isTicket = 1 and oc.controlDateTime is null and oc.fk_usr_senderUserId <> o.fk_usr_customerId) as newTicketCount
	,OA.transfereeName
	,O.reviewDateTime
	,co.sum_sendRemaining
	,co.sum_deliveryRemaining
	,case when co.sum_receive > 0 then 1 else 0 end isReceived
	,case when [dbo].[func_getOrderStatus](o.id,o.fk_status_statusId,o.lastDeliveryDateTime) in(101,102) and co.sum_deliveredRemainingToReceive > 0 then 1 else 0 end as isAbleToReceivePackage
	,o.submitDateTime
	--,case when co. isAbleToReceivePackage
	,dbo.FUNC_getStoreCurrentShiftStatus(o.fk_store_storeId,null) as currentShiftStatus
	FROM 
	  dbo.TB_ORDER as o 
	inner join TB_STORE AS s WITH (NOLOCK) ON o.fk_store_storeId = s.id
	inner join TB_COUNTRY as cnty  WITH (NOLOCK) ON s.fk_country_id = cnty.id
	inner join TB_CURRENCY as crncy  WITH (NOLOCK) ON cnty.fk_currency_id = crncy.id
	left join TB_CURRENCY_TRANSLATIONS as crncy_trn  ON cnty.fk_currency_id = crncy_trn.id and crncy_trn.lan = @clientLanguage
	left join dbo.[func_getOrderHdrs](@orderId) AS co on  o.id = co.orderId
	left JOIN TB_ORDER_HDR AS oh ON dbo.func_getMinOrderHdrIdOfOrder(o.id) = oh.id
	left join TB_ORDER_ADDRESS as oa on oh.fk_address_id = oa.id
	LEFT JOIN TB_STORE_DELIVERYTYPES AS dt WITH (NOLOCK) ON oh.fk_deliveryTypes_id = dt.id
	LEFT JOIN TB_STATE AS stat WITH (NOLOCK) ON oa.fk_state_id = stat.id
	LEFT JOIN TB_CITY AS city WITH (NOLOCK) ON oa.fk_city_id = city.id
	left join TB_STATUS as os on [dbo].[func_getOrderStatus](o.id,o.fk_status_statusId,o.lastDeliveryDateTime) = os.id
	left join TB_STATUS_TRANSLATIONS as os_trn on os.id = os_trn.id and os_trn.lan = @clientLanguage
--left join TB_STATUS as status_paymentStatus  on oh.fk_status_paymentStatusId = status_paymentStatus.id
--left join TB_STATUS_TRANSLATIONS as status_paymentStatus_trn on oh.fk_status_paymentStatusId = status_paymentStatus_trn.id and status_paymentStatus_trn.lan = @clientLanguage
--LEFT JOIN TB_USR_SESSION AS us ON oh.fk_usrSession_id = us.id

--LEFT JOIN TB_DOCUMENT_STORE AS ds WITH (NOLOCK) ON s.id = ds.pk_fk_store_id	AND ds.isDefault = 1
--JOIN TB_DOCUMENT AS d_storeLogo WITH (NOLOCK) ON d_storeLogo.id = ds.pk_fk_document_id	AND d_storeLogo.fk_documentType_id = 5
--LEFT JOIN TB_DOCUMENT_STORE AS ds_ WITH (NOLOCK) ON s.id = ds_.pk_fk_store_id AND ds_.isDefault = 1
--JOIN TB_DOCUMENT AS d_storePic WITH (NOLOCK) ON ds_.pk_fk_document_id = d_storePic.id AND d_storePic.[fk_documentType_id] = 3
left join dbo.func_getStoreDefaultImage(5) as d_storeLogo on s.id = d_storeLogo.storeId
left join dbo.func_getStoreDefaultImage(3) as d_storePic on s.id = d_storePic.storeId




LEFT JOIN TB_STORE_PHONE AS sp WITH (NOLOCK) ON o.fk_store_storeId = sp.fk_store_id
	AND sp.isDefault = 1
	AND sp.isActive = 1
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
				o.fk_usr_customerId = @userId
			)
	)
SELECT *
INTO #TEMP
FROM BASEDATAT

--اطلاعات اصلی
SELECT *
FROM #TEMP
ORDER BY
	CASE WHEN @orderByDate = 1 THEN submitDateTime else 0 END ASC ,
	CASE WHEN @orderByDate = 0 THEN	submitDateTime else 0 END DESC,
	CASE WHEN @orderByDate is Null then  orderId else 0 END DESC

 OFFSET(@pageNo * 10) ROWS

----اطلاعات جانبی
--SELECT DISTINCT
--	--s.id
--	s.title AS storeTitle
--	,s.title_second AS sroeTitle_second
--	,d.completeLink AS storeLogo
--	,d.thumbcompeleteLink AS storeLogo_thumb
--	,s.address AS storeAddress
--	,CASE 
--		WHEN t.saveUserLoc IS NULL
--			OR s.location IS NULL
--			THEN 'نامشخص'
--		ELSE dbo.func_calcDistance(@clientLanguage, t.saveUserLoc, s.location)
--		END AS distance
--	,s.location.Lat AS storeLoc_Lat
--	,s.location.Long AS soreLoc_Lon
--	,d_storePic.completeLink AS storePic
--	,d_storePic.thumbcompeleteLink AS storePic_thumb
--	--,ISNULL(status_paymentStatus_trn.title,status_paymentStatus.title) as paymentStatus_dsc
--	,city.title AS deliveryLoc_city_dsc
--	,stat.title AS deliveryLoc_state_dsc
--	,dt.title AS deliveryType_dsc
--	,us.loc AS saveUserLoc
--FROM #TEMP AS t
--JOIN TB_STORE AS s WITH (NOLOCK) ON t.fk_store_id = s.id
--LEFT JOIN TB_STORE_DELIVERYTYPES AS dt WITH (NOLOCK) ON o.fk_deliveryTypes_id = dt.id
--LEFT JOIN TB_STATE AS stat WITH (NOLOCK) ON O.fk_state_deliveryStateId = stat.id
--LEFT JOIN TB_CITY AS city WITH (NOLOCK) ON O.fk_city_deliveryCityId = city.id
----left join TB_STATUS as status_paymentStatus  on O.fk_status_paymentStatusId = status_paymentStatus.id
----left join TB_STATUS_TRANSLATIONS as status_paymentStatus_trn on O.fk_status_paymentStatusId = status_paymentStatus_trn.id and status_paymentStatus_trn.lan = @clientLanguage
--LEFT JOIN TB_USR_SESSION AS us ON O.fk_usrSession_id = us.id
--LEFT JOIN TB_DOCUMENT_STORE AS ds WITH (NOLOCK) ON S.id = DS.pk_fk_store_id
--	AND DS.isDefault = 1
--LEFT JOIN TB_DOCUMENT AS d WITH (NOLOCK) ON d.id = ds.pk_fk_document_id
--	AND D.fk_documentType_id = 5
--LEFT JOIN TB_DOCUMENT AS d_storePic WITH (NOLOCK) ON ds.pk_fk_document_id = d_storePic.id
--	AND d_storePic.[fk_documentType_id] = 3
--	AND ds.isDefault = 1
--LEFT JOIN TB_STORE_PHONE AS sp WITH (NOLOCK) ON t.storeId = sp.fk_store_id
--	AND sp.isDefault = 1
--	AND sp.isActive = 1

--WHERE s.id IN (
--		SELECT DISTINCT fk_store_id
--		FROM #TEMP
--		)
--
--SELECT fk_store_id
--	,phone
--FROM TB_STORE_PHONE
--WHERE fk_store_id IN (
--		SELECT fk_store_id
--		FROM #TEMP
--		)
--IF ((@includeDtls is not null and @includeDtls <> 1 and @orderId IS NULL) or @includeDtls is null or @includeDtls = 0)
--	RETURN 0;

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
	--,[dbo].[func_getPriceAsDisplayValue_v2](dtl.cost_oneUnit_withoutDiscount,@clientLanguage,@storeId) as cost_oneUnit_withoutDiscount --dbo.func_addThousandsSeperator(dtl.cost_oneUnit_withoutDiscount) + ' ' + dbo.func_getCurrencyTitleByLanguage(@clientLanguage, H.fk_store_id, 1) cost_oneUnit_withoutDiscount
	--,[dbo].[func_getPriceAsDisplayValue_v2](dtl.cost_oneUnit_withDiscount,@clientLanguage,@storeId) as cost_oneUnit_withDiscount--dbo.func_addThousandsSeperator(dtl.cost_oneUnit_withDiscount) + ' ' + dbo.func_getCurrencyTitleByLanguage(@clientLanguage, H.fk_store_id, 1) cost_oneUnit_withDiscount
	,[dbo].[func_getPriceAsDisplayValue_v2](dtl.cost_payable_withoutTax_withoutDiscount, @clientLanguage, t.storeId,t.currency) AS payableAmountWithoutTaxWithoutDiscount
	,[dbo].[func_getPriceAsDisplayValue_v2](dtl.cost_discount * -1, @clientLanguage, t.storeId,t.currency) AS discountVal --dbo.func_addThousandsSeperator(dtl.cost_discount) + ' ' + dbo.func_getCurrencyTitleByLanguage(@clientLanguage, H.fk_store_id, 1) cost_discount
	,[dbo].[func_getPriceAsDisplayValue_v2](dtl.cost_payable_withoutTax, @clientLanguage, t.storeId,t.currency) AS payableAmountWithoutTax
	,[dbo].[func_getPriceAsDisplayValue_v2](dtl.cost_totalTax_info,@clientLanguage,t.storeId,t.currency) as cost_totalTax_info--dbo.func_addThousandsSeperator(cost_totalTax_info) + ' ' + dbo.func_getCurrencyTitleByLanguage(@clientLanguage, H.fk_store_id, 1) cost_totalTax_info
	--,[dbo].[func_getPriceAsDisplayValue_v2](cost_payable_withTax_withDiscount_totalPaid,@clientLanguage,@storeId) as cost_payable_withTax_withDiscount_totalPaid--dbo.func_addThousandsSeperator(cost_payable_withTax_withDiscount_totalPaid) + ' ' + dbo.func_getCurrencyTitleByLanguage(@clientLanguage, H.fk_store_id, 1) cost_payable_withTax_withDiscount_totalPaid
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
	,[dbo].[func_getPriceAsDisplayValue_v2](dtl.cost_oneUnit_withoutDiscount, @clientLanguage, t.storeId,t.currency) AS cost_oneUnit_withoutDiscount_dsc
	,[dbo].[func_getPriceAsDisplayValue_v2](dtl.cost_totalTax_info,@clientLanguage,t.storeId,t.currency) as cost_totalTax_info--dbo.func_addThousandsSeperator(cost_totalTax_info) + ' ' + dbo.func_getCurrencyTitleByLanguage(@clientLanguage, H.fk_store_id, 1) cost_totalTax_info
	,dtl.discount_percent
	,dtl.taxRate

	,ISNULL(tu_trn.title,tu.title) as unitDsc
	,i.barcode
FROM #TEMP AS t
INNER JOIN dbo.func_getOrderDtls(@orderId,null) AS dtl ON t.orderId = dtl.orderId
LEFT JOIN TB_STORE_ITEM_QTY AS siq ON dtl.itemId = siq.pk_fk_item_id AND t.storeId = siq.pk_fk_store_id
LEFT JOIN TB_ITEM AS i ON dtl.itemId = i.id
LEFT JOIN TB_COLOR AS C ON dtl.colorId = c.id
LEFT JOIN TB_COLOR_TRANSLATIONS cr ON c.id = cr.id
LEFT JOIN dbo.func_getItemDefaultImage(2) as d on d.itemId = dtl.itemId
--LEFT JOIN TB_STORE_ITEM_SIZE as IZ ON dtl.vfk_store_item_size_id = IZ.pk_sizeInfo AND dtl.fk_item_id = iz.pk_fk_item_id AND dtl.fk_store_id = iz.pk_fk_store_id
--LEFT JOIN ( select  dtl.itemId from  TB_DOCUMENT_ITEM AS di 
-- JOIN TB_DOCUMENT AS d ON di.pk_fk_document_id = d.id and d.fk_documentType_id = 2
-- where dtl.itemId = di.pk_fk_item_id AND di.isDefault = 1 ) as t22 on t22.itemId = di.pk_fk_item_id
--LEFT JOIN TB_STORE_DELIVERYTYPES as SD ON SD.id = t.fk_deliveryTypes_id
--LEFT JOIN TB_STORE_ITEM_WARRANTY AS siw ON dtl.vfk_store_item_warranty = siw.pk_fk_storeWarranty_id	AND siw.pk_fk_store_id = dtl.fk_store_id	AND siw.pk_fk_item_id = dtl.fk_item_id
left join TB_STORE_WARRANTY as w with(nolock) on dtl.warrantyId = w.id
left join TB_TYP_UNIT as tu on tu.id = i.fk_unit_id
left join TB_TYP_UNIT_TRANSLATIONS as tu_trn on tu_trn.id = i.fk_unit_id and tu_trn.lan = @clientLanguage
--WHERE dtl.isVoid = 0 and dtl.fk_status_id <> 41
WHERE dtl.sum_qty > 0
end


if(@includeStatusList = 1)
begin

declare @returntable TABLE
(
    orderId bigint,
	ord smallint,
	title varchar(50),
	stat tinyint--0:pass,1:on it,2: not reached yet
	
)
   declare @c_orderId as bigint,@c_orderStatusId as int,@c_reviewDateTime as datetime,@c_sum_sent as money,@c_sum_delivered as money;
	declare cr cursor for
	select t.orderId,
	t.[status] as orderStatusId,
	t.reviewDateTime,
	 sum(d.sum_sent) as sum_sent , 
	 sum(d.sum_delivered) as sum_delivered
	from dbo.func_getOrderDtls(null,null) as d
	join #TEMP as t on d.orderId = t.orderId
	where t.[status] in (101,102,105)
	group by t.orderId,t.[status],t.reviewDateTime

	--select b.orderId,dbo.func_getOrderStatus(o.id,o.fk_status_statusId,o.lastDeliveryDateTime) as orderStatusId,o.reviewDateTime,b.sum_sent,b.sum_delivered
	--from b as b join TB_ORDER as o on b.orderId = o.id

	open cr;
    fetch next from cr into 
	@c_orderId,@c_orderStatusId,@c_reviewDateTime,@c_sum_sent,@c_sum_delivered;

	while (@@FETCH_STATUS = 0)
	begin
		--if(@c_orderStatusId in(101,102,105))
		--begin

			declare @stateOneStatus as tinyint,@stateTwoStatus as tinyint,@stateThreeStatus as tinyint,@stateForStatus as tinyint;

			set @stateOneStatus = case when @c_orderStatusId = 100 then 2 when @c_orderStatusId = 101 and @c_reviewDateTime is null then 1 else 0 end;
			set @stateTwoStatus = case when @stateOneStatus = 0 and isnull(@c_sum_sent,0) = 0 then 1 when @stateOneStatus = 0 and isnull( @c_sum_sent,0) > 0  then 0 else 2 end;
			set @stateThreeStatus = case when @stateTwoStatus = 0 and isnull(@c_sum_delivered,0) = 0 then 1 when @stateTwoStatus = 0 and isnull( @c_sum_delivered,0) > 0 then 0 else 2 end;
			set @stateForStatus = case when @stateThreeStatus = 0 and @c_orderStatusId = 102 then 1 when @stateThreeStatus = 0 and @c_orderStatusId = 105 then 0 else 2 end;

			insert into @returntable values (@c_orderId,1,'در انتظار بررسی', @stateOneStatus);
			insert into @returntable values (@c_orderId,2,'در انتظار ارسال',@stateTwoStatus);
			insert into @returntable values (@c_orderId,3,'در انتظار تحویل',@stateThreeStatus);
			insert into @returntable values (@c_orderId,4,'خاتمه',@stateForStatus);

		--end
		fetch next from cr into 
		@c_orderId,@c_orderStatusId,@c_reviewDateTime,@c_sum_sent,@c_sum_delivered;
	end
	close cr;
	deallocate cr;
	select * from @returntable order by orderId,ord;
end



RETURN 0