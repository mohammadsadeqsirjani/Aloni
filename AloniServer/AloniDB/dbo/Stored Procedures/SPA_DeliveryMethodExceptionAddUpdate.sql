CREATE PROCEDURE [dbo].[SPA_DeliveryMethodExceptionAddUpdate]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@itemId as bigint,
	@itemGrpId as bigint,
	@deliveryMethod as smallint,
	@id as int out
AS
	-- check validation
	
	if(not exists (select id from TB_STORE where id = @storeId))
	begin
		set @rMsg = dbo.func_getSysMsg('invalid_store',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه فروشگاه وارد شده معتبر نمی باشد.'); 
		set @rCode = 0
		return 0
	end
	if(not exists(select top 1 1 from TB_TYP_DELIVERY_METHOD where id = @deliveryMethod))
	begin
		set @rMsg = dbo.func_getSysMsg('invalidDeliveryMethodId',OBJECT_NAME(@@PROCID),@clientLanguage,'روش ارسال معتبر نیست'); 
		set @rCode = 0
		return 0
	end
	if((@itemGrpId is null or @itemId = 0) and (@itemGrpId is null or @itemGrpId = 0))
	begin
		set @rMsg = dbo.func_getSysMsg('invalidInputData',OBJECT_NAME(@@PROCID),@clientLanguage,'هیچ کالا یا گروه کالایی معتبری را برای استثناء تعریف نکرده اید'); 
		set @rCode = 0
		return 0
	end
	if(@itemId > 0 and not exists(select top 1 1 from TB_STORE_ITEM_QTY where pk_fk_store_id = @storeId and pk_fk_item_id = @itemId))
	begin
		set @rMsg = dbo.func_getSysMsg('invalidInputData',OBJECT_NAME(@@PROCID),@clientLanguage,'کالای مورد نظر شما در پنل موجود نیست'); 
		set @rCode = 0
		return 0
	end
	if(@itemGrpId > 0 and not exists(select top 1 1 from TB_TYP_ITEM_GRP where id = @itemGrpId))
	begin
		set @rMsg = dbo.func_getSysMsg('invalidInputData',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه گروه مورد نظر شما معتبر نیست'); 
		set @rCode = 0
		return 0
	end
	if(exists(select top 1 1 from TB_STORE_DELIVERYMETHODTYPE_EXCEPTION where fk_store_id = @storeId and (fk_item_id = @itemId or fk_itemgrp_id = @itemGrpId)))
	begin
		set @rMsg = dbo.func_getSysMsg('invalidInputData',OBJECT_NAME(@@PROCID),@clientLanguage,'برای گروه/شناسه مورد نظر شما قبلا استثنایی به ثبت رسیده است'); 
		set @rCode = 0
		return 0
	end
	begin try
	if(@id = 0 or @id is null)
	begin
		insert into TB_STORE_DELIVERYMETHODTYPE_EXCEPTION(fk_item_id,fk_itemgrp_id,fk_store_id,fk_deliveryMethod_id) values(case when @itemId = 0 THEN NULL ELSE @itemId END,case when @itemGrpId = 0 THEN NULL ELSE @itemGrpId END,@storeId,@deliveryMethod)
		set @id = SCOPE_IDENTITY()
		set @rCode = 1
		set @rMsg = 'success'
	end
	else
	begin
		update TB_STORE_DELIVERYMETHODTYPE_EXCEPTION
		set 
			fk_item_id = case when @itemId = 0 THEN NULL ELSE @itemId END,
			fk_itemgrp_id =case when @itemGrpId = 0 THEN NULL ELSE @itemGrpId END,
			fk_deliveryMethod_id = @deliveryMethod
		where
			id = @id
		if(@@ROWCOUNT > 0)
		begin
			set @rMsg = 'success'
		end
		else
			set @rMsg = 'id not found'
		set @rCode = 1
	end
	end try 
	begin catch
		set @rMsg = dbo.func_getSysMsg('Error_unExpected',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
		set @rCode = 0
	end catch
RETURN 0
