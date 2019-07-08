CREATE PROCEDURE [dbo].[SP_deleteItem]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@itemId as bigint,
	@storeId as bigint
AS
	declare @isTemplate as bit
	select @isTemplate = isTemplate from TB_ITEM where id = @itemId
	if(exists(select id from TB_ORDER_DTL  with(nolock)  where fk_store_id = @storeId and isVoid = 0 and fk_item_id = @itemId))
	begin
		set @rCode = 0;
		set @rMsg = dbo.func_getSysMsg('invalid request',OBJECT_NAME(@@PROCID),@clientLanguage,'این کالا در سفارشات فعال موجود است و قادر به حذف آن نمی باشید!')
		return
	end

	begin try
		delete from TB_STORE_ITEM_QTY where pk_fk_store_id = @storeId and pk_fk_item_id = @itemId
		if(@isTemplate = 0)
		begin
			update TB_ITEM set fk_status_id = 16 where id = @itemId
		end
		set @rCode = 1
		set @rMsg = 'success'
	end try
	begin catch
		set @rCode = 0;
		set @rMsg = dbo.func_getSysMsg('invalid request',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE());
	end catch
RETURN 0

