CREATE PROCEDURE [dbo].[SP_setNewSession]
	@uid as bigint,
	@countryId as int,
	@mobile as VARCHAR(20),
	@appId as tinyint,
	@clientLanguage as char(2),

	@sessionId as bigint out,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out
AS
	
	begin try
	declare @validationCode as char(5);


	select top(1) @validationCode = us.otpCode from TB_USR_SESSION as us with(nolock)
	where us.fk_app_id = @appId and us.fk_usr_id = @uid and us.fk_status_id = 3 and DATEDIFF(MINUTE,us.saveDateTime,GETDATE()) <= 5
	order by us.id desc;

	if(@validationCode is null or @validationCode = '')
	  set @validationCode = dbo.func_RandomString(5,1);




	insert into
	 TB_USR_SESSION
	  (fk_usr_id,fk_app_id,otpCode,fk_status_id)
	  values
	  (@uid,@appId,	@validationCode,3)

	  set @sessionId = SCOPE_IDENTITY();

	  declare @objName as varchar(60),
	  @SP_sendSMS_rCode as tinyint,
	  @SP_sendSMS_rMsg as nvarchar(max);

	  set @objName = OBJECT_NAME(@@PROCID);



--	  	declare @validationCodeSmsMsg as nvarchar(max);
--	set @validationCodeSmsMsg = dbo.func_getSysMsg('sms_validationCode',OBJECT_NAME(@@PROCID),@clientLanguage,'** aloni **
--your validation code is {0}');

--	EXEC [dbo].[sp_stringFormat] @value = @validationCodeSmsMsg
--		,@arg1 = @validationCode
--		,@result = @validationCodeSmsMsg OUTPUT




	 exec [dbo].[SP_sendSMS]	 
	 @userId = @uid,
	 @countryId = @countryId,
	 @mobile = @mobile,
	 @SYSTEMMESSAGE_msgKey = 'sms_validationCode',
	 @SYSTEMMESSAGE_objectName = @objName,
	 @SYSTEMMESSAGE_lan = @clientLanguage,
	 @arg1 = @validationCode,
	 @rCode = @SP_sendSMS_rCode OUTPUT,
	 @rMsg = @SP_sendSMS_rMsg OUTPUT



	  end try
	  begin catch
	  set @rMsg = ERROR_MESSAGE();
	  goto fail;
	  end catch


	  success:
	  set @rCode = 1;
	  set @rMsg = dbo.func_getSysMsg('success',OBJECT_NAME(@@PROCID),@clientLanguage,'کد اعتبار سنجی برای شما ارسال گردید.');
	  return 0;
	  fail:
	  set @rCode = 0;
	  return 0;