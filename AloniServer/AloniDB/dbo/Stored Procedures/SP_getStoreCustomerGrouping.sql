create PROCEDURE [dbo].[SP_getStoreCustomerGrouping]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@pageNo as int,
	@storeId as bigint,
	@search as nvarchar(100),
	@parent as varchar(20) = null
AS
  set nocount on
  select id,title,discountPercent,isActive,color
  from TB_STORE_CUSTOMER_GROUP where fk_store_id = @storeId
  and (@search is null or @search = '' or (title like '%' + @search + '%'))
RETURN 0
