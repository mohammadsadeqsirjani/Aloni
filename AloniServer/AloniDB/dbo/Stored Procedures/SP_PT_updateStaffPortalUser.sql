CREATE PROCEDURE [dbo].[SP_PT_updateStaffPortalUser]
	 @clientLanguage as char(2),
	@appId AS TINYINT,
	@clientIp AS VARCHAR(50),
	@mobile VARCHAR(20),
	@staffId as smallint = null,
	@saveUser as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out
AS
	declare @password as varchar(150);
set @password = dbo.func_RandomString(6,0);




		if(not exists(select 1 from TB_USR with (nolock) where mobile = @mobile ))
		begin
		set @rMsg = dbo.func_getSysMsg('dontExistUser',OBJECT_NAME(@@PROCID),@clientLanguage,'کاربری با این شماره موبایل ایجاد نشده است.');
		goto fail;
		end



		begin try
		begin tran t1;
		
		declare @userId as bigint, @countryUser as int;
		select @userId = id,@countryUser = fk_country_id from TB_USR with (nolock) where mobile = @mobile
		
	  update TB_USR_STAFF
	  set fk_status_id = 38
	  where fk_usr_id = @userId and fk_staff_id in (31,32,33)

	  if(@staffId is not null)
	  begin

	  update TB_USR_STAFF 
	  set fk_status_id = 37
	  where fk_usr_id = @userId and fk_staff_id = @staffId

	  if(@@ROWCOUNT = 0)
	  begin
	  insert into TB_USR_STAFF
	  (fk_usr_id,fk_staff_id,fk_status_id,save_fk_usr_id,saveTime)
	  values
	  (@userId,@staffId,37,@saveUser,GETDATE())
	  end
	  end


	    if(not exists (select 1 from TB_USR_SESSION where fk_usr_id = @userId and fk_app_id = 3))
		begin
		declare @salt as char(10),@insertedUserId as bigint
		set @salt = dbo.func_RandomString(10,0);

		insert into
	    TB_USR_SESSION
	    (fk_usr_id,fk_app_id,osType,fk_status_id,[password],salt)
	    values
	    (@userId,3,3,3,HASHBYTES('SHA2_512', @password + @salt),@salt);

		 declare @objName as varchar(60),
		  @SP_sendSMS_rCode as tinyint,
		  @SP_sendSMS_rMsg as nvarchar(max);
		  set @objName = OBJECT_NAME(@@PROCID);

		 exec [dbo].[SP_sendSMS]	 
		 @userId = @userId,
		 @countryId = @countryUser,
		 @mobile = @mobile,
		 @SYSTEMMESSAGE_msgKey = 'sms_newPortalUserPassword',
		 @SYSTEMMESSAGE_objectName = @objName,
		 @SYSTEMMESSAGE_lan = @clientLanguage,
		 @arg1 = @password,
		 @rCode = @SP_sendSMS_rCode OUTPUT,
		 @rMsg = @SP_sendSMS_rMsg OUTPUT
		end

		commit tran t1;
		end try
		begin catch
		rollback tran t1;
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