CREATE PROCEDURE [dbo].[SP_updateWarranty]
  @clientLanguage as char(2),
  @appId as tinyint,
  @clientIp as varchar(50),
  @userId as bigint,
  @rCode as tinyint out,
  @rMsg as nvarchar(max) out,
  @itemId as bigint,
  @storeId as bigint,
  @warranty as [dbo].[WarantyType] readonly
AS
	set nocount on
	begin try
		
				update TB_STORE_WARRANTY set  title =w.WarantyCo from  @warranty W join TB_STORE_WARRANTY S on w.warrantyId = s.id 
				update TB_STORE_ITEM_WARRANTY set warrantyCost = w.warrantyCost,warrantyDays = w.warrantyDays  from  @warranty W join TB_STORE_ITEM_WARRANTY S on w.warrantyId = s.pk_fk_storeWarranty_id and pk_fk_item_id = @itemId and pk_fk_store_id = @storeId
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
