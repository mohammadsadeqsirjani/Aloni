CREATE PROCEDURE [dbo].[SP_addShchduleStore]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@schedules as [dbo].[ScheduleType] readonly,
	@storeId as bigint
AS
	set nocount on
	
	if((select fk_status_id from TB_STORE where id = @storeId) <> 13) -- store not active
	begin
		set @rMsg = dbo.func_getSysMsg('error_storeIsInactive',OBJECT_NAME(@@PROCID),@clientLanguage,'وضعیت فروشگاه فعال نمی باشد.');  
		goto fail
	end
	if Exists(select * from @schedules where isActiveFrom > activeUntil)
	begin
		set @rMsg = dbo.func_getSysMsg('error_invalid_time_period',OBJECT_NAME(@@PROCID),@clientLanguage,'بازه زمانی اشتباه است');  
		goto fail
	end
	if Exists(select count(*),p1.onDayOfWeek,isActiveFrom,activeUntil from @schedules p1 group by p1.onDayOfWeek,isActiveFrom,activeUntil having count(*) > 1)
	begin
		set @rMsg = dbo.func_getSysMsg('error_interference_time_period',OBJECT_NAME(@@PROCID),@clientLanguage,'برای یک روز کاری نمیتوان بازه زمانی تکراری وارد کرد . لطفا در ورود بازه زمانی دقت نمایید.');  
		goto fail
	end
	delete from TB_STORE_SCHEDULE where fk_store_id = @storeId
	insert into TB_STORE_SCHEDULE(fk_store_id,onDayOfWeek,isActiveFrom,activeUntil) select @storeId,onDayOfWeek,isActiveFrom,activeUntil from @schedules
	set @rCode = 1;
	return 0
	fail:
		set @rCode = 0
RETURN 0
