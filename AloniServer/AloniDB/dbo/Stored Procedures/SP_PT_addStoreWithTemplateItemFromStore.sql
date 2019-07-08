CREATE PROCEDURE [dbo].[SP_PT_addStoreWithTemplateItemFromStore]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@sourceStoreId as bigint,
	@isCopyItemStore as BIT,
	@title as nvarchar(150),
	@title_second as nvarchar(150),
	@store_typeId as int,
	@expertise as dbo.ExpertiseTableType readonly,
	@description as nvarchar(max),
	@keyword as nvarchar(max) = null,
	@id_str as varchar(50),
	@storeId as bigint out,
	@categoryId as int = NULL ,
	@ordersNeedConfimBeforePayment as bit,
	@onlyCustomersAreAbleToSetOrder as bit,
	@onlyCustomersAreAbleToSeeItems as bit,
	@customerJoinNeedsConfirm as bit,
	@storePersonalityType as int = null,
	@storeItemGrpPanelCategories as [dbo].[LongIdTitleType] readonly,
	@uid as uniqueidentifier = null,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out
AS

	begin tran t
	begin try

	exec SP_storeAdd
	@clientLanguage  = @clientLanguage,
	@appId = @appId,
	@clientIp = @clientIp,
	@userId = @userId,
	@title = @title,
	@title_second = @title_second,
	@store_typeId = @store_typeId,
	@expertise = @expertise,
	@description = @description,
	@keyword = @keyword,
	@id_str = @id_str,
	@storeId = @storeId out,
	@categoryId = @categoryId ,
	@ordersNeedConfimBeforePayment = @ordersNeedConfimBeforePayment,
	@onlyCustomersAreAbleToSetOrder = @onlyCustomersAreAbleToSetOrder,
	@onlyCustomersAreAbleToSeeItems = @onlyCustomersAreAbleToSeeItems,
	@customerJoinNeedsConfirm = @customerJoinNeedsConfirm,
	@storePersonalityType =@storePersonalityType,
	@storeItemGrpPanelCategories = @storeItemGrpPanelCategories,
	@uid = @uid,
	@rCode = @rCode out,
	@rMsg = @rMsg out

	if(@rCode = 0)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid title',OBJECT_NAME(@@PROCID),@clientLanguage,@rMsg); 
		goto fail;
	end
	IF(@sourceStoreId IS NOT NULL AND @isCopyItemStore = 1)
	begin
	exec SP_copyTemplateItemFromStore
	@clientLanguage = @clientLanguage,
	@appId = @appId,
	@clientIp = @clientIp,
	@userId = @userId,
	@rCode = @rCode out,
	@rMsg = @rMsg out,
	@sourceStoreId = @sourceStoreId,
	@destStoreId =  @storeId 

	if(@rCode = 0)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid title',OBJECT_NAME(@@PROCID),@clientLanguage,@rMsg); 
		goto fail;
	end
	end

		commit tran t;
	end try
	begin catch
	rollback tran t;
	set @rMsg = ERROR_MESSAGE();
	goto fail;
	end catch



success:

SET @rCode = 1;

--commit transaction T
--set @rMsg = dbo.func_getSysMsg('success',OBJECT_NAME(@@PROCID),@clientLanguage,'the validation code sent.');
RETURN 0;

fail:

SET @rCode = 0;

--rollback transaction T
RETURN 0;
