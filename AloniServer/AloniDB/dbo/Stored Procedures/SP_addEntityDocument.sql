	CREATE PROCEDURE [dbo].[SP_addEntityDocument]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@entityId as bigint,
	@DocInfoItem as [dbo].[DocInfoItemType] readonly,
	@fk_documentType_id as int,
	@storeId as bigint
AS
	begin try 
		declare @accessLevel as tinyint = (select accessLevel from TB_STORE where id = @storeId)
		if(@fk_documentType_id = 1 or @fk_documentType_id = 3 or @fk_documentType_id = 5)
		begin
			update TB_DOCUMENT_STORE set isDefault = 0 where pk_fk_document_id in (select d.pk_fk_document_id from TB_DOCUMENT_STORE D inner join tb_document DD on d.pk_fk_document_id = DD.id
			where dd.fk_documentType_id = @fk_documentType_id and d.pk_fk_store_id = @entityId) 
			insert into TB_DOCUMENT_STORE(pk_fk_document_id,pk_fk_store_id,isDefault) select  id,@entityId,isDefault from @DocInfoItem
		end
		else if(@fk_documentType_id = 2)
		begin
			if((select isTemplate from TB_ITEM where id = @entityId) = 1 and (@accessLevel = 0 or (@accessLevel = 2 and not exists(select top 1 1 from TB_ITEM where fk_itemGrp_id in(select fk_itemGrp_id from TB_STORE_ITEMGRP_ACCESSLEVEL where fk_store_id = @storeId) and id = @entityId))))
			begin
				set @rCode = 0
				set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'امکان افزودن تصویر برای کالاهای پیشفرض سیستم وجود ندارد')
				return 
			end	
			if(exists(select pk_fk_document_id from TB_DOCUMENT_ITEM where pk_fk_item_id = @entityId and pk_fk_document_id in (select id from @DocInfoItem)))
			begin
				set @rCode = 0
				set @rMsg = dbo.func_getSysMsg('duplicate document',OBJECT_NAME(@@PROCID),@clientLanguage,'یکی از تصاویر انتخابی شما قبلا برای این کالا ثبت شده است')
				return 
			end	
		   if(exists(select pk_fk_document_id from TB_DOCUMENT_ITEM where pk_fk_item_id = @entityId and isDefault = 1))
		   begin
				update TB_DOCUMENT_ITEM set isDefault = 0 where pk_fk_item_id = @entityId
				update TB_ITEM set modifyDateTime = GETDATE() where id = @entityId
		   end
		   insert into TB_DOCUMENT_ITEM(pk_fk_document_id,pk_fk_item_id,isDefault) select top 10 id,@entityId,isDefault from @DocInfoItem
		   update TB_ITEM set modifyDateTime = GETDATE() where id = @entityId
		end
		else if(@fk_documentType_id = 4)
		begin
			update TB_DOCUMENT_USR set isDefault = 0 where pk_fk_usr_id = @entityId
			insert into TB_DOCUMENT_USR(pk_fk_document_id,pk_fk_usr_id,isDefault) select id,@entityId,isDefault from @DocInfoItem
		end
		else if (@fk_documentType_id = 7)
		begin
			update TB_TYP_ITEM_GRP set fk_document_id = (select top 1 id from @DocInfoItem) where id = @entityId
		end
		
		   set @rCode = 1
		   set @rMsg = 'success'
	end try
	begin catch
			set @rMsg = dbo.func_getSysMsg('Error',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
			set @rCode = 0
	end catch	
	
RETURN 0

