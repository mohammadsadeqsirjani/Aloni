CREATE PROCEDURE [dbo].[SP_getCompleteItemInfo]
	 @clientLanguage AS CHAR(2)
	,@appId AS TINYINT
	,@clientIp AS VARCHAR(50)
	,@pageNo AS INT = NULL
	,@search AS NVARCHAR(100)
	,@parent AS VARCHAR(20) = NULL
	,@userId AS BIGINT
	,@itemId AS BIGINT
	,@storeId AS BIGINT
AS
SET NOCOUNT ON;



with scheduleInfo as (select * from TB_STORE_ITEM_SCHEDULE with(nolock) where fk_item_id = @itemId and fk_store_id = @storeId)





SELECT 
     I.title
	,I.technicalTitle
	,I.isTemplate
	,I.fk_unit_id
	,un.title unitTitle
	,I.fk_itemGrp_id
	,ig.title grpTitle
	,ig.[type] as grpType
	,I.barcode
	,si.pk_fk_store_id storeId
	,case when si.qty < 0 then 10000 else SI.qty end qty -- برای مبحث منفی بودن موجودی
	,SI.orderPoint
	,SI.inventoryControl
	,SI.price
	,case when si.price = 0 then '' else  [dbo].[func_getPriceAsDisplayValue](SI.price,@clientLanguage,@storeId) END as price_dsc--CAST(SI.price AS VARCHAR(30)) + ' ' + dbo.func_getCurrencyTitleByLanguage(@clientLanguage, @storeId, 1) price_dsc
	,cu.id fk_country_Manufacturer
	,cu.title countryTitle
	,SI.ManufacturerCo
	,SI.localBarcode
	,SI.fk_status_id
	,SI.hasDelivery
	,case when S.fk_status_id = 13 then SI.isNotForSelling else 1 END isNotForSelling
	,SI.discount_minCnt
	,(case when SI.discount_percent >= 1 OR discount_percent = 0 then SI.discount_percent else SI.discount_percent * 100 end) discount_percent
	,case when si.price = 0 then '' else [dbo].[func_getPriceAsDisplayValue](si.price - (SI.price * (si.discount_percent + case when sp.id is null then 0 else sp.promotionPercent end)) ,@clientLanguage,@storeId) END as discountprice_dsc
	,SI.includedTax
	,SI.prepaymentPercent
	,SI.cancellationPenaltyPercent
	,SI.validityTimeOfOrder
	,SI.importerCo
	,SI.hasWarranty
	,SI.canBePurchasedWithoutWarranty
	,ISNULL(tra.review, i.review) review
	,s.title storeName
	,SI.dontShowinginStoreItem
	,I.uniqueBarcode
	,I.sex
	,cc.id cityId,cc.title cityTitle
	,SS.id stateId,ss.title stateTitle
	,village,
	unitName,
	ISNULL(i.isLocked,0) isLocked,
	case when i.itemType = 1 then 1 else 0 end doNotShowUniqueBarcode,
	case when (SIE.id is not null) then 1
	else 0 end voted,
	g.id objectId,
	isnull(gr.title,g.title) objectTitle,
	case when exists(select 1 from scheduleInfo as sch ) then 1 else 0 end as hasSchedule

	  ,substring(
					(select 
					'-' +'از ' + substring(cast(isActiveFrom as varchar(7)),0,6) + ' تا ' + substring(CAST(activeUntil as varchar(7)),0,6) as [text()]
					 from scheduleInfo --TB_STORE_ITEM_SCHEDULE with(nolock)
					where
					-- fk_store_id = 9
					--and fk_item_id = 22217 and
					 onDayOfWeek = case when DATEPART(dw,getdate())  = 7 then 0 else DATEPART(dw,getdate()) end
					for xml path (''))
					,2,2147483647 ) as todaySchedule

,dbo.FUNC_getStoreCurrentShiftStatus(@storeId,@itemId) as currentShiftStatus,

 SI.[location].Lat as lat,
 SI.[location].Long as lng,
 SI.[address],
 case when i.isTemplate = 1 then 0
	  when i.isTemplate = 0 and i.fk_savestore_id <> @storeId then 0
	  else 1 END editable
,i.findJustBarcode
,ed.id eduId
,ISNULL(edr.title,ed.title) eduTitle
,sp.promotionPercent * 100 as promotionPercent
,sp.promotionDsc
,si.commentCntPerUser
,si.commentCntPerDayPerUser
,case when s.accessLevel = 1 or GSL.id is not null or i.isTemplate = 0 then 1 else 0 END canUpdateAccessLevel
,s.fk_store_type_id storeType
,ISNULL(us.fk_status_id,0) statusId
,case when exists(select top 1 1 from TB_STORE_ITEM_FAVORITE sif where sif.pk_fk_item_id = @itemId and sif.pk_fk_store_id = @storeId and sif.pk_fk_usr_id = @userId) then 1 else 0 END isCallerFavorite 
FROM TB_ITEM I
LEFT JOIN TB_STORE_ITEM_QTY SI ON I.id = SI.pk_fk_item_id
LEFT JOIN TB_STORE S ON si.pk_fk_store_id = s.id
LEFT JOIN TB_TYP_ITEM_GRP ig ON i.fk_itemGrp_id = ig.id
LEFT JOIN TB_TYP_UNIT un ON i.fk_unit_id = un.id
LEFT JOIN TB_ITEM_TRANSLATIONS tra ON i.id = tra.id	AND tra.lan = @clientLanguage
LEFT JOIN TB_COUNTRY cu ON i.fk_country_Manufacturer = cu.id
LEFT JOIN TB_STATE SS ON SS.id = I.fk_state_id
LEFT JOIN TB_CITY CC ON CC.id = i.fk_city_id
Left Join TB_STORE_ITEM_EVALUATION SIE ON i.id = SIE.fk_item_id and s.id = SIE.fk_store_id and SIE.fk_usr_id = @userId
left join TB_TYP_OBJECT_GRP g on g.id = I.fk_objectGrp_id
left join TB_TYP_OBJECT_GRP_TRANSLATIONS gr on g.id = gr.id and gr.lan = @clientLanguage
left join TB_TYP_EDUCATION as ed on i.fk_education_id = ed.id
left join TB_TYP_EDUCATION_TRANSLATION  as edr on ed.id = edr.id and edr.lan = @clientLanguage
left join TB_STORE_PROMOTION as sp on SI.pk_fk_store_id = sp.fk_store_id
left join TB_STORE_ITEMGRP_ACCESSLEVEL GSL on s.id = GSL.fk_store_id and ig.id = GSL.fk_itemGrp_id 
left join TB_STORE_CUSTOMER us on us.pk_fk_store_id = s.id and us.pk_fk_usr_cstmrId = @userId

WHERE 
	I.id = @itemId
	--AND SI.pk_fk_store_id = CASE 
	--	WHEN @storeId IS NOT NULL
	--		AND @storeId <> 0
	--		THEN @storeId
	--	ELSE si.pk_fk_store_id
	--	END
	AND
	S.id = @storeId
	AND (
		i.title LIKE CASE 
			WHEN @search IS NOT NULL
				AND @search <> ''
				THEN '%' + @search + '%'
			ELSE i.title
			END
		OR i.technicalTitle LIKE CASE 
			WHEN @search IS NOT NULL
				AND @search <> ''
				THEN '%' + @search + '%'
			ELSE i.technicalTitle
			END
		)

-- waranty 
SELECT sw.id
	,sw.title WarrantyCo
	,siw.warrantyCost
	,siw.warrantyDays
	,[dbo].[func_getPriceAsDisplayValue](dbo.func_addThousandsSeperator(warrantyCost),@clientLanguage,@storeId) WarantyPrice_dsc
FROM TB_STORE_ITEM_WARRANTY siw
INNER JOIN TB_STORE_WARRANTY sw ON siw.pk_fk_storeWarranty_id = sw.id
WHERE siw.pk_fk_store_id = @storeId
	AND siw.pk_fk_item_id = @itemId
	AND siw.isActive <> 0

-- technical info
SELECT DISTINCT it.strValue
	,itv.[key]
	,itv.val
	,itt.[description]
	,CASE 
		WHEN typ2.title IS NOT NULL
			THEN typ2.title
		ELSE typ1.title
		END title
	,CASE 
		WHEN typ2.[type] IS NOT NULL
			THEN typ2.[type]
		ELSE typ1.[type]
		END type
	,CASE 
		WHEN typ2.[order] IS NOT NULL
			THEN typ2.[order]
		ELSE typ1.[order]
		END 'order'
FROM tb_item i
INNER JOIN tb_item_technicalinfo it ON i.id = it.pk_fk_item_id
LEFT JOIN tb_technicalinfo_values itv ON it.pk_fk_technicalinfo_id = itv.id
LEFT JOIN tb_technicalinfo_table itt ON itv.fk_technicalinfo_table_id = itt.id
LEFT JOIN TB_TYP_TECHNICALINFO typ1 ON it.pk_fk_technicalInfo_id = typ1.id
LEFT JOIN TB_TYP_TECHNICALINFO typ2 ON itt.id = typ2.fk_technicalinfo_table_id
WHERE
 i.id = @itemId
 AND
 ((it.isPublic = 1 and @appId = 2) or @appId <> 2)
-- document tab
SELECT completeLink
	,thumbcompeleteLink
	,isDefault
	,D.id
FROM TB_STORE_ITEM_QTY S
INNER JOIN TB_ITEM I ON s.pk_fk_item_id = i.id
INNER JOIN TB_DOCUMENT_ITEM dti ON i.id = dti.pk_fk_item_id
INNER JOIN TB_DOCUMENT D ON dti.pk_fk_document_id = D.id
WHERE dti.pk_fk_item_id = @itemId
	AND fk_documentType_id = 2
	AND isDeleted <> 1
	AND s.pk_fk_store_id = @storeId
order by dti.isDefault DESC
-- color
SELECT c.id
	,c.title
	,sc.isActive
	,ISNULL(sc.colorCost,0) colorCost
FROM TB_COLOR c
INNER JOIN TB_STORE_ITEM_COLOR sc ON c.id = sc.fk_color_id
WHERE sc.pk_fk_item_id = @itemId
	AND sc.pk_fk_store_id = @storeId

-- size
SELECT pk_sizeInfo
	,isActive
	,ISNULL(sizeCost,0) sizeCost
FROM TB_STORE_ITEM_SIZE
WHERE pk_fk_item_id = @itemId
	AND pk_fk_store_id = @storeId
	


	--opinionPoll
DECLARE @RC int;
EXECUTE @RC =  [dbo].[SP_opinionpoll_getList]
		@clientLanguage = @clientLanguage,
		@appId = @appId,
		@clientIp = @clientIp,
		@userId = @userId,
		@opinionPollId = NULL,
		@storeId = @storeId,
		@itemId = @itemId,
		@itemBarcode = NULL,
		@itemGrpType = NULL,
		@sex = NULL,
		@itemGrpId = NULL,
		@itemType = NULL,
		@isActive = 1,
		@publish = NULL,
		@resultIsPublic = NULL,
		@startDateTime = NULL,
		@endDateTime = NULL,
		@opinionPollIsRunning = NULL,
		@pageNo = 0,
		@search = NULL,
		@parent = NULL,
		@sort_countOfparticipants = 0,
		@sort_totalAvg = 0,
		@sort_startDateTime = 0


-- item in card
 select b.sum_qty from dbo.func_getOrderDtls(null,null) as b
 join TB_ORDER o on b.orderId = o.id and o.fk_usr_customerId = @userId and [dbo].[func_getOrderStatus](o.id,o.fk_status_statusId,o.lastDeliveryDateTime) = 100 and o.fk_store_storeId = @storeId and b.itemId = @itemId
 
 select scc.id,scc.title
 from TB_STORE_CUSTOM_CATEGORY as scc
 join TB_STORE_CUSTOMCATEGORY_ITEM as scci on scc.id = scci.pk_fk_custom_category_id
 where scci.pk_fk_item_id = @itemId and scc.fk_store_id = @storeId 

 

RETURN 0
