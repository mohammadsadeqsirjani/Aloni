CREATE PROCEDURE [dbo].[SP_DeleteSocialNetworkAccount]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@id as bigint 
AS
	begin try
		delete from TB_STORE_SOCIALNETWORK where id= @id
		set @rCode = 1
		set @rMsg = 'success'
	end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,ERROR_MESSAGE())
	end catch
RETURN 0