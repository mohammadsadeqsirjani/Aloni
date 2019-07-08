CREATE PROCEDURE [dbo].[SP_joinToStoreByUser]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint
	
AS
	if(@appId <> 2) return
	declare @storeTypeId as int = (select fk_store_type_id from TB_STORE where id = @storeId)
	if(not exists(select id from TB_STORE where id = @storeId))
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('invalid data',OBJECT_NAME(@@PROCID),@clientLanguage,'store is not valid')
		return
	end
	if(exists(select pk_fk_usr_cstmrId from TB_STORE_CUSTOMER where pk_fk_store_id = @storeId and pk_fk_usr_cstmrId = @userId))
	begin
		declare @statusId as int = (select fk_status_id from TB_STORE_CUSTOMER where pk_fk_store_id = @storeId and pk_fk_usr_cstmrId = @userId)
		if(@statusId = 32)
		begin
			set @rCode = 0
			set @rMsg = dbo.func_getSysMsg('warning',OBJECT_NAME(@@PROCID),@clientLanguage,'you have already joined this store')
			return
		end
	
		if(@statusId = 34)
		begin
			set @rCode = 0
			set @rMsg = dbo.func_getSysMsg('warning',OBJECT_NAME(@@PROCID),@clientLanguage,'دسترسی به اطلاعات این پنل برای شما مسدود شده است.')
			return
		end
		if(@storeTypeId = 1)
		begin
			update TB_STORE_CUSTOMER set fk_status_id = 32where pk_fk_store_id = @storeId and pk_fk_usr_cstmrId = @userId
			set @rCode = 1
			set @rMsg = 'success'
			return
		end
		if(@storeTypeId = 2)
		begin
			update TB_STORE_CUSTOMER set fk_status_id = 44 where pk_fk_store_id = @storeId and pk_fk_usr_cstmrId = @userId
			set @rCode = 1
			set @rMsg = 'success'
			return
		end
		
	end
	
	if(@storeTypeId = 1)
	begin
		insert into TB_STORE_CUSTOMER(pk_fk_store_id,pk_fk_usr_cstmrId,fk_usr_requester,requestTime,fk_status_id) values(@storeId,@userId,@userId,GETDATE(),32)
		set @rCode = 1
		set @rMsg = 'success'
	end
	if(@storeTypeId = 2)
	begin
		insert into TB_STORE_CUSTOMER(pk_fk_store_id,pk_fk_usr_cstmrId,fk_usr_requester,requestTime,fk_status_id) values(@storeId,@userId,@userId,GETDATE(),44)
		set @rCode = 1
		set @rMsg = 'success'
	end
RETURN 0
