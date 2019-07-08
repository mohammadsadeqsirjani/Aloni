CREATE PROCEDURE [dbo].[SP_updatePassword]
		@clientLanguage as char(2),
			--@mobile VARCHAR(20),
			@appId as tinyint,
			@clientIp as varchar(50),
			@otpCode as varchar(5),
			@oldPassword as varchar(150),
			@newPassword as varchar(150),
			@sessionId as bigint,

			@authorization as char(128) out,

			@unauthorized as bit out,
			@rCode as tinyint out,
			@rMsg as nvarchar(max) out
			AS

			set @unauthorized = 0;

			if((@oldPassword is null or @oldPassword = '') and  ( @otpCode is null or  @otpCode = ''))
			begin
			set @rMsg = dbo.func_getSysMsg('oldPasswordAndOtpCodeAreNull',OBJECT_NAME(@@PROCID),@clientLanguage,'لطفا رمز عبور قبلی / کد اعتبار سنجی را وارد نمایید.');
		    goto fail;
			end

			if(@newPassword is null or len(@newPassword) < 6)
			begin
			set @rMsg = dbo.func_getSysMsg('passwordIsNotCorrect',OBJECT_NAME(@@PROCID),@clientLanguage,'حداقل طول گذرواژه 6 کارکتر می باشد.');
		    goto fail;
			end


			if(@sessionId is null)
			begin
			set @rMsg = dbo.func_getSysMsg('sessionIdIsNull',OBJECT_NAME(@@PROCID),@clientLanguage,'session Id is required.');
		    goto fail;
			end


				declare @salt as char(10),@newAuthorization as char(128);
		set @salt = dbo.func_RandomString(10,0);
		set @newAuthorization = CONVERT(VARCHAR(128), HASHBYTES('SHA2_512', cast( newid() as varchar(36))) , 2);

			declare @userId as bigint;
		select @userId = fk_usr_id from TB_USR_SESSION
		where id = @sessionId;

		begin try
		begin tran t




		update TB_USR_SESSION
		set fk_status_id = 5
		where fk_usr_id = @userId and fk_status_id in (3,4) and fk_app_id = @appId and id <> @sessionId;


			update TB_USR_SESSION
			set [password] = HASHBYTES('SHA2_512', @newPassword + @salt),salt = @salt,@authorization = @newAuthorization,otpCode = null
			where 
			id = @sessionId
			 and 
			        ((@oldPassword is null and @otpCode is not null and @authorization is null)  or   token = HASHBYTES('SHA2_512', @authorization + CAST(@sessionId as varchar(20))))
			  and
			  (
						  ((@otpCode is null or @otpCode = '') and @oldPassword is not null and @oldPassword <> '' and [password] = HASHBYTES('SHA2_512', @oldPassword + salt)) 
						  or 
						  ((@oldPassword is null or @oldPassword = '') and @otpCode is not null and @otpCode <> '' and otpCode = @otpCode)
			  )
			  and 
				fk_app_id in (3)
				 and 
				 fk_app_id = @appId; 

			if(@@ROWCOUNT <> 1)
			begin
			set @unauthorized = 1;
			set @rMsg = dbo.func_getSysMsg('incorrectOldPassword',OBJECT_NAME(@@PROCID),@clientLanguage,'رمز عبور قبلی صحیح نمی باشد. در صورت فراموشی رمز عبور نسبت به بازیابی رمز عبور اقدام نمایید.');
			rollback tran t;
			goto fail; 
			end

			set @authorization = @newAuthorization;


				commit tran t
			end try
			begin catch
			set @rMsg = ERROR_MESSAGE();
			rollback tran t;
			goto unexpectedFail;
			end catch
			
	  success:
	  set @rCode = 1;
	  set @rMsg = dbo.func_getSysMsg('success',OBJECT_NAME(@@PROCID),@clientLanguage,'the validation code sent.');
	  return 0;
	  fail:
	  set @rCode = 0;
	  return 0;

	    unexpectedFail:
		set @rCode = -1;
		return 0;