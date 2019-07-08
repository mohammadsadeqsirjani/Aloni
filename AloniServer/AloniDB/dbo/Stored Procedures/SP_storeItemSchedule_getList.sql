CREATE PROCEDURE [dbo].[SP_storeItemSchedule_getList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint, 
	@pageNo as int = null,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@storeId as bigint,
	@itemId as bigint
AS
	select onDayOfWeek,isActiveFrom,activeUntil
	from TB_STORE_ITEM_SCHEDULE with(nolock)
	where  fk_store_id = @storeId and fk_item_id = @itemId
	order by onDayOfWeek,isActiveFrom
	
RETURN 0
