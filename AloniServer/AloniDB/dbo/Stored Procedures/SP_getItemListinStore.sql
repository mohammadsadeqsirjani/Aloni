CREATE PROCEDURE [dbo].[SP_getItemListinStore] 
	@clientLanguage AS CHAR(2)
	,@appId AS TINYINT
	,@clientIp AS VARCHAR(50)
	,@userId AS BIGINT
	,@pageNo AS INT = 0
	,@search AS NVARCHAR(100)
	,@type AS smallint
	,@parent AS VARCHAR(20) = NULL
	,@storeId AS BIGINT
	,@state AS TINYINT
	,@activeItem AS BIT = 0
	,@orderType AS SMALLINT = 1
	,@showItemInStore AS SMALLINT = 2
	,@sellItemStatus AS SMALLINT = 2
	,@taxItemStatus AS SMALLINT = 2
	,@discountItemStatus AS SMALLINT = 2
	,@typeItem AS SMALLINT = 2
	,@itemGrpId AS BIGINT
	,@catId as BIGINT
AS
SET NOCOUNT ON
SET @pageNo = isnull(@pageNo, 0)
set @type = case when @type = 0 then 1 else @type END
select * into #itemGrps from (select * from dbo.func_subGrpItemByGrpItemId(@itemGrpId)) as tt
SELECT * INTO #temp FROM (SELECT  
		 si.pk_fk_item_id
		,si.pk_fk_store_id
		,si.localBarcode
		,si.qty
		,isnull(si.orderPoint,0) orderPoint
		,i.title
		,i.uniqueBarcode
		,isnull(discount_percent,0) discount_percent
		,price
		--,CAST(cast(case when si.discount_percent >=1 or si.discount_percent = 0 then si.discount_percent else si.discount_percent * 100 end as int) AS nVARCHAR(10)) + ' % ' discount_percent
		--,[dbo].[func_getPriceAsDisplayValue](si.price,@clientLanguage,@storeId) as price
		--,[dbo].[func_getPriceAsDisplayValue](si.price - ((si.price * ISNULL(si.discount_percent, 0))),@clientLanguage,@storeId) as priceAfterDiscount
		,si.includedTax
		,si.dontShowinginStoreItem
		,si.isNotForSelling
		--,case when si.qty > 0 then dbo.func_addThousandsSeperator(si.qty) + ' ' + dbo.func_getItemUnit(@clientLanguage, si.pk_fk_item_id) else '0' end  qty_dsc
		--,case when si.orderPoint > 0 then dbo.func_addThousandsSeperator(si.orderPoint) + ' ' + dbo.func_getItemUnit(@clientLanguage, si.pk_fk_item_id) else '0' end orderPoint_dsc
		,i.technicalTitle
		,ISNULL(tryg.title, tyg.title) grpTitle
		,i.isTemplate
		,st.id statusId
		,ISNULL(STR_.title,st.title) statusTitle
		,i.barcode
		--,dbo.func_getItemUnit(@clientLanguage, si.pk_fk_item_id) unit_dsc
		,case when s.accessLevel = 1 or GSL.id is not null or i.isTemplate = 0 then 1 else 0 END isEditable
		,(isnull(si.qty, 0) - isnull(si.orderPoint, 0)) neareByOrderPoint
		,0 pollId
		,isnull(i.isLocked,0) isLocked
		,(select count(id) from  TB_STORE_ITEM_EVALUATION SIE with(nolock) where i.id = sie.fk_item_id and fk_status_id = 107 and fk_store_id = @storeId) commentWaitForConfirmCnt
	FROM 
		TB_STORE s
		INNER JOIN TB_STORE_ITEM_QTY si WITH (NOLOCK) on s.id = si.pk_fk_store_id
		INNER JOIN TB_ITEM i WITH (NOLOCK) ON si.pk_fk_item_id = i.id AND si.pk_fk_store_id = @storeId
		INNER JOIN TB_TYP_ITEM_GRP tyg WITH (NOLOCK) ON tyg.id = i.fk_itemGrp_id
		LEFT  JOIN TB_STATUS st WITH(NOLOCK) ON st.id = I.fk_status_id 
		LEFT  JOIN TB_STATUS_TRANSLATIONS STR_ WITH(NOLOCK) ON STR_.id = st.id AND STR_.lan = @clientLanguage
		LEFT  JOIN TB_TYP_ITEM_GRP_TRANSLATIONS tryg WITH (NOLOCK) ON tryg.id = tyg.id AND tryg.lan = @clientLanguage
		LEFT  JOIN  TB_STORE_ITEMGRP_ACCESSLEVEL GSL with(nolock) on GSL.fk_store_id = s.id and GSL.fk_itemGrp_id = i.fk_itemGrp_id
		
	WHERE
			(i.itemType = @type)
		
		AND (((si.orderPoint > 0 AND si.qty <= si.orderPoint) or @state <> 3) AND (si.qty = 0 or @state <> 2) AND (si.qty > 0 or @state <> 1) or @state = 0)
		AND 
			(((i.title LIKE case when @search is not null and @search <> '' then  '%' + @search + '%' end) or  @search is null or @search = '')  or (i.barcode LIKE (case when @search is not null and @search <> '' then '%' + @search + '%' end) or  @search is null or @search = '') or ((si.localBarcode LIKE case when @search is not null and @search <> '' then '%' + @search + '%' end) or  @search is null or @search = ''))
		AND (si.fk_status_id = CASE WHEN @activeItem = 1	THEN 15	ELSE si.fk_status_id END and i.fk_status_id not in(16,57))
		AND (SI.dontShowinginStoreItem = CASE WHEN @showItemInStore = 1 THEN 0 WHEN @showItemInStore = 0	THEN 1 ELSE SI.dontShowinginStoreItem END or @type <> 1)
		AND (si.isNotForSelling = CASE WHEN @sellItemStatus = 0 THEN 1 WHEN @sellItemStatus = 1 THEN 0 ELSE si.isNotForSelling END or @type <> 1)
		AND (SI.includedTax = CASE WHEN @taxItemStatus = 0 THEN 0 WHEN @taxItemStatus = 1 THEN 1	ELSE si.includedTax	END or @type <> 1)
		AND (((isnull(SI.discount_percent, 0) = CASE WHEN @discountItemStatus = 0 THEN 0 END)OR(ISNULL(si.discount_percent, 0) > CASE WHEN @discountItemStatus = 1 THEN 0 END)OR @discountItemStatus = 2) or @type <> 1)
		AND i.isTemplate = CASE	WHEN @typeItem = 0 THEN 1 WHEN @typeItem = 1 THEN 0	ELSE i.isTemplate END
		AND i.fk_itemGrp_id in(select id from #itemGrps) 
		AND	(i.itemtype = @type or i.itemtype =case when @type = 0 then 1 end)
		AND (i.id = cast(@parent as bigint) or @parent is null or @parent = '0')
		AND (@catId = 0 or @catId is null or(@catId > 0 and i.id not in(select SCI.pk_fk_item_id from TB_STORE_CUSTOMCATEGORY_ITEM SCI where SCI.pk_fk_custom_category_id = @catId)))
	ORDER BY 
		CASE WHEN @orderType = 1 OR @orderType = 0	THEN i.modifyDateTime END DESC,
		CASE WHEN @orderType = 2 THEN si.price END ASC,
		CASE WHEN @orderType = 3 THEN si.price END DESC,
		CASE WHEN @orderType = 4 THEN si.discount_percent END ASC,
		CASE WHEN @orderType = 5 THEN si.discount_percent END DESC,
		CASE WHEN @orderType = 6 THEN si.qty END ASC,
		CASE WHEN @orderType = 7 THEN si.qty END DESC,
		CASE WHEN @orderType = 8 THEN (isnull(si.qty, 0) - isnull(si.orderPoint, 0)) END,
		CASE WHEN @orderType = 9 THEN i.barcode END,
		CASE WHEN @orderType = 10 THEN i.uniqueBarcode END,
		CASE WHEN @orderType = 11 THEN i.fk_itemGrp_id END
		OFFSET(@pageNo * 10) ROWS
		FETCH NEXT 10 ROWS ONLY
	) s	option(recompile)
SELECT 
	     pk_fk_item_id
		,pk_fk_store_id
		,localBarcode
		,qty
		,orderPoint
		,title
		,uniqueBarcode
		,CAST(cast(case when discount_percent >=1 or discount_percent = 0 then discount_percent else discount_percent * 100 end as int) AS nVARCHAR(10)) + ' % ' discount_percent
		,[dbo].[func_getPriceAsDisplayValue](price,@clientLanguage,@storeId) as price
		,[dbo].[func_getPriceAsDisplayValue](price - ((price * ISNULL(discount_percent, 0))),@clientLanguage,@storeId) as priceAfterDiscount
		,includedTax
		,dontShowinginStoreItem
		,isNotForSelling
		,case when qty > 0 then dbo.func_addThousandsSeperator(qty) + ' ' + dbo.func_getItemUnit(@clientLanguage, pk_fk_item_id) else '0' end  qty_dsc
		,case when orderPoint > 0 then dbo.func_addThousandsSeperator(orderPoint) + ' ' + dbo.func_getItemUnit(@clientLanguage, pk_fk_item_id) else '0' end orderPoint_dsc
		,technicalTitle
		,grpTitle
		,isTemplate
		,statusId
		,statusTitle
		,barcode
		,dbo.func_getItemUnit(@clientLanguage, pk_fk_item_id) unit_dsc
		,isEditable
		,(isnull(qty, 0) - isnull(orderPoint, 0)) neareByOrderPoint
		,pollId
		,isLocked
		,commentWaitForConfirmCnt
FROM
#temp

SELECT max(id) AS id ,fk_item_id
FROM   TB_STORE_ITEM_OPINIONPOLL
WHERE  fk_store_id = @storeId and isActive = 1 and fk_item_id in(select pk_fk_item_id from #temp)
GROUP BY fk_item_id

SELECT
	 i.pk_fk_item_id
	,d.completeLink
	,d.thumbcompeleteLink
FROM
	#temp i
	INNER JOIN TB_DOCUMENT_ITEM DI WITH (NOLOCK) ON DI.pk_fk_item_id = i.pk_fk_item_id AND DI.isDefault = 1
	INNER JOIN TB_DOCUMENT D ON DI.pk_fk_document_id = D.id
RETURN 0