CREATE PROCEDURE [dbo].[SP_colorAddUpdate]
  @clientLanguage as char(2),
  @appId as tinyint,
  @clientIp as varchar(50),
  @userId as bigint,
  @rCode as tinyint out,
  @rMsg as nvarchar(max) out,
  @itemId as bigint,
  @storeId as bigint,
  @colorId as nvarchar(50),
  @isActive as bit,
  @colorCost as money
AS
	if(@storeId is null or not exists(select top 1 * from TB_STORE where id = @storeId))
	begin
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'فروشگاه نامعتبر!'); 
		set @rCode = 0
		return
	end
	if(@itemId is null or not exists(select top 1 * from TB_STORE_ITEM_QTY where pk_fk_item_id = @itemId and pk_fk_store_id = @storeId))
	begin
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'کالای هدف در فروشگاه شما موجود نیست'); 
		set @rCode = 0
		return
	end
	if(@colorId is null or not exists(select top 1 * from TB_COLOR where id = @colorId))
	begin
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه رنگ نامعتبر می باشد'); 
		set @rCode = 0
		return
	end
	begin try
	if(exists(select top 1 * from TB_STORE_ITEM_COLOR where pk_fk_item_id = @itemId and pk_fk_store_id = @storeId and fk_color_id = @colorId))
	begin
		update TB_STORE_ITEM_COLOR 
		set isActive = @isActive, colorCost = @colorCost 
		where pk_fk_item_id = @itemId and pk_fk_store_id = @storeId and fk_color_id = @colorId
		if @@ROWCOUNT > 0
		begin
		set @rCode = 1
		set @rMsg = 'success'
		end
		return
	end
	else
		begin
			insert TB_STORE_ITEM_COLOR(pk_fk_store_id,pk_fk_item_id,fk_color_id,isActive,colorCost) 
			values (@storeId,@itemId,@colorId,@isActive,@colorCost)
			set @rCode = 1
			set @rMsg = dbo.func_getSysMsg('ok',OBJECT_NAME(@@PROCID),@clientLanguage,'success!'); 
		end
	end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('ok',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
	end catch
	
RETURN 0
