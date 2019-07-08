CREATE PROCEDURE [dbo].[SP_addUpdateOrderAddress]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@id as bigint out,
	@transfereeName nvarchar(250),
	@transfereeMobile nvarchar(20),
	@transfereeTell nvarchar(20),
    @state int,
	@city int,
    @postalCode nvarchar(20),
	@postalAddress nvarchar(250),
	@lat float,
	@lng float,
	@nationalCode as varchar(11) = NULL,
	@countryCode as nvarchar(8) = NULL
	
AS
begin try
		set @countryCode = ISNULL(@countryCode,'+98')
		if(@transfereeName is null)
		begin
			set @transfereeName = (select fname+' '+ISNULL(lname,'') from TB_USR where id = @userId)
		end
		if(@transfereeMobile is null)
		begin
			set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,'وارد کردن شماره تلفن همراه الزامی است'); 
			set @rCode = 0
			return 0
		end
		if(@state is null)
		begin
			set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه استان الزامی است !'); 
			set @rCode = 0
			return 0
		end
		if(@city is null)
		begin
			set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه شهر الزامی است !'); 
			set @rCode = 0
			return 0
		end
		if(not exists(select id from TB_STATE where  id = @state ))
		begin
			set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه استان معتبر نیست !'); 
			set @rCode = 0
			return 0
		end
		if(not exists(select id from TB_CITY where  id = @city ))
		begin
			set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه شهر معتبر نیست !'); 
			set @rCode = 0
			return 0
		end
		if(@postalAddress is null)
		begin
			set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,'وارد کردن آدرس پستی الزامی است'); 
			set @rCode = 0
			return 0
		end
		if(@lat = 0 or @lng = 0 or @lat is null or @lng is null)
		begin
			set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,'وارد کردن مکان جغرافیایی الزامی است'); 
			set @rCode = 0
			return 0
		end
		if(@id is not null and not exists(select top 1 1 from TB_ORDER_ADDRESS where id = @id))
		begin
			set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه آدرس معتبر نیست'); 
			set @rCode = 0
			return 0
		end
		if(exists(select top 1 1 from TB_ORDER_ADDRESS where postalAddress = @postalAddress))
		begin
			set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,'آدرس وارد شده تکراری است'); 
			set @rCode = 0
			return 0
		end
		if(@id is null or @id = 0)
		begin
			insert into TB_ORDER_ADDRESS(transfereeName,transfereeMobile,transfereeTell,fk_state_id,fk_city_id,postalCode,postalAddress,[location],fk_usr_id,nationalCode,countryCode)
								  values(@transfereeName, @transfereeMobile,@transfereeTell,@state,@city,@postalCode,@postalAddress,geography::Point(@lat,@lng,4326),@userId,@nationalCode,@countryCode)
			set @id = SCOPE_IDENTITY()
			set @rCode = 1
			set @rMsg = 'success'
			return 0
		end
		else
		begin
			update TB_ORDER_ADDRESS
			set 
				transfereeName= @transfereeName,
				transfereeMobile = @transfereeMobile,
				transfereeTell = @transfereeTell,
				fk_state_id = @state,
				fk_city_id = @city,
				postalCode = @postalCode,
				postalAddress = @postalAddress,
				[location] = geography::Point(@lat,@lng,4326),
				fk_usr_id = @userId,
				nationalCode = @nationalCode,
				countryCode = @countryCode
			where
				id = @id
			if(@@ROWCOUNT > 0)
			begin
				set @rCode = 1
				set @rMsg = 'success'
				return 0
			end
		end
end try
begin catch
	set @rMsg = dbo.func_getSysMsg('Error',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
	set @rCode = 0
end catch
RETURN 0