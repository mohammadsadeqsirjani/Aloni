CREATE PROCEDURE [dbo].[SP_addUpdateItemSize]
  @clientLanguage as char(2),
  @appId as tinyint,
  @clientIp as varchar(50),
  @userId as bigint,
  @rCode as tinyint out,
  @rMsg as nvarchar(max) out,
  @itemId as bigint,
  @storeId as bigint,
  @sizeInfo as nvarchar(50),
  @isActive as bit,
  @sizeCost as money
AS
	if(@storeId is null or not exists(select top 1 1 from TB_STORE where id = @storeId))
	begin
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'فروشگاه نامعتبر!'); 
		set @rCode = 0
		return
	end
	if(@itemId is null or not exists(select top 1 1 from TB_STORE_ITEM_QTY where pk_fk_item_id = @itemId and pk_fk_store_id = @storeId))
	begin
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'کالای هدف در فروشگاه شما موجود نیست'); 
		set @rCode = 0
		return
	end
	
	begin try
	if(exists(select top 1 1 from TB_STORE_ITEM_SIZE where pk_fk_item_id = @itemId and pk_fk_store_id = @storeId and pk_sizeInfo = @sizeInfo))
	begin
		update TB_STORE_ITEM_SIZE 
		set 
			isActive = @isActive, 
			sizeCost = @sizeCost 
		where 
			pk_fk_item_id = @itemId 
			and 
			pk_fk_store_id = @storeId 
		if @@ROWCOUNT > 0
		begin
		set @rCode = 1
		set @rMsg = 'success'
		end
		return
	end
	else
		begin
			insert TB_STORE_ITEM_SIZE(pk_fk_store_id,pk_fk_item_id,pk_sizeInfo,isActive,sizeCost) 
			values (@storeId,@itemId,@sizeInfo,@isActive,@sizeCost)
			set @rCode = 1
			set @rMsg = dbo.func_getSysMsg('ok',OBJECT_NAME(@@PROCID),@clientLanguage,'success!'); 
		end
	end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('ok',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
	end catch
	
RETURN 0