CREATE PROCEDURE [dbo].[SP_moveItemsToPanel]
  @clientLanguage as char(2),
  @appId as tinyint,
  @clientIp as varchar(50),
  @userId as bigint,
  @rCode as tinyint out,
  @rMsg as nvarchar(max) out,
  @itemList as [dbo].[LongType] readonly,
  @destStoreId as bigint,
  @storeId as bigint
AS
	set nocount on
	begin try
				update TB_ITEM set fk_savestore_id = @destStoreId where id in(select id from @itemList where id not in(select pk_fk_item_id from TB_STORE_ITEM_QTY where pk_fk_store_id = @destStoreId)) 
				update TB_STORE_ITEM_QTY set pk_fk_store_id = @destStoreId
				where pk_fk_store_id = @storeId and pk_fk_item_id in(select id from @itemList where id not in(select pk_fk_item_id from TB_STORE_ITEM_QTY where pk_fk_store_id = @destStoreId)) 
				set @rCode = 1
				set @rMsg = 'success'
				return 
		end try
		begin catch
				set @rMsg = dbo.func_getSysMsg('Error',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
				goto faild
		end catch
		faild:
				
				set @rCode = 0
				return 0
RETURN 0

