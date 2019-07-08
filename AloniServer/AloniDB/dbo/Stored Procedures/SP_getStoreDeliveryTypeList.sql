CREATE PROCEDURE [dbo].[SP_getStoreDeliveryTypeList] @clientLanguage AS CHAR(2)
	,@appId AS TINYINT
	,@clientIp AS VARCHAR(50)
	,@pageNo AS INT = NULL
	,@search AS NVARCHAR(100) = NULL
	,@parent AS VARCHAR(20) = NULL
	,@userId AS BIGINT = NULL
	,@storeId AS BIGINT
	,@orderId as bigint = null
AS
SET NOCOUNT ON
set @pageNo = ISNULL(@pageNo,0)
IF (@appId = 2) -- app kharidar
BEGIN
	SELECT SD.id
		,s.title storeTitle
		,fk_store_id storeId
		,SD.title
		,cost
		,radius
		,minOrderCost
		,[dbo].[func_getPriceAsDisplayValue](cost,@clientLanguage,@storeId) as cost_dsc--dbo.func_addThousandsSeperator(cost) + dbo.func_getCurrencyTitleByLanguage(@clientLanguage, @storeId, 1) cost_dsc
		,includeCostOnInvoice
		,storeLocation.Lat lat
		,storeLocation.Long lng
		,dbo.func_getDistanceUnitByLanguage(@clientLanguage, radius) radius_dsc
		,[dbo].[func_getPriceAsDisplayValue](minOrderCost,@clientLanguage,@storeId) as minOrderCost_dsc--dbo.func_addThousandsSeperator(minOrderCost) + dbo.func_getCurrencyTitleByLanguage(@clientLanguage, @storeId, 1) minOrderCost_dsc
		,isActive
		,isDeleted isDelete
	FROM TB_STORE S
	INNER JOIN TB_STORE_DELIVERYTYPES SD ON s.id = SD.fk_store_id
	WHERE isActive = 1
		AND isDeleted <> 1
		AND fk_store_id = @storeId
	order by SD.id
	OFFSET (@pageNo * 10) ROWS
	FETCH NEXT 10 ROW ONLY
		--AND (@orderId is null or exists(select 1 from dbo.func_getOrderHdrs(@orderId) where storeId = @storeId and sd.minOrderCost <= sum_cost_payable_withTax_withDiscount))
END
ELSE
BEGIN
	SELECT SD.id
		,s.title storeTitle
		,fk_store_id storeId
		,SD.title
		,cost
		,radius
		,minOrderCost
		,[dbo].[func_getPriceAsDisplayValue](cost,@clientLanguage,@storeId) as cost_dsc--dbo.func_addThousandsSeperator(cost) + dbo.func_getCurrencyTitleByLanguage(@clientLanguage, @storeId, 1) cost_dsc
		,includeCostOnInvoice
		,storeLocation.Lat lat
		,storeLocation.Long lng
		,dbo.func_getDistanceUnitByLanguage(@clientLanguage, cast(radius AS FLOAT)) radius_dsc
		,[dbo].[func_getPriceAsDisplayValue](minOrderCost,@clientLanguage,@storeId) as minOrderCost_dsc--dbo.func_addThousandsSeperator(minOrderCost) + dbo.func_getCurrencyTitleByLanguage(@clientLanguage, @storeId, 1) minOrderCost_dsc
		,isActive
		,isDeleted isDelete
	FROM TB_STORE S
	INNER JOIN TB_STORE_DELIVERYTYPES SD ON s.id = SD.fk_store_id
	WHERE isDeleted <> 1
		AND fk_store_id = @storeId
	order by SD.id
	OFFSET (@pageNo * 10) ROWS
	FETCH NEXT 10 ROW ONLY
END

RETURN 0
