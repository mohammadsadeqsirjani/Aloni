CREATE PROCEDURE [dbo].[SP_searchItemsInSpesificStore]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20),
	@storeId as bigint,
	@orderByNewstItem as bit,
	@orderByCheapestItem as bit,
	@orderByMostExpensiveItem as bit,
	@orderByMostDiscountItem as bit,
	@justAvailableItems as bit,
	@includeDiscountItems as bit,
	@storeGroupingId as bigint,
	@itemGrpId as bigint
AS
	SET NOCount ON

	SELECT 
		I.id itemId,
		I.title itemTitle,
		SIQ.qty,
		SIQ.price,
		[dbo].[func_getPriceAsDisplayValue](SIQ.price,@clientLanguage,@storeId) as price_dsc ,
		SIQ.price - (SIQ.price * SIQ.discount_percent) pricewithdiscount,
		[dbo].[func_getPriceAsDisplayValue]((Siq.price - (SIQ.price * SIQ.discount_percent)),@clientLanguage,@storeId) as pricewithdiscount_dsc,
		SIQ.discount_percent,
		d.thumbcompeleteLink,
		TYG.id grpId,
		ISNULL(TYGR.title,tyg.title) grpTitle,
		SIQ.isNotForSelling,
		TYG.[type],
		(select b.sum_qty from dbo.func_getOrderDtls(null,null) as b
				join TB_ORDER o on b.orderId = o.id and o.fk_usr_customerId = @userId and o.fk_status_statusId = 100 and o.fk_store_storeId = @storeId and b.itemId = i.id) itemInCart
	FROM
		TB_ITEM I WITH(NOLOCK)
		INNER JOIN TB_STORE_ITEM_QTY SIQ WITH(NOLOCK) ON I.id = SIQ.pk_fk_item_id
		INNER JOIN TB_STORE S WITH(NOLOCK) ON S.id = SIQ.pk_fk_store_id
		INNER JOIN TB_TYP_ITEM_GRP TYG WITH(NOLOCK) ON TYG.id = I.fk_itemGrp_id
		LEFT JOIN TB_TYP_ITEM_GRP_TRANSLATIONS TYGR WITH(NOLOCK) ON TYG.id = TYGR.id AND TYGR.lan = @clientLanguage
		--LEFT JOIN TB_STORE_CUSTOM_CATEGORY SIG WITH(NOLOCK) ON S.id = SIG.fk_store_id
		--LEFT JOIN TB_STORE_CUSTOMCATEGORY_ITEM SCCC WITH(NOLOCK) ON SIG.id = SCCC.pk_fk_custom_category_id AND SIQ.pk_fk_item_id = SCCC.[pk_fk_item_id]
		LEFT JOIN TB_DOCUMENT_ITEM DI WITH(NOLOCK) ON DI.pk_fk_item_id = I.id AND DI.isDefault = 1
		LEFT JOIN TB_DOCUMENT D WITH(NOLOCK) ON D.id = DI.pk_fk_document_id
		
	WHERE
		I.fk_status_id = 15
		AND
		(SIQ.qty > CASE WHEN @justAvailableItems = 1 THEN 0 END OR @justAvailableItems = 0 OR @justAvailableItems IS NULL)
		AND
		(SIQ.discount_percent > CASE WHEN @includeDiscountItems = 1 THEN 0 END OR @includeDiscountItems = 0 OR @includeDiscountItems IS NULL)
		AND
		--(SIG.id = @storeGroupingId OR @storeGroupingId = 0 OR @storeGroupingId IS NULL)
		(i.id in (select [pk_fk_item_id] from [dbo].[TB_STORE_CUSTOMCATEGORY_ITEM] where [pk_fk_custom_category_id] = @storeGroupingId)OR @storeGroupingId = 0 OR @storeGroupingId IS NULL)
		AND
		(I.fk_itemGrp_id = @itemGrpId OR @itemGrpId = 0 OR @itemGrpId IS NULL)
		AND
		S.id = @storeId
		AND
		(SIQ.localBarcode LIKE '%'+@search+'%' OR I.uniqueBarcode LIKE '%'+@search+'%' OR I.title LIKE '%'+@search+'%' OR I.technicalTitle LIKE '%'+@search+'%'  OR @search IS NULL OR @search = '')
	ORDER BY
		CASE WHEN @orderByNewstItem = 1 THEN SIQ.saveDateTime END DESC, 
		CASE WHEN @orderByCheapestItem = 1 THEN SIQ.price END ASC,
		CASE WHEN @orderByMostExpensiveItem = 1 THEN SIQ.price END DESC,
		CASE WHEN @orderByMostDiscountItem = 1 THEN SIQ.discount_percent END DESC
	OFFSET(@pageNo * 10) ROWS
	FETCH NEXT 10 ROWS ONLY

	
RETURN 0

