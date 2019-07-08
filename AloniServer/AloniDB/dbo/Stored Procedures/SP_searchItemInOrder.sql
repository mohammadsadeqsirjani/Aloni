CREATE PROCEDURE [dbo].[SP_searchItemInOrder] @clientLanguage AS CHAR(2)
	,@appId AS TINYINT
	,@clientIp AS VARCHAR(50)
	,@pageNo AS INT
	,@search AS NVARCHAR(100)
	,@parent AS VARCHAR(20)
	,@userId AS BIGINT
	,@orderId AS BIGINT
	,@state AS SMALLINT = 0
AS
SET NOCOUNT ON

IF (@state = 0)
BEGIN
	SELECT i.id
		,i.title
	FROM TB_ITEM I
	INNER JOIN TB_ORDER_DTL D ON i.id = D.fk_item_id
	WHERE D.fk_orderHdr_id = @orderId
		AND i.title LIKE '%' + @search + '%'
END
ELSE
BEGIN
	SELECT DISTINCT TYG.title grouptitle
		,i.id
		,i.title
		,d.completeLink
		,d.thumbcompeleteLink
		,i.technicalTitle
		,[dbo].[func_getPriceAsDisplayValue](SIQ.price,@clientLanguage,o.fk_store_storeId) as price--dbo.func_addThousandsSeperator(SIQ.price) + ' ' + dbo.func_getCurrencyTitleByLanguage(@clientLanguage, @userId, 1) price
		,i.isTemplate
	FROM TB_ITEM I
	INNER JOIN TB_ORDER_DTL DD ON i.id = DD.fk_item_id
	inner join TB_ORDER_HDR h on DD.fk_orderHdr_id = h.id
	inner join TB_ORDER as o on h.fk_order_orderId = o.id
	LEFT JOIN TB_TYP_ITEM_GRP TYG ON i.fk_itemGrp_id = TYG.id
	LEFT JOIN TB_STORE_ITEM_QTY SIQ ON i.id = SIQ.pk_fk_item_id
	LEFT JOIN TB_DOCUMENT_ITEM DI ON i.id = DI.pk_fk_item_id
		AND isDefault = 1
	LEFT JOIN TB_DOCUMENT D ON DI.pk_fk_document_id = d.id
		AND fk_documentType_id = 2
		AND isDeleted <> 1
	WHERE i.barcode = @search
		AND DD.fk_orderHdr_id = @orderId
	ORDER BY i.id
END

RETURN 0
