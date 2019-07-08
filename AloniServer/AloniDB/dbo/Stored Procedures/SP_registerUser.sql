		
		CREATE PROCEDURE [dbo].[SP_registerUser]
			@clientLanguage as char(2),
			@mobile VARCHAR(20),
			@countryId as int,
			@appId as tinyint,
			@introducerUserCode as varchar(15),
			@fname as nvarchar(50),
			@lname as nvarchar(50),
			@clientIp as varchar(50),
			@email as varchar(100) = null,
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
	


		declare @callingCode as varchar(5);
		select @callingCode = callingCode
		 from TB_COUNTRY with(nolock)
		 where id = @countryId;

		 if(@callingCode is null)
		 begin
		  set @rMsg = 'invalid countryId!'
		  goto fail;
		 end

		 if(@email is not null and @email not like '%@%')
		 begin
		  set @rMsg = dbo.func_getSysMsg('invalidEmail',OBJECT_NAME(@@PROCID),@clientLanguage,'آدرس ایمیل وارد شده معتبر نمی باشد.');
		  goto fail;
		 end

		 if(@mobile not like (@callingCode + '%') or len(@mobile) > 14 )
		 begin
		 --set @rCode = 0;
		 set @rMsg = 'invalid mobile no!'
		  goto fail;
		 end

		 if(not exists(select 1 from TB_APP with(nolock) where id = @appId))
		 begin
		  set @rMsg = 'invalid app id!'
		  goto fail;
		 end

		declare @introducerUid as bigint;
		if(@introducerUserCode is not null and @introducerUserCode <> '')
		begin
			select top (1) @introducerUid = id
			from TB_USR with(nolock)
			where
			   (@introducerUserCode like 'AI-%' and id_str = @introducerUserCode) 
			or (@introducerUserCode like '+%' and mobile = @introducerUserCode)
			or (@introducerUserCode like '00%' and mobile = @callingCode + RIGHT('000'+@introducerUserCode,10)) 
		    or (@introducerUserCode like '0%' and mobile = @callingCode + RIGHT('000'+@introducerUserCode,10))

			if(@introducerUid is null)
			begin
			set @rMsg = dbo.func_getSysMsg('invalid_introducer',OBJECT_NAME(@@PROCID),@clientLanguage,'کد معرف وارد شده صحیح نمی باشد.');
			goto fail;
			end
		end






		declare @existingSameUid as bigint;
		select @existingSameUid = id
			from TB_USR with(nolock)
			where 
			mobile = @mobile;



		begin try
		begin transaction T;

			if(@existingSameUid is not null)
			begin

				if(exists(select 1 from TB_USR_SESSION with(nolock) where fk_app_id = @appId and fk_usr_id = @existingSameUid and fk_status_id <> 3))
				begin
				set @rMsg = dbo.func_getSysMsg('alreadyRegistered',OBJECT_NAME(@@PROCID),@clientLanguage,'شما از قبل عضو سیستم شده اید. لطفا از منوی ورود اقدام فرمائید.');
				rollback transaction T;
				goto fail;
				end





			
			update TB_USR
			 set 
			 fname = @fname,
			 lname = @lname,
			 email = @email,
			 fk_country_id = @countryId,
			 fk_introducer = @introducerUid,
			 fk_language_id = @clientLanguage,
			 fk_status_id = 1
			 where
			 id = @existingSameUid;

			 declare @Financial_Account_Title as nvarchar(100);
	set @Financial_Account_Title = 'unknown accTitle ';


			select @Financial_Account_Title = ISNULL(B.title,A.title)
			 from TB_TYP_FINANCIAL_ACCOUNT_TYPE A
			  inner join TB_TYP_FINANCIAL_ACCOUNT_TYPE_TRANSLATIONS B on A.id = B.id 
			  where A.id = 1 and (B.lan = @clientLanguage or b.lan is null);



			 declare @staffTitle nvarchar(100);
			  select top 1 @staffTitle = ISNULL(sr.title,s.title) 
			 from TB_STAFF s left join TB_STAFF_TRANSLATIONS sr on s.id = sr.id 
			 where (sr.lan = 'fa' or lan is null) and s.id = 21


			 if(@appId = 2 )
			 begin
				update TB_FINANCIAL_ACCOUNT
					set title = @Financial_Account_Title + ISNULL(@fname,'') + ' ' + isnull(@lname,'') +  ' _ ' + isnull(@staffTitle,'')
				where fk_usr_userId = @existingSameUid and fk_typFinancialAccountType_id = 1
			 end
			 --goto setSession;
	
			end --of @existingSameUid is not null
			else
			begin
			insert into TB_USR
			(fk_country_id,fk_introducer,fk_language_id,fname,lname,mobile,saveIp,saveTime,id_str,fk_status_id)
			 values
			  (@countryId,@introducerUid,@clientLanguage,@fname,@lname,@mobile,@clientIp,GETDATE(),'AI-' + dbo.func_RandomString(6,0),1);

			  set @existingSameUid = SCOPE_IDENTITY();

			   if(@appId = 2 )
			 begin
				declare @fk_currency_id as int = (select fk_currency_id from TB_COUNTRY where id = @countryId )
				insert into TB_FINANCIAL_ACCOUNT(fk_typFinancialAccountType_id,fk_usr_userId,title,fk_status_id,fk_currency_id) values (1,@existingSameUid, ISNULL(@Financial_Account_Title,'') +  ISNULL(@fname,'') + ' ' + isnull(@lname,'') +  ' _ ' + isnull(@staffTitle,'') ,36,@fk_currency_id)
				insert into TB_USR_STAFF(fk_usr_id,saveTime,fk_staff_id,fk_status_id) values (@existingSameUid,GETDATE(),21,38)
			 end

			 
	  

			  goto setSession;
			end





			setSession:

			 --declare @rCode_SP_setNewSession as tinyint,
			 -- @rMsg_SP_setNewSession as nvarchar(max)

			  exec dbo.SP_setNewSession
			  @uid = @existingSameUid,
			  @countryId = @countryId,
			  @mobile = @mobile,
			  @appId = @appId,
			  @clientLanguage = @clientLanguage,
			  @sessionId = @sessionId OUTPUT,
			  @rCode = @rCode OUTPUT, -- @rCode_SP_setNewSession OUTPUT,
			  @rMsg = @rMsg OUTPUT --@rMsg_SP_setNewSession OUTPUT
		if(@rCode <> 1)
		begin
		rollback transaction T;
		goto fail;
		end









		commit transaction T;
		end try
		begin catch
		rollback transaction T;
		set @rMsg = ERROR_MESSAGE();
		goto unexpectedFail;
		end catch
			success:
			set @rCode = 1;
			--commit transaction T
			--set @rMsg = dbo.func_getSysMsg('success',OBJECT_NAME(@@PROCID),@clientLanguage,'the validation code sent.');
			return 0;
			fail:
			set @rCode = 0;
			--rollback transaction T
			return 0;

			unexpectedFail:
			set @rCode = 0;
			return 0;
