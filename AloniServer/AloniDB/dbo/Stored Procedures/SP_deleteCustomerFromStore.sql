CREATE PROCEDURE [dbo].[SP_deleteCustomerFromStore]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@customerId as bigint,
	@storeId as bigint,
	@state as smallint
AS
	if(dbo.func_GetUserStaffStore(@userId,@storeId) <> 11)
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@procId),@clientLanguage,'شما مجاز به انجام این عملیات نمی باشید.')
		return
	end	
	begin try
		update TB_STORE_CUSTOMER set fk_status_id = case when @state = 1 then 43 when @state = 2 then 34 when @state = 3 then 32 end,fk_usr_actionator = @userId,actionTime = GETDATE() where pk_fk_store_id = @storeId and pk_fk_usr_cstmrId = @customerId
		set @rCode = 1
		set @rMsg = 'success'
	end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procID),@clientLanguage,ERROR_MESSAGE())
	end catch
RETURN 0
