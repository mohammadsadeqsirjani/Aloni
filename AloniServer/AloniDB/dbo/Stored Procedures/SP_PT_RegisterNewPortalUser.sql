CREATE PROCEDURE [dbo].[SP_PT_RegisterNewPortalUser]
	@clientLanguage as char(2),
			@mobile VARCHAR(20),
			@countryId as int,
			--@appId as tinyint,
			--@introducerUserCode as varchar(15),
			@fname as nvarchar(50),
			@lname as nvarchar(50),
			@clientIp as varchar(50),
			@cityId as int = null,
			--@authorization as char(128) out,
			--@sessionId as bigint out,
			--@password as varchar(150) = '',
			@staffId as smallint = null,
			@saveUser as bigint,
			--@unauthorized as bit out,
			@userStatus as int,
			@rCode as tinyint out,
			@rMsg as nvarchar(max) out
AS


--declare @password as varchar(150);
declare @password as varchar(150);
set @password = dbo.func_RandomString(6,0);

		if(exists(select 1 from TB_USR with (nolock) where mobile = @mobile ))
		begin
		set @rMsg = dbo.func_getSysMsg('alreadyRegistered',OBJECT_NAME(@@PROCID),@clientLanguage,'the user is already registered.');
		goto fail;
		end

		begin try
		begin tran t1;
		
		insert into TB_USR
		(fk_country_id,fk_language_id,fname,lname,mobile,saveIp,saveTime,id_str,fk_status_id,fk_cityId)
		values
		(@countryId,@clientLanguage,@fname,@lname,@mobile,@clientIp,GETDATE(),dbo.func_RandomString(10,0),@userStatus,@cityId);

		declare @salt as char(10),@insertedUserId as bigint
		set @salt = dbo.func_RandomString(10,0);
		set @insertedUserId = SCOPE_IDENTITY();

		insert into
	 TB_USR_SESSION
	  (fk_usr_id,fk_app_id,osType,fk_status_id,[password],salt)
	  values
	  (@insertedUserId,3,3,3,HASHBYTES('SHA2_512', @password + @salt),@salt);

	  --set @sessionId = SCOPE_IDENTITY();

	  if(@staffId is not null)
	  begin
	  insert into TB_USR_STAFF
	  (fk_usr_id,fk_staff_id,fk_store_id,fk_status_id,save_fk_usr_id)
	  values
	  (@insertedUserId,@staffId,null,37,@saveUser)
	  end

	  	  declare @objName as varchar(60),
	  @SP_sendSMS_rCode as tinyint,
	  @SP_sendSMS_rMsg as nvarchar(max);
	  set @objName = OBJECT_NAME(@@PROCID);

	  exec [dbo].[SP_sendSMS]	 
	 @userId = @insertedUserId,
	 @countryId = @countryId,
	 @mobile = @mobile,
	 @SYSTEMMESSAGE_msgKey = 'sms_newPortalUserPassword',
	 @SYSTEMMESSAGE_objectName = @objName,
	 @SYSTEMMESSAGE_lan = @clientLanguage,
	 @arg1 = @password,
	 @rCode = @SP_sendSMS_rCode OUTPUT,
	 @rMsg = @SP_sendSMS_rMsg OUTPUT

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
