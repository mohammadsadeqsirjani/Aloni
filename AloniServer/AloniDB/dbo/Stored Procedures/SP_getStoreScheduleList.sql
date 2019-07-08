CREATE PROCEDURE [dbo].[SP_getStoreScheduleList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint, 
	@pageNo as int = null,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@storeId as bigint
AS
	select fk_store_id,onDayOfWeek,isActiveFrom,activeUntil from TB_STORE_SCHEDULE
	where  fk_store_id = @storeId 
	order by onDayOfWeek,isActiveFrom
	
	
RETURN 0
