CREATE PROCEDURE [dbo].[SP_getItemListinStore_Copy] 
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
AS
SET NOCOUNT ON
SET @pageNo = isnull(@pageNo, 0)
SELECT * INTO #temp FROM (SELECT  
		 si.pk_fk_item_id
		,si.pk_fk_store_id
		,si.localBarcode
		,si.qty
		,si.orderPoint
		,i.title
		,i.uniqueBarcode
		,CAST(cast(si.discount_percent AS INT) AS VARCHAR(10)) + ' % ' discount_percent
		,[dbo].[func_getPriceAsDisplayValue](si.price,@clientLanguage,@storeId) as price
		,[dbo].[func_getPriceAsDisplayValue](si.price - ((si.price * ISNULL(si.discount_percent, 0)) / 100),@clientLanguage,@storeId) as priceAfterDiscount
		,si.includedTax
		,si.dontShowinginStoreItem
		,si.isNotForSelling
		,dbo.func_addThousandsSeperator(si.qty) + ' ' + dbo.func_getItemUnit(@clientLanguage, si.pk_fk_item_id) qty_dsc
		,dbo.func_addThousandsSeperator(si.orderPoint) + ' ' + dbo.func_getItemUnit(@clientLanguage, si.pk_fk_item_id) orderPoint_dsc
		,i.technicalTitle
		,ISNULL(tryg.title, tyg.title) grpTitle
		,i.isTemplate
		,st.id statusId
		,ISNULL(STR_.title,st.title) statusTitle
	FROM 
		TB_STORE_ITEM_QTY si WITH (NOLOCK)
		INNER JOIN TB_ITEM i WITH (NOLOCK) ON si.pk_fk_item_id = i.id AND si.pk_fk_store_id = @storeId AND (i.displayMode = 0 or i.displayMode is null)
		INNER JOIN TB_TYP_ITEM_GRP tyg WITH (NOLOCK) ON tyg.id = i.fk_itemGrp_id AND tyg.[type] = 1
		LEFT JOIN TB_STATUS st WITH(NOLOCK) ON st.id = I.fk_status_id 
		LEFT JOIN TB_STATUS_TRANSLATIONS STR_ WITH(NOLOCK) ON STR_.id = st.id AND STR_.lan = @clientLanguage
		LEFT JOIN TB_TYP_ITEM_GRP_TRANSLATIONS tryg WITH (NOLOCK) ON tryg.id = tyg.id AND tryg.lan = @clientLanguage
	WHERE
			
		
		 ((si.orderPoint > 0 AND si.qty <= si.orderPoint) or @state <> 3) AND (si.qty = 0 or @state <> 2) AND (si.qty > 0 or @state <> 1) or @state = 0
		AND (i.title LIKE '%' + @search + '%' or @search is null or @search = '' or	i.barcode LIKE '%' + @search + '%' or si.localBarcode LIKE '%' + @search + '%')
		AND si.fk_status_id = CASE WHEN @activeItem = 1	THEN 15	ELSE si.fk_status_id END
		AND SI.dontShowinginStoreItem = CASE WHEN @showItemInStore = 1 THEN 0 WHEN @showItemInStore = 0	THEN 1 ELSE SI.dontShowinginStoreItem END
		AND si.isNotForSelling = CASE WHEN @sellItemStatus = 0 THEN 1 WHEN @sellItemStatus = 1 THEN 0 ELSE si.isNotForSelling END
		AND SI.includedTax = CASE WHEN @taxItemStatus = 0 THEN 0 WHEN @taxItemStatus = 1 THEN 1	ELSE si.includedTax	END
		AND ((isnull(SI.discount_percent, 0) = CASE WHEN @discountItemStatus = 0 THEN 0 END)OR(ISNULL(si.discount_percent, 0) > CASE WHEN @discountItemStatus = 1 THEN 0 END)OR @discountItemStatus = 2)
		AND i.isTemplate = CASE	WHEN @typeItem = 0 THEN 1 WHEN @typeItem = 1 THEN 0	ELSE i.isTemplate END
		AND (i.fk_itemGrp_id =  @itemGrpId or @itemGrpId = 0)
		
	ORDER BY 
		CASE WHEN @orderType = 1 OR @orderType = 0	THEN si.saveDateTime END DESC,
		CASE WHEN @orderType = 2 THEN si.price END ASC,
		CASE WHEN @orderType = 3 THEN si.price END DESC,
		CASE WHEN @orderType = 4 THEN si.discount_percent END ASC,
		CASE WHEN @orderType = 5 THEN si.discount_percent END DESC,
		CASE WHEN @orderType = 6 THEN si.qty END ASC,
		CASE WHEN @orderType = 7 THEN si.qty END DESC,
		CASE WHEN @orderType = 8 THEN (isnull(si.qty, 0) - isnull(si.orderPoint, 0)) END
		OFFSET(@pageNo * 10) ROWS
		FETCH NEXT 10 ROWS ONLY
	) s	
SELECT * FROM #temp
SELECT max(id) AS id ,fk_item_id
FROM   TB_STORE_ITEM_OPINIONPOLL
WHERE  fk_store_id = @storeId and isActive = 1
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