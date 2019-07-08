CREATE PROCEDURE [dbo].[SP_inviteUserToStore]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@mobile as varchar(50),
	@staffId as smallint,
	@description as nvarchar(150) = NULL
AS
	if(not exists(select id from TB_STORE where id = @storeId))
	begin
		set @rMsg = dbo.func_getSysMsg('invalid store',OBJECT_NAME(@@PROCID),@clientLanguage,'store not exists!'); 
		set @rCode = 0
		return 0
	end
	if(@mobile not LIKE '+[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
	begin
		set @rMsg = dbo.func_getSysMsg('invalid mobile',OBJECT_NAME(@@PROCID),@clientLanguage,'mobile number not valid!'); 
		set @rCode = 0
		return 0
	end
	if(not exists (select id from TB_USR where mobile = @mobile))
	begin
		begin transaction T
		begin try

			insert into TB_USR(fname, mobile, fk_country_id, fk_language_id, saveTime,id_str, fk_status_id) values ('inviteUser1',@mobile,1,@clientLanguage,GETDATE(),dbo.func_RandomString(10,0),1)
			insert into TB_USR_STAFF(fk_store_id,fk_usr_id,fk_staff_id,fk_status_id,save_fk_usr_id,saveTime,description) values (@storeId,SCOPE_IDENTITY(),@staffId,6,@userId,GETDATE(),@description)
			set @rCode = 1
			set @rMsg = cast(SCOPE_IDENTITY() as varchar(50))
			commit transaction T
			return
		end try
		begin catch
			set @rMsg = dbo.func_getSysMsg('Errore',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
			set @rCode = 0
			rollback transaction T
			return 0
		end catch
	end
	else
	begin
		declare @userId_ bigint = (select id from TB_USR where mobile = @mobile)
		if(@userId = @userId_)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'درخواست غیر مجاز!'); 
			set @rCode = 0
			return 0
		end
		if(exists(select id from TB_USR_STAFF where fk_store_id = @storeId and fk_usr_id = @userId_))
		begin
			if((select fk_status_id from TB_USR_STAFF where fk_store_id = @storeId and fk_usr_id = @userId_) in (8,6))
			begin
				set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'شما عضو پنل هستید'); 
				set @rCode = 0
				return 0
			end
			else
			begin
				update TB_USR_STAFF set fk_status_id = 6 where fk_store_id = @storeId and fk_usr_id = @userId_
				set @rCode = 1
				set @rMsg = (select cast(id as varchar(10)) from TB_USR_STAFF where fk_store_id = @storeId and fk_usr_id = @userId_)
				return
			end
		end
		begin try

			insert into TB_USR_STAFF(fk_store_id,fk_usr_id,fk_staff_id,fk_status_id,save_fk_usr_id,saveTime,description) values (@storeId,@userId_,@staffId,6,@userId,GETDATE(),@description)
			set @rCode = 1
			set @rMsg = cast(SCOPE_IDENTITY() as varchar(50))
			return
		end try
		begin catch
			set @rMsg = dbo.func_getSysMsg('Errore',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
			set @rCode = 0
			return 0
		end catch
	end 
RETURN 0
