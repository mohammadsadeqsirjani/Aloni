CREATE PROCEDURE [dbo].[SP_setLogin]
		@clientLanguage as char(2),
			@mobile VARCHAR(20),
			@appId as tinyint,
			@clientIp as varchar(50),

			--@authorization as char(128) out,
			@sessionId as bigint out,
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
		--@otpCode = '',
		--@authorization =  @authorization,
		--@unauthorized = @unauthorized OUTPUT
		--if(@unauthorized = 1)
		--goto fail;


		declare @Uid as bigint,
		@countryId as int,
		@status as int;
		select @Uid = id
		, @countryId = fk_country_id
		,@status = fk_status_id
		 from TB_USR with(nolock) 
		 where mobile = @mobile;

		if(@Uid is null)
		begin
		set @rMsg = dbo.func_getSysMsg('notRegistered',OBJECT_NAME(@@PROCID),@clientLanguage,'شما عضو سامانه نمی باشید. لطفا از منوی ثبت نام نسبت به عضویت اقدام بفرمائید.');
			goto fail;
		end

		if(@status <> 1)
		begin
		set @rMsg = dbo.func_getSysMsg('accountDisabled',OBJECT_NAME(@@PROCID),@clientLanguage,'حساب کاربری شما در سیستم غیر فعال گردیده است. لطفا با واحد پشتیبانی تماس حاصل نمائید.');
			goto fail;
		end



		setSession:

			 --declare @rCode_SP_setNewSession as tinyint,
			 -- @rMsg_SP_setNewSession as nvarchar(max)

			  exec [dbo].[SP_setNewSession]
			  @uid = @Uid,
			  @countryId = @countryId,
			  @mobile = @mobile,
			  @appId = @appId,
			  @clientLanguage = @clientLanguage,
			  @sessionId = @sessionId OUTPUT,
			  @rCode = @rCode OUTPUT, -- @rCode_SP_setNewSession OUTPUT,
			  @rMsg = @rMsg OUTPUT --@rMsg_SP_setNewSession OUTPUT
		if(@rCode <> 1)
		goto fail;






success:
			set @rCode = 1;
			--set @rMsg = dbo.func_getSysMsg('success',OBJECT_NAME(@@PROCID),@clientLanguage,'the validation code sent.');
			return 0;
			fail:
			set @rCode = 0;
			return 0;