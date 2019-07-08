CREATE PROCEDURE [dbo].[SP_deleteDocument]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@DocInfoItem as [dbo].[DocInfoItemType] readonly,
	@fk_documentType_id as int,
	@fk_entityId as bigint,
	@storeId as bigint
AS
	SET NOCOUNT ON
	if(@fk_documentType_id = 0 and @fk_entityId = 0)
	begin
		if(
			(exists(select pk_fk_document_id from TB_DOCUMENT_ITEM where pk_fk_document_id in (select id from @DocInfoItem))) 
				or (exists(select pk_fk_document_id from TB_DOCUMENT_STORE where pk_fk_document_id in (select id from @DocInfoItem))) 
				or (exists(select pk_fk_document_id from TB_DOCUMENT_USR where pk_fk_document_id in (select id from @DocInfoItem))) 
				or (exists(select pk_fk_document_id from TB_DOCUMENT_STORE_ABOUT where pk_fk_document_id in (select id from @DocInfoItem))) 
				or (exists(select pk_fk_document_id from TB_DOCUMENT_STORE_VITRIN where pk_fk_document_id in (select id from @DocInfoItem)))
		  )
		begin
			SET @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,'Your selected image or images are attributed to an entity in the system and can not be deleted.'); 
			set @rCode = 0
			return
		end
		update TB_DOCUMENT SET isDeleted = 1,modifyDatetime = GETDATE(),fk_usr_deletedId = @userId WHERE id = (select id from @DocInfoItem)
		SET @rCode = 1
		SET @rMsg = dbo.func_getSysMsg('DONE',OBJECT_NAME(@@PROCID),@clientLanguage,'SUCCESS!'); 
	end
	else
	begin
		if(@fk_documentType_id = 1 or @fk_documentType_id = 3 or @fk_documentType_id = 5)
		begin
			delete from TB_DOCUMENT_STORE where pk_fk_document_id in (select id from @DocInfoItem) and pk_fk_store_id = @fk_entityId
			SET @rCode = 1
			SET @rMsg = dbo.func_getSysMsg('DONE',OBJECT_NAME(@@PROCID),@clientLanguage,'SUCCESS!'); 
		end
		else if(@fk_documentType_id = 2)
		begin
			declare @accessLevel as tinyint = (select accessLevel from TB_STORE where id = @storeId)
			if((select isTemplate from TB_ITEM where id = @fk_entityId) = 1 and (@accessLevel = 0 or (@accessLevel = 2 and not exists(select top 1 1 from TB_ITEM where fk_itemGrp_id in(select fk_itemGrp_id from TB_STORE_ITEMGRP_ACCESSLEVEL where fk_store_id = @storeId) and id = @fk_entityId))))
			begin
				set @rCode = 0
				set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'امکان حذف تصویر کالاهای پیشفرض سیستم وجود ندارد')
				return 
			end		
		  delete from TB_DOCUMENT_ITEM where  pk_fk_document_id in (select id from @DocInfoItem) and pk_fk_item_id = @fk_entityId
		  SET @rCode = 1
		  SET @rMsg = dbo.func_getSysMsg('DONE',OBJECT_NAME(@@PROCID),@clientLanguage,'SUCCESS!'); 
		end
		else if(@fk_documentType_id = 4)
		begin
		  delete from TB_DOCUMENT_USR where  pk_fk_document_id in (select id from @DocInfoItem) and pk_fk_usr_id = @fk_entityId
		  SET @rCode = 1
		  SET @rMsg = dbo.func_getSysMsg('DONE',OBJECT_NAME(@@PROCID),@clientLanguage,'SUCCESS!'); 
		end
		else if(@fk_documentType_id = 10)
		begin
		  delete from TB_DOCUMENT_STORE_ABOUT where  pk_fk_document_id in (select id from @DocInfoItem) 
		  SET @rCode = 1
		  SET @rMsg = dbo.func_getSysMsg('DONE',OBJECT_NAME(@@PROCID),@clientLanguage,'SUCCESS!'); 
		end
	end
RETURN 0
