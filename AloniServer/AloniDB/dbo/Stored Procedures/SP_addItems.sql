CREATE PROCEDURE [dbo].[SP_addItems]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@itemIds as dbo.LongType readonly
AS
	-- check validation
	declare @itemsCount int = (select count(id) from @itemIds)
	if(not exists (select id from TB_STORE where id = @storeId))
	begin
		set @rMsg = dbo.func_getSysMsg('invalid_store',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه فروشگاه وارد شده معتبر نمی باشد.'); 
		set @rCode = 0
		return 0
	end
	if((select fk_status_id from TB_ITEM where id in (select  id from @itemIds)) <> 15)
	begin
		set @rMsg = dbo.func_getSysMsg('item_invalid_status',OBJECT_NAME(@@PROCID),@clientLanguage,'کالای انتخابی در سیستم فعال نمی باشد و مجاز به استفاده نیست..'); 
		set @rCode = 0
		return 0
	end
	if(exists(select pk_fk_item_id from TB_STORE_ITEM_QTY where pk_fk_store_id = @storeId and pk_fk_item_id in ((select id from @itemIds))))
	begin
		set @rMsg = dbo.func_getSysMsg('item_exist',OBJECT_NAME(@@PROCID),@clientLanguage,'کالای انتخابی از قبل موجود می باشد.'); 
		set @rCode = 0
		return 0
	end
	begin try
		insert into TB_STORE_ITEM_QTY(pk_fk_store_id,pk_fk_item_id,fk_status_id) select @storeId,id,fk_status_id from TB_ITEM where isTemplate = 1 and fk_status_id = 15 and id in(select id from @itemIds ) 
		set @rCode = 1
		set @rMsg = 'success'
	end try 
	begin catch
		set @rMsg = dbo.func_getSysMsg('Error_unExpected',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
		set @rCode = 0
	end catch
RETURN 0