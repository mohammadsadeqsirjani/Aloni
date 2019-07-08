create PROCEDURE [dbo].[SP_getAdvertisementList] @clientLanguage AS CHAR(2)
	,@appId AS TINYINT
	,@clientIp AS VARCHAR(50)
	,@pageNo AS INT
	,@search AS NVARCHAR(100)
	,@parent AS VARCHAR(20)
	,@userId AS BIGINT
	,@sessionId AS BIGINT
AS
DECLARE @userLocation GEOGRAPHY = (
		SELECT loc
		FROM TB_USR_SESSION
		WHERE id = @sessionId
		);

WITH result
AS (
	SELECT DISTINCT ADV.id
		,ADV.dsc
		,CASE WHEN ADV.type = 2 AND DO.completeLink IS NULL THEN DO1.completeLink ELSE do.completeLink END banerUrl
		,CASE WHEN ADV.type = 2 AND DO.thumbcompeleteLink IS NULL THEN DO1.thumbcompeleteLink ELSE do.thumbcompeleteLink END thumbBanerurl
		,ADV.[url]
		,ST.id storeId
		,St.title storeTitle
		,ST.[address]
		,IT.id itemId
		,IT.title itemTitle
		,STI.price
		,[dbo].[func_getPriceAsDisplayValue](STI.price, @clientLanguage, ST.id) AS price_dsc
		,STI.discount_percent * 100 AS discount
		,'%' + REPLACE(cast((isnull(STI.discount_percent, 0) * 100) AS VARCHAR(50)), '.00', '') AS discount_dsc
		,STI.price - (STI.price * STI.discount_percent) AS priceAfterDiscount
		,[dbo].[func_getPriceAsDisplayValue](STI.price - (STI.price * STI.discount_percent), @clientLanguage, ST.id) AS priceAfterDiscount_dsc
		,ADV.[location].Lat Lat
		,ADV.[location].Long Long
		,ADV.selectEvent
		,ADV.[type]
		,@userLocation.STDistance(ADV.[location]) distance
	FROM 
	TB_ADVERTISING ADV
	LEFT JOIN TB_DOCUMENT DO ON ADV.fk_document_bannerId = DO.id
	LEFT JOIN TB_DOCUMENT_ITEM DI ON ADV.fk_item_id = DI.pk_fk_item_id and DI.isDefault = 1
	LEFT JOIN TB_DOCUMENT DO1 ON DI.pk_fk_document_id = DO1.id
	LEFT JOIN TB_DOCUMENT_STORE DS ON ADV.fk_store_id = DS.pk_fk_store_id AND DS.isDefault = 1
	LEFT JOIN TB_DOCUMENT DO2 ON DS.pk_fk_document_id = DO2.id 
	LEFT JOIN TB_STORE ST ON ADV.fk_store_id = ST.id
	LEFT JOIN TB_ITEM IT ON ADV.fk_item_id = IT.id
	LEFT JOIN TB_STORE_ITEM_QTY STI ON IT.id = STI.pk_fk_item_id AND STI.fk_status_id = 15 and STI.pk_fk_store_id = ST.id
	WHERE (
			ADV.[type] = CASE 
				WHEN @parent IS NOT NULL
					AND @parent <> ''
					THEN cast(@parent AS INT)
				ELSE ADV.[type]
				END
			)
			AND 
			ADV.isActive <> 0
		--AND do.fk_documentType_id IN (2,3,5)
	)

SELECT *
INTO #temp
FROM result

SELECT DISTINCT *
	--,dbo.func_addThousandsSeperator(price) + ' ' + dbo.func_getCurrencyTitleByLanguage(@clientLanguage, storeId, 1) price_
	--,dbo.func_addThousandsSeperator(price - (price * discount_percent / 100)) + ' ' + dbo.func_getCurrencyTitleByLanguage(@clientLanguage, storeId, 1) purePrice
FROM #temp
WHERE (
		itemTitle LIKE CASE 
			WHEN @search IS NOT NULL
				AND @search <> ''
				THEN '%' + @search + '%'
			ELSE itemTitle
			END
		OR storeTitle LIKE CASE 
			WHEN @search IS NOT NULL
				AND @search <> ''
				THEN '%' + @search + '%'
			ELSE storeTitle
			END
		)
ORDER BY distance

SELECT st.id
	,TYSE.id storeExpertiseId
	,TYSE.title storeExpertiseTitle
FROM TB_STORE ST
LEFT JOIN TB_STORE_EXPERTISE STE ON ST.id = STE.pk_fk_store_id
LEFT JOIN TB_TYP_STORE_EXPERTISE TYSE ON STE.pk_fk_expertise_id = TYSE.id
WHERE TYSE.isActive = 1
	AND st.id IN (
		SELECT storeId
		FROM #temp
		)

SELECT st.id
	,C.id categoryId
	,isnull(tc.title, C.title) title
FROM TB_STORE ST
INNER JOIN TB_TYP_STORE_CATEGORY C ON ST.fk_store_category_id = C.id
LEFT JOIN TB_TYP_STORE_CATEGORY_TRANSLATIONS TC ON c.id = TC.id
	AND tc.lan = @clientLanguage
WHERE C.isActive = 1
	AND st.id IN (
		SELECT storeId
		FROM #temp
		)

RETURN 0
