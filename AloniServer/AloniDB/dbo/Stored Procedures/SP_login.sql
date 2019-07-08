CREATE PROCEDURE [dbo].[SP_login]
		@clientLanguage as char(2),
			@mobile VARCHAR(20),
			@appId as tinyint,
			@clientIp as varchar(50),
			@otpCode as char(5),
			@deviceInfo as varchar(50),
			@deviceId as varchar(150),
			@deviceId_appDefined as varchar(150),
			@osType as tinyint,
			@sessionId as bigint out,
			@password as varchar(150) = '',
			@authorization as char(128) out,
			--@unauthorized as bit out,
			@rCode as tinyint out,
			@rMsg as nvarchar(max) out
AS

set @rCode = 0;
		set @rMsg = '';
		--set @unauthorized = 1;

		--exec SP_authenticateReq
		--@mobile = @mobile,
		--@sessionId = @sessionId,
		--@otpCode = @otpCode,
		--@authorization =  @authorization,
		--@unauthorized = @unauthorized OUTPUT
		--if(@unauthorized = 1)
		--goto fail;


		if((@otpCode is null and @password is null ) or @deviceId is null or @deviceInfo is null or @deviceId_appDefined is null)
		begin
		set @rMsg = 'please fill all required inputs!' ;
		goto fail;
		end




		declare @Uid as bigint,@Ustatus as int;
		select @Uid = id,
		@Ustatus = fk_status_id
		 from TB_USR with(nolock) 
		 where mobile = @mobile;

		if(@Uid is null)
		begin
		set @rMsg = dbo.func_getSysMsg('invalidMobile',OBJECT_NAME(@@PROCID),@clientLanguage,'شماره موبایل وارد شده صحیح نمی باشد.'); --dbo.func_getSysMsg('notRegistered',OBJECT_NAME(@@PROCID),@clientLanguage,'You have not registered yet. please go to Registration menue.');
			goto fail;
		end
		if( @Ustatus <> 1)
		begin
		set @rMsg = dbo.func_getSysMsg('userIsBlocked',OBJECT_NAME(@@PROCID),@clientLanguage,'کاربری شما مسدود می باشد.'); -- 'user is blocked.'; --dbo.func_getSysMsg('notRegistered',OBJECT_NAME(@@PROCID),@clientLanguage,'You have not registered yet. please go to Registration menue.');
			goto fail;
		end



		set @authorization = CONVERT(VARCHAR(128), HASHBYTES('SHA2_512', cast( newid() as varchar(36))) , 2);


				begin tran t;
		begin try

		update TB_USR_SESSION
		set 
		token = HASHBYTES('SHA2_512', @authorization + CAST(id as varchar(20))), --HASHBYTES('SHA2_512', @authorization + (case cast(@appId as varchar(2)) + cast(@osType as varchar(2)) when '33' then CAST(id as varchar(20)) else CAST(@sessionId as varchar(20)) end) ),
		deviceInfo = @deviceInfo,
		lastActivityTime = getdate(),
		otpCode = null,
		fk_status_id = 4,
		loginIp = @clientIp,
		currentIp = @clientIp,
		deviceId = @deviceId,
		deviceId_appDefined = @deviceId_appDefined,
		osType = @osType,
		@sessionId = id
		where 
		((@appId in (1,2) and @osType in (1,2,4) and id = @sessionId) or (@appId = 3 and @osType = 3))
		and
		((@appId in (1,2) and @osType in (1,2,4) and otpCode = @otpCode) or (@appId = 3 and @osType = 3 and [password] = HASHBYTES('SHA2_512', @password + [salt])))
		and
		fk_usr_id = @Uid
		and
		((@appId in (1,2) and @osType in (1,2,4) and fk_status_id = 3) or (@appId = 3 and @osType = 3 and fk_status_id in(3,4)))
		and
		fk_app_id = @appId;

		if(@@ROWCOUNT <> 1)
		begin
		set @rMsg = dbo.func_getSysMsg('invalidPassword',OBJECT_NAME(@@PROCID),@clientLanguage,'رمز ورود به سیستم صحیح نمی باشد.');
		rollback tran t;
		goto fail;
		end

		commit tran t;
		end try
		begin catch
		set @rMsg = ERROR_MESSAGE();
		rollback tran t;
			goto unexpectedFail;
		end catch


		success:
			set @rCode = 1;
			set @rMsg = 'success!'; --dbo.func_getSysMsg('success',OBJECT_NAME(@@PROCID),@clientLanguage,'the validation code sent.');
			return 0;
			fail:
			set @authorization = null;
			set @rCode = 0;
			--set @rMsg = 'fail!';
			return 0;



						unexpectedFail:
		set @rCode = -1;
		return 0;