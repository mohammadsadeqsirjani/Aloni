CREATE PROCEDURE [dbo].[SP_getItemWarrantyList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = null,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@userId as bigint,
	@itemId as bigint,
	@storeId as bigint
AS
	SET NOCOUNT ON

	SELECT 
		 sw.id
		,sw.title WarrantyCo
		,siw.warrantyCost
		,siw.warrantyDays
		,[dbo].[func_getPriceAsDisplayValue](dbo.func_addThousandsSeperator(warrantyCost),@clientLanguage,@storeId) WarantyPrice_dsc
	FROM
		  TB_STORE_ITEM_WARRANTY siw
		 INNER JOIN 
		  TB_STORE_WARRANTY sw 
		 ON 
		  siw.pk_fk_storeWarranty_id = sw.id
	WHERE 
		 siw.pk_fk_store_id = @storeId
		AND
		 siw.pk_fk_item_id = @itemId
		AND
		 siw.isActive <> 0
RETURN 0
