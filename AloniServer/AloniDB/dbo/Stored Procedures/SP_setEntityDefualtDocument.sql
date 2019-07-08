CREATE PROCEDURE [dbo].[SP_setEntityDefualtDocument]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@entityId as bigint,
	@uid as uniqueidentifier,
	@fk_documentType_id as int
AS
	begin try 
		
		if(@fk_documentType_id = 1 or @fk_documentType_id = 3 or @fk_documentType_id = 5)
		begin
			update TB_DOCUMENT_STORE set isDefault = 0 where pk_fk_store_id = @entityId and pk_fk_document_id in(select id from TB_DOCUMENT D inner join TB_DOCUMENT_STORE DS on d.id = DS.pk_fk_document_id where d.fk_documentType_id = @fk_documentType_id)
			update TB_DOCUMENT_STORE set isDefault = 1 where pk_fk_store_id = @entityId and pk_fk_document_id = @uid
		end
		else if(@fk_documentType_id = 2)
		begin
			update TB_DOCUMENT_ITEM set isDefault = 0 where pk_fk_item_id = @entityId 
			update TB_DOCUMENT_ITEM set isDefault = 1 where pk_fk_item_id = @entityId and pk_fk_document_id = @uid
		end
		else if(@fk_documentType_id = 4)
		begin
			update TB_DOCUMENT_USR set isDefault = 0 where pk_fk_usr_id = @entityId 
			update TB_DOCUMENT_USR set isDefault = 1 where pk_fk_usr_id = @entityId and pk_fk_document_id = @uid
		end
		
		   set @rCode = 1
		   set @rMsg = 'success'
	end try
	begin catch
			set @rMsg = dbo.func_getSysMsg('Error',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
			set @rCode = 0
	end catch	
	
RETURN 0