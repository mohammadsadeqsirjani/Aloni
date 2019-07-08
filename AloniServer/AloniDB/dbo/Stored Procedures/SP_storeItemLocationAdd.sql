CREATE PROCEDURE [dbo].[SP_storeItemLocationAdd]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@title as nvarchar(100),
	@lat as float,
	@lng as float,
	@id as bigint out,
	@address as nvarchar(250)
AS
	set nocount on
	begin try 
		if(exists(select top 1 1 from TB_STORE_FAVORITE_LOCATION where title = @title and fk_store_id = @storeId))
		begin
			set @rMsg = 'عنوان تکراری می باشد'
			set @rCode = 0
			return
		end
		if(exists(select top 1 1 from TB_STORE_FAVORITE_LOCATION where [location].Lat = @lat and [location].Long = @lng and fk_store_id = @storeId))
		begin
			set @rMsg = ' مکان مورد نظر از قبل در بین مکان های نشان شده پنل موجود می باشد'
			set @rCode = 0
			return
		end
		if(exists(select top 1 1 from TB_STORE_FAVORITE_LOCATION where address = @address and fk_store_id = @storeId))
		begin
			set @rMsg = ' آدرس از قبل در بین آدرس های نشان شده پنل موجود می باشد'
			set @rCode = 0
			return
		end
		if(@id = 0)
		begin
				
				insert into TB_STORE_FAVORITE_LOCATION(title,fk_store_id,location,address) values (@title,@storeId,geography::Point(@lat,@lng,4326),@address)
				set @id = scope_identity()
				set @rMsg = 'success'
		end
		else
		begin
			update TB_STORE_FAVORITE_LOCATION 
			set 
				location = geography::Point(@lat,@lng,4326),
				title = @title,
				address = @address
			where
				id = @id
			if(@@ROWCOUNT > 0)
				set @rMsg = 'success'
			else
				set @rMsg = 'هیچ موقعیت پیشفرضی با شناسه مورد نظر شما یافت نشد'
			
		end
		set @rCode = 1
	end try
	begin catch
		
		if(not exists(select id from TB_STORE where id = @storeId))
		begin
			set @rMsg = 'شناسه فروشگاه یافت نشد'
		end
		else
			set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
	end catch
RETURN 0
