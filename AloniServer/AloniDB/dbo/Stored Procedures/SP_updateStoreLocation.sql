CREATE PROCEDURE [dbo].[SP_updateStoreLocation]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@countryId as int,
	@cityId as int,
	@addressFull as nvarchar(500),
	@address as varchar(500),
	@lat as float,
	@lng as float,
	@email as varchar(50),
	@phones as dbo.PhoneType readonly
AS
	
	set nocount on
	-- check validation
	if(dbo.func_GetUserStaffStore(@userId,@storeId) <> 11 AND @appId = 1)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid Country',OBJECT_NAME(@@PROCID),@clientLanguage,'شما مجاز به انجام این عملیات نیستید'); 
		goto fail;
	end
	if(@countryId is null or @countryId = 0 or not exists(select top 1 1 from TB_COUNTRY where id = @countryId))
	begin
		set @rMsg = dbo.func_getSysMsg('invalid Country',OBJECT_NAME(@@PROCID),@clientLanguage,'کاربر محترم کشور انتخاب نشده و یا معتبر نمی باشد'); 
		goto fail;
	end
	if(@cityId is null or @cityId = 0 or not exists(select top 1 1 from TB_CITY where id = @cityId))
	begin
		set @rMsg =dbo.func_getSysMsg('invalid City',OBJECT_NAME(@@PROCID),@clientLanguage,'کاربر محترم شهر انتخاب نشده و یا معتبر نمی باشد'); 
		goto fail;
	end
	if((select COUNT(phone) from @phones) < 0)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid phone',OBJECT_NAME(@@PROCID),@clientLanguage,'phone required!');
		goto fail;
	end
	if(@addressFull is null)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid address',OBJECT_NAME(@@PROCID),@clientLanguage,'address required!'); 
		goto fail;
	end
	if(@lat is null or @lng is null)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid location',OBJECT_NAME(@@PROCID),@clientLanguage,'location required!');
		goto fail;
	end
	if(@email IS NOT NULL AND dbo.FUNC_emailIsValid(@email) = 0)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid email',OBJECT_NAME(@@PROCID),@clientLanguage,'ایمل وارد شده معتبر نمی باشد');
		goto fail;
	end


	declare @existingCountry as int;
	select @existingCountry = fk_country_id from TB_STORE where id = @storeId;
	if(@existingCountry is not null and @existingCountry <> @countryId and exists(select 1 from TB_ORDER where fk_store_storeId = @storeId)) 
	begin
		set @rMsg = dbo.func_getSysMsg('illegal_countryCannotChange',OBJECT_NAME(@@PROCID),@clientLanguage,'امکان تغییر کشور پنل به علت وجود سفارش ممکن نمی باشد. لطفا با واحد پشتیبانی تماس حاصل نمائید.');
		goto fail;
	end


	begin try
	begin tran t
	

		update TB_STORE
		set 
		fk_country_id = @countryId,
		fk_city_id = @cityId,
		address_full = @addressFull,
		[address] = @address,
		[location] =geography::Point(@lat, @lng, 4326),
		email = @email
		
		where id = @storeId
		delete from TB_STORE_PHONE where fk_store_id = @storeId
		insert into TB_STORE_PHONE(fk_store_id,phone,isActive,isDefault) select @storeId,phone,1,isDefault from @phones
		--if(not exists(select id from TB_FINANCIAL_ACCOUNT where fk_store_id = @storeId))
		--begin
		--	declare @fk_currency_id as int = (select fk_currency_id from TB_COUNTRY where id = @countryId )
		--	declare @usrName nvarchar(500)= (select isnull(fname,'') + ' '+ isnull(lname,'') from TB_USR where id = @userId)
		--	declare @staffTitle nvarchar(100)= (select ISNULL(sr.title,s.title) from TB_STAFF s left join TB_STAFF_TRANSLATIONS sr on s.id = sr.id where (sr.lan = 'fa' or lan is null) and s.id = 11)
		--	declare @Financial_Account_Title1 as varchar(100) = (select ISNULL(B.title,A.title) from TB_TYP_FINANCIAL_ACCOUNT_TYPE A left join TB_TYP_FINANCIAL_ACCOUNT_TYPE_TRANSLATIONS B on A.id = B.id and B.lan = @clientLanguage  where A.id = 2 )
		--	declare @Financial_Account_Title2 as varchar(100) = (select ISNULL(B.title,A.title) from TB_TYP_FINANCIAL_ACCOUNT_TYPE A left join TB_TYP_FINANCIAL_ACCOUNT_TYPE_TRANSLATIONS B on A.id = B.id and  B.lan = @clientLanguage where A.id = 3 )
		--	insert into TB_FINANCIAL_ACCOUNT(fk_typFinancialAccountType_id,title,fk_status_id,fk_store_id,fk_currency_id) values (2, (@Financial_Account_Title1 +  @usrName +  ' _ ' + @staffTitle),36,@storeId,@fk_currency_id),(3, ISNULL((@Financial_Account_Title2 +  @usrName +  ' _ ' + @staffTitle),'__bug'),36,@storeId,@fk_currency_id)
		--end
		declare @currencyId as int;
		select @currencyId = fk_currency_id from TB_COUNTRY where id = @countryId;
		update TB_FINANCIAL_ACCOUNT set fk_currency_id =  @currencyId where fk_store_id = @storeId
		commit tran t
	end try
	begin catch
		rollback tran t;
		set @rMsg =  dbo.func_getSysMsg('invalid location',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE());
		goto fail;
	end catch
	success:
			set @rCode = 1;
			set @rMsg = 'ok'
			return 0;

	fail:
		set @rCode = 0;
		return 0;
RETURN 0
