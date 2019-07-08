CREATE PROCEDURE [dbo].[SP_deleteItemSize]
  @clientLanguage as char(2),
  @appId as tinyint,
  @clientIp as varchar(50),
  @userId as bigint,
  @rCode as tinyint out,
  @rMsg as nvarchar(max) out,
  @itemId as bigint,
  @storeId as bigint,
  @sizeInfo as nvarchar(50)
 
AS
	if(exists(select top 1 1 from TB_ORDER_DTL where vfk_store_item_size_id = @sizeInfo and fk_item_id = @itemId and fk_store_id = @storeId))
	begin
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'امکان حذف وجود ندارد'); 
		set @rCode = 0
		return
	end
	begin try
	
		delete from  TB_STORE_ITEM_SIZE  where pk_fk_item_id = @itemId and pk_fk_store_id = @storeId and pk_sizeInfo = @sizeInfo
		if @@ROWCOUNT > 0
		begin
		set @rCode = 1
		set @rMsg = 'success'
		end
		return
	end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('ok',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
	end catch
	
RETURN 0
