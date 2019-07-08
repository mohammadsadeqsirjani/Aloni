CREATE PROCEDURE [dbo].[SP_updateEmployee]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@fullName as nvarchar(50),
	@fk_document_id as uniqueidentifier = NULL,
	@mobile as varchar(50),
	@staff as nvarchar(50),
	@description as nvarchar(500),
	@id as bigint 
AS
	--if((select fk_staff_id from TB_USR_STAFF where fk_store_id = @storeId and fk_usr_id = @userId) <> 11 )
	--begin
	--	set @rCode = 0
	--	set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@PROCID),@clientLanguage,'you are not have permission for this action!'); 
	--	return
	--end
	if(not exists(select id from TB_DOCUMENT where id = @fk_document_id))
	begin
		set @fk_document_id = NULL
	end
	
	if(@fullName is null)
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,'full name is required!')
		return
	end
	begin try
		update TB_STORE_EMPLOYEE set fk_document_id = @fk_document_id,fullname = @fullName,mobile = @mobile ,[description] = @description,staff = @staff,fk_usr_saveUserId = @userId where id = @id
		set @rCode = 1
		set @rMsg = 'success'
	end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,ERROR_MESSAGE())
	end catch
RETURN 0

