CREATE PROCEDURE [dbo].[SP_updateStoreAutoSyncTime]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId bigint,
	@timeValue as int
AS
	begin try
		update TB_STORE
		set
			autoSyncTimePeriod = @timeValue
		where 
			id= @storeId
		set @rCode = 1
		set @rMsg = 'success'

	end try
		
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
	end catch
RETURN 0
