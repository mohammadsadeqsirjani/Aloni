CREATE PROCEDURE [dbo].[SP_getItemSaleNegativeCnt]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = 0,
	@search as nvarchar(100),
	@parent as varchar(20) = null,
	@storeId as bigint
AS
	SET NOCOUNT ON
	SELECT 
		COUNT(pk_fk_item_id) cnt
	FROM
		TB_STORE_ITEM_QTY
	WHERE
		pk_fk_store_id = @storeId AND canBeSalesNegative = 1
RETURN 0

