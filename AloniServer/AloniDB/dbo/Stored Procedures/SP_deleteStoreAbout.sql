CREATE PROCEDURE [dbo].[SP_deleteStoreAbout]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@id as bigint
AS
	begin try
		delete from TB_DOCUMENT_STORE_ABOUT   where pk_fk_store_about_id = @id
		delete from TB_STORE_ABOUT where id = @id
		set @rMsg = 'success' 
		set @rCode = 1
	end try
	begin catch
		set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
		set @rCode = 0
	end catch
RETURN 0