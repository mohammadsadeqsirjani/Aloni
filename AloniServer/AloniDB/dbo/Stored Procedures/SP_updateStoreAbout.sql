CREATE PROCEDURE [dbo].[SP_updateStoreAbout]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@languageId as char(2),
	@dsc as text,
	@title as varchar(100),
	@id as bigint,
	@document as dbo.DocInfoItemType readonly
AS
	if(@storeId is null or @languageId is null or @dsc is null or @title is null)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid data',OBJECT_NAME(@@PROCID),@clientLanguage,'invalid data!'); 
		set @rCode = 0
		return
	end
	
	begin try
	    delete from TB_DOCUMENT_STORE_ABOUT where pk_fk_store_about_id = @id
		update TB_STORE_ABOUT set fk_language_id= @languageId,fk_store_id = @storeId,title=@title,description=@dsc where id = @id
		insert into TB_DOCUMENT_STORE_ABOUT(pk_fk_store_about_id,pk_fk_document_id) select @id,id from @document
		set @rMsg = 'success' 
		set @rCode = 1
	end try
	begin catch
		set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
		set @rCode = 0
	end catch
RETURN 0

