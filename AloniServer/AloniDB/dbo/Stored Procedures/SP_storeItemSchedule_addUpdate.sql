CREATE PROCEDURE [dbo].[SP_storeItemSchedule_addUpdate]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@schedules as [dbo].[ScheduleType] readonly,
	@storeId as bigint,
	@itemId as bigint
AS
	set nocount on
	
	if((select fk_status_id from TB_STORE where id = @storeId) <> 13) -- store not active
	begin
		set @rMsg = dbo.func_getSysMsg('storeIsInactive',OBJECT_NAME(@@PROCID),@clientLanguage,'سازمان مرتبط با شخص فعال نمی باشد.');  
		goto fail
	end

	if(not exists(select 1 from TB_STORE_ITEM_QTY with(nolock) where pk_fk_store_id = @storeId and pk_fk_item_id = @itemId))
	begin
		set @rMsg = dbo.func_getSysMsg('invalidStoreOrItemId',OBJECT_NAME(@@PROCID),@clientLanguage,'پرسنل و سازمان ورودی با یکدیگر مطابقت ندارند.');  
		goto fail
	end

	if(dbo.FUNC_validateTimeSchedule(@schedules) = 0)
	begin
		set @rMsg = dbo.func_getSysMsg('overlapTime',OBJECT_NAME(@@PROCID),@clientLanguage,'بازه زمانی وارد شده تداخل دارد');  
		goto fail
	end

	delete from TB_STORE_ITEM_SCHEDULE where fk_store_id = @storeId and fk_item_id = @itemId
	insert into TB_STORE_ITEM_SCHEDULE(fk_store_id,fk_item_id,onDayOfWeek,isActiveFrom,activeUntil) 
	select @storeId,@itemId,onDayOfWeek,isActiveFrom,activeUntil from @schedules
	set @rCode = 1;
	set @rMsg = 'success'
	return 0
	fail:
		set @rCode = 0
RETURN 0