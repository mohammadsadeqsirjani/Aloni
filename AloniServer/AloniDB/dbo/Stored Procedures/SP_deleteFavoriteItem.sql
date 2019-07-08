CREATE PROCEDURE [dbo].[SP_deleteFavoriteItem]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@itemId	as bigint
	
AS
	SET NOCOUNT ON

	if(@storeId is null or not exists(select top 1 1 from TB_STORE where id = @storeId))
	begin
		set @rMsg = dbo.func_getSysMsg('invalid store',OBJECT_NAME(@@PROCID),@clientLanguage,'پنل معتبر نیست'); 
		set @rCode = 0
		return
	end
	if(@itemId is null or not exists(select top 1 1 from TB_ITEM where id = @itemId) or not exists(select top 1 1 from TB_STORE_ITEM_QTY where pk_fk_store_id = @storeId and pk_fk_item_id = @itemId))
	begin
		set @rMsg = dbo.func_getSysMsg('invalid item',OBJECT_NAME(@@PROCID),@clientLanguage,' شناسه آیتم معتبر نیست و یا در پنل وجود ندارد'); 
		set @rCode = 0
		return
	end
	if(not exists(select top 1 1 from TB_STORE_ITEM_FAVORITE where pk_fk_item_id = @itemId and pk_fk_store_id = @storeId and pk_fk_usr_id = @userId))
	begin
		set @rMsg = dbo.func_getSysMsg('item exists',OBJECT_NAME(@@PROCID),@clientLanguage,'این آیتم از قبل در بین آیتم های مورد علاقه شما در پنل موجود نمی باشد'); 
		set @rCode = 0
		return
	end
	begin try
			delete from  TB_STORE_ITEM_FAVORITE where pk_fk_store_id = @storeId and pk_fk_item_id = @itemId and pk_fk_usr_id = @userId
			set @rCode = 1
			set @rMsg = dbo.func_getSysMsg('ok',OBJECT_NAME(@@PROCID),@clientLanguage,'success!'); 
	end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('ok',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
	end catch
	

RETURN 0
