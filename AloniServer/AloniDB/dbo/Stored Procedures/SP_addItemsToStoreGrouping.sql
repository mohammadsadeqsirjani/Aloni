CREATE PROCEDURE [dbo].[SP_addItemsToStoreGrouping]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@itemIdList as [dbo].[LongType] readonly,
	@StoreGroupingId as bigint,
	@storeId as bigint
AS
	SET NOCOUNT ON
	declare @itemCount int = (select count(id) from @itemIdList)
	
	if(@itemCount = 0)
	begin
		set @rMsg = dbo.func_getSysMsg('error_invalid_item',OBJECT_NAME(@@PROCID),@clientLanguage,'خطا : کد کالا معتبر نمی باشد.'); 
		set @rCode = 0
		return
	end
	if(@storeId is null)
	begin
		set @rMsg = dbo.func_getSysMsg('error_invalid_store',OBJECT_NAME(@@PROCID),@clientLanguage,'خطا: کد فروشگاه معتبر نمی باشد.'); 
		set @rCode = 0
		return
	end
	if((select count(id) from TB_STORE where id = @storeId) = 0)
	begin
		set @rMsg = dbo.func_getSysMsg('error_invalid_store',OBJECT_NAME(@@PROCID),@clientLanguage,'خطا: کد فروشگاه معتبر نمی باشد.'); 
		set @rCode = 0
		return
	end
	if((select count(pk_fk_item_id) from TB_STORE_ITEM_QTY where pk_fk_item_id in ((select id from @itemIdList)) and pk_fk_store_id = @storeId) != @itemCount)
	begin
		set @rMsg = dbo.func_getSysMsg('error_invalid_items_of_store',OBJECT_NAME(@@PROCID),@clientLanguage,'خطا: کالاهای وارد شده به فروشگاه مورد نظر تعلق ندارند.'); 
		set @rCode = 0
		return
	end
	begin try
		insert into TB_STORE_ITEM_GROUPING(pk_fk_grouping_id,pk_fk_store_id,pk_fk_item_id) select @StoreGroupingId,@storeId,id from @itemIdList
		set @storegroupingId = SCOPE_IDENTITY()
		set @rCode = 1
		
	end try
	begin catch
		set @rMsg = dbo.func_getSysMsg('Error_unExpected',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
		set @rCode = 0
	end catch
RETURN 0
