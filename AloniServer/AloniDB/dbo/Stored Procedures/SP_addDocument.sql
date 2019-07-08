CREATE PROCEDURE [dbo].[SP_addDocument]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@file_Name as nvarchar(max),
	@caption as nvarchar(250),
	@fk_documentType_id as int,
	@description as nvarchar(500),
	@isDefault as bit,
	@link as nvarchar(250),
	@uid as uniqueidentifier,
	@fk_EntityId as bigint

AS
	set nocount on
	begin transaction T
	if(@file_Name is null)
	begin
		set @rMsg = dbo.func_getSysMsg('error_invalid_fileName',OBJECT_NAME(@@PROCID),@clientLanguage,'ورود عنوان فایل الزامی می باشد.'); 
		goto fail;
	end
	if(@fk_documentType_id is null or @fk_documentType_id = 0)
	begin
		set @rMsg =dbo.func_getSysMsg('error_invalid_typeId',OBJECT_NAME(@@PROCID),@clientLanguage,'ورود کد تایپ الزامی می باشد.'); 
		goto fail;
	end
	begin try
		
		
		insert into TB_DOCUMENT(id,[fileName],caption,[description],fk_documentType_id,creationDate,linkUrl,fk_usr_saveUserId,[type],isDeleted) values(@uid,@file_Name,@caption,@description,@fk_documentType_id,GETDATE(),@link,@userId,DBO.func_getFileDataType(@file_Name),0)
		if(@fk_EntityId is not null and @fk_EntityId <> 0)
		begin
			if(@fk_documentType_id = 1 or @fk_documentType_id = 3)
			begin
				insert into TB_DOCUMENT_STORE(pk_fk_document_id,pk_fk_store_id,isDefault) values(@uid,@fk_EntityId,@isDefault)
			end
			else if(@fk_documentType_id = 2)
			begin
				
				--if((select isTemplate from TB_ITEM where id = @fk_EntityId) = 1 and (@appId <> 3 and (select from tb)) )
				--begin
				--	set @rCode = 0
				--	set @rMsg = dbo.func_getSysMsg('error_illegalTarget',OBJECT_NAME(@@PROCID),@clientLanguage,'امکان افزودن تصویر برای کالاهای پیشفرض سیستم وجود ندارد')
				--	return 
				--end	
			
		   if(exists(select pk_fk_document_id from TB_DOCUMENT_ITEM where pk_fk_item_id = @fk_EntityId and isDefault = 1))
		   begin
				update TB_DOCUMENT_ITEM set isDefault = 0 where pk_fk_item_id = @fk_EntityId
				update TB_ITEM set modifyDateTime = GETDATE() where id = @fk_EntityId
		   end
				insert into TB_DOCUMENT_ITEM(pk_fk_document_id,pk_fk_item_id,isDefault) values(@uid,@fk_EntityId,@isDefault)
				update TB_ITEM set modifyDateTime = GETDATE() where id = @fk_EntityId
			end
			else if(@fk_documentType_id = 4)
			begin
				insert into TB_DOCUMENT_USR(pk_fk_document_id,pk_fk_usr_id,isDefault) values(@uid,@fk_EntityId,@isDefault)
			end
			else if (@fk_documentType_id = 7)
			begin
				update TB_TYP_ITEM_GRP set fk_document_id = @uid where id = @fk_EntityId
			end
			
		end
			set @rCode = 1;
			commit transaction T
			return 0
		end try
		begin catch
			set @rMsg = dbo.func_getSysMsg('Error_unExpected',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE());
			set @rCode = 0
			rollback transaction T
			return 0
		end catch
		fail:
		set @rCode = 0;
		rollback transaction T
		return 0;
	
RETURN 0


