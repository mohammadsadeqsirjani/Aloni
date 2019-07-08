CREATE PROCEDURE [dbo].[SP_addEmployee]
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
	@id as bigint out
AS
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
		insert into TB_STORE_EMPLOYEE(fk_store_id,fk_document_id,fullname,mobile,[description],staff,saveDatetime,fk_usr_saveUserId)
										values(@storeId,@fk_document_id,@fullName,@mobile,@description,@staff,GETDATE(),@userId)
		set @rCode = 1
		set @rMsg = 'success'
		set @id = SCOPE_IDENTITY()
	end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,ERROR_MESSAGE())
	end catch
RETURN 0
