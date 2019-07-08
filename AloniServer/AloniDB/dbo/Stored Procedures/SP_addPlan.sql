CREATE PROCEDURE [dbo].[SP_addPlan]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@title	as varchar(150),
	@minComission as decimal(10,2),
	@validityDate as datetime,
	@id as bigint out,
	@isActive as bit
AS
	
	if(@title is null or @minComission is null or @validityDate is null or @storeId is null)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'invalid Data!'); 
		set @rCode = 0
		return
	end
	if(@minComission > 100)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'invalid  min Comission!'); 
		set @rCode = 0
		return
	end
	if((@minComission * 1.25) > 100)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'invalid  max Comission!'); 
		set @rCode = 0
		return
	end
	if(exists(select id from TB_STORE_MARKETING where fk_store_id = @storeId and fk_status_id = 48 and id != @id) and @isActive = 1)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'Your store now has an active marketing plan. So you can not define another plan.!'); 
		set @rCode = 0
		return
	end
	begin try
		if(@id > 0)
		begin
			update TB_STORE_MARKETING
			set fk_store_id = @storeId,
				minCommission = @minComission,
				maxCommission = @minComission * 1.25,
				title = @title,
				fk_save_user_id = @userId,
				fk_status_id =case when @isActive = 1 then 48 else 49 end,
				validityDate = @validityDate
			where @id = id
			set @rCode = 1
			set @rMsg = dbo.func_getSysMsg('ok',OBJECT_NAME(@@PROCID),@clientLanguage,'success!'); 
		end
		else
		begin
			insert TB_STORE_MARKETING(fk_store_id,minCommission,maxCommission,title,fk_save_user_id,fk_status_id,validityDate) values (@storeId,@minComission,@minComission * 1.25,@title,@userId,case when @isActive = 1 then 48 else 49 end,@validityDate)
			set @id = SCOPE_IDENTITY()
			set @rCode = 1
			set @rMsg = dbo.func_getSysMsg('ok',OBJECT_NAME(@@PROCID),@clientLanguage,'success!'); 
		end
	end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('ok',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
	end catch
	

RETURN 0

