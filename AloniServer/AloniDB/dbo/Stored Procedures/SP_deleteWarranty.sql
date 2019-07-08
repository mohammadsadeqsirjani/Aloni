CREATE PROCEDURE [dbo].[SP_deleteWarranty]
 @clientLanguage as char(2),
  @appId as tinyint,
  @clientIp as varchar(50),
  @userId as bigint,
  @rCode as tinyint out,
  @rMsg as nvarchar(max) out,
  @warranty as [dbo].[WarantyType] readonly,
  @itemId as bigint,
  @storeId as bigint
AS
	set nocount on
	begin try
		
				--update TB_STORE_WARRANTY set  title =w.WarantyCo from  @waranty W join TB_STORE_WARRANTY S on w.warrantyId = s.id 
				delete from TB_STORE_ITEM_WARRANTY  where pk_fk_storeWarranty_id in (select warrantyId from @warranty) and pk_fk_item_id = @itemId and pk_fk_store_id = @storeId
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