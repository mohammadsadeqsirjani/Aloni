CREATE PROCEDURE [dbo].[SP_PT_updateMarketerUser]
	@clientLanguage as char(2),
	@appId AS TINYINT,
	@clientIp AS VARCHAR(50),
	@fk_user_id bigint,
	@fk_staff_id as smallint,
	@fk_status_id as int,
	@fk_store_id as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out
AS
	    if(@fk_user_id is null)
		begin
		set @rMsg = dbo.func_getSysMsg('dontExistUser',OBJECT_NAME(@@PROCID),@clientLanguage,'کاربر وجود ندارد');
		goto fail;
		end
		if(@fk_staff_id is null)
		begin
		set @rMsg = dbo.func_getSysMsg('dontExistUser',OBJECT_NAME(@@PROCID),@clientLanguage,'سمت کاربر نمی تواند خالی باشد');
		goto fail;
		end
		if(@fk_status_id is null)
		begin
		set @rMsg = dbo.func_getSysMsg('dontExistUser',OBJECT_NAME(@@PROCID),@clientLanguage,'وضعیت کاربر نمی تواند خالی باشد');
		goto fail;
		end

		begin try
		begin tran t;

		update TB_USR
		set fk_status_id = @fk_status_id
		where id = @fk_user_id

		 if(@@ROWCOUNT = 0)
		 begin
		 set @rMsg = dbo.func_getSysMsg('dontExistUser',OBJECT_NAME(@@PROCID),@clientLanguage,'وضعیت کاربر تغییر نیافت .');
		 goto fail;
		 end

		 if(exists (select 1 from TB_USR_STAFF where fk_usr_id = @fk_user_id and fk_store_id = @fk_store_id))
		 BEGIN
		 update TB_USR_STAFF
		 set fk_staff_id = @fk_staff_id
		 where fk_usr_id = @fk_user_id and fk_store_id = @fk_store_id
		 END
		 else
		 BEGIN
		 INSERT INTO [dbo].[TB_USR_STAFF]
           ([fk_usr_id]
           ,[fk_staff_id]
           ,[fk_store_id]
           ,[fk_status_id]
           ,[saveTime])
     VALUES
           (@fk_user_id
           ,@fk_staff_id
           ,@fk_store_id
           ,8
           ,GETDATE())
		 END


		commit tran t;
		end try
		begin catch
		rollback tran t;
		set @rMsg = ERROR_MESSAGE();
		goto fail;
		end catch

		success:
		set @rCode = 1;
		set @rMsg = 'success!'; --dbo.func_getSysMsg('success',OBJECT_NAME(@@PROCID),@clientLanguage,'the validation code sent.');
		return 0;
		fail:
		set @rCode = 0;
		--set @rMsg = 'fail!';
		return 0;

RETURN 0
