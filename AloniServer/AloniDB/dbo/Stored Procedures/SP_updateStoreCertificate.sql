CREATE PROCEDURE [dbo].[SP_updateStoreCertificate]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@id as bigint out,
	@storeId as bigint,
	@title as varchar(250),
	@dsc as varchar(250),
	@documents as  [dbo].[DocInfoItemType] readonly,
	@cerId as bigint
AS
	SET nocount on

	if(@title is null)
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('invalid_title',OBJECT_NAME(@@PROCID),@clientLanguage, 'title must to be set!')
		return 0
	end
	if(@storeId is null or not exists(select id from TB_STORE where id = @storeId))
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('invalid_Store',OBJECT_NAME(@@PROCID),@clientLanguage, 'store not exists!')
		return 0
	end
	if((select COUNT(*) from @documents) = 0)
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('invalid_Certificate',OBJECT_NAME(@@PROCID),@clientLanguage, 'certificate image not exists!')
		return 0
	end
	begin try
		if(@cerId > 0)
		begin
			delete from TB_DOCUMENT_STORE_CERTIFICATE where pk_fk_store_certificate_id = @cerId
			update TB_STORE_CERTIFICATE set fk_store_id = @storeId,title = @title,dsc =@dsc where id = @cerId
			set @id = @cerId
			insert into TB_DOCUMENT_STORE_CERTIFICATE(pk_fk_document_id,pk_fk_store_certificate_id) select id,@id from @documents
		end
		else
		begin
			insert into TB_STORE_CERTIFICATE(fk_store_id,title,dsc,fk_status_id) values(@storeId,@title,@dsc,12)
			set @id = SCOPE_IDENTITY()
			insert into TB_DOCUMENT_STORE_CERTIFICATE(pk_fk_document_id,pk_fk_store_certificate_id) select id,@id from @documents
		end
		set @rCode = 1
		set @rMsg = 'success'
	end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@PROCID),@clientLanguage, ERROR_MESSAGE())
	end catch

RETURN 0
