CREATE PROCEDURE [dbo].[SP_storeItemLocationDelete]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@id as bigint 
AS
	set nocount on
	begin try 
		
			delete from TB_STORE_FAVORITE_LOCATION 
			where
				id = @id
			if(@@ROWCOUNT > 0)
				set @rMsg = 'success'
			else
				set @rMsg = 'هیچ موقعیت پیشفرضی با شناسه مورد نظر شما یافت نشد'
		
		set @rCode = 1
	end try
	begin catch
			set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
	end catch
RETURN 0
