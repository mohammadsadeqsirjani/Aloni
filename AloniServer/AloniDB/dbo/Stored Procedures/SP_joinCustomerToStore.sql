CREATE PROCEDURE [dbo].[SP_joinCustomerToStore]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@customerId as bigint,
	@storeId as bigint,
	@fk_storeGroupingId as bigint = null
AS
	set @fk_storeGroupingId = case when @fk_storeGroupingId = 0 then NULL else @fk_storeGroupingId end
	if(dbo.func_GetUserStaffStore(@userId,@storeId) <> 11)
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procID),@clientLanguage,'access denied!')
		return
	end	
	if(@customerId = 0)
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procID),@clientLanguage,'invalid userId!')
		return
	end
	if(@fk_storeGroupingId is not null and @fk_storeGroupingId > 0 and not exists(select id from TB_STORE_CUSTOMER_GROUP where id = @fk_storeGroupingId and fk_store_id = @storeId))
		begin
			set @rCode = 0
			set @rMsg = dbo.func_getSysMsg('warning',OBJECT_NAME(@@PROCID),@clientLanguage,'گروه وارد شده مربوط به فروشگاه شما نیست!')
			return
		end
	if(exists(select pk_fk_usr_cstmrId from TB_STORE_CUSTOMER where pk_fk_store_id = @storeId and pk_fk_usr_cstmrId = @customerId))
	begin
		
			update TB_STORE_CUSTOMER set fk_status_id = 32,fk_customerGroup_id = @fk_storeGroupingId where pk_fk_store_id = @storeId and pk_fk_usr_cstmrId = @customerId
			set @rCode = 1
			set @rMsg = 'success'
			return 
		
	end
	begin try
		
		insert into TB_STORE_CUSTOMER(pk_fk_store_id,pk_fk_usr_cstmrId,fk_usr_actionator,actionTime,fk_status_id,requestTime,fk_customerGroup_id) values(@storeId,@customerId,@userId,GETDATE(),32,GETDATE(),@fk_storeGroupingId)
		set @rCode = 1
		set @rMsg = 'success'
	end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procID),@clientLanguage,ERROR_MESSAGE())
	end catch
RETURN 0
