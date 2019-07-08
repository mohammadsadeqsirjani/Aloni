CREATE PROCEDURE [dbo].[SP_getStorePromotion]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = null,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@userId as bigint,
	@storeId as bigint
AS
	SET NOCOUNT ON
	SELECT
		id,
		cast((promotionPercent * 100) as decimal(10,2)) promotionPercent,
		promotionDsc,
		isActive
	FROM
		 TB_STORE_PROMOTION
	WHERE
		fk_store_id = @storeId

	
	
RETURN 0