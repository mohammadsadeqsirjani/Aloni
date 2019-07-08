CREATE PROCEDURE [dbo].[SP_RequestCorrectionItemTemplateInformationAddUpdate]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@userId as bigint,
	@storeId as bigint,
	@id as bigint out,
	@itemId as bigint,
	@suggestedTitle as varchar(150) = NULL,
	@suggestedBarcode as varchar(150) = NULL,
	@documentList as GuidType readonly,
	@description as varchar(350) = NULL
AS
	SET NOCOUNT ON
	if(not exists(select top 1 1 from TB_STORE where id = @storeId))
		begin
			set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه فروشگاه نامعتبر است'); 
			set @rCode = 0
			return 0
		end
	if(not exists(select top 1 1 from TB_ITEM where id = @itemId and isTemplate = 1) or not exists(select top 1 1 from TB_STORE_ITEM_QTY where pk_fk_item_id = @itemId and pk_fk_store_id = @storeId))
		begin
			set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه آیتم معتبر نیست'); 
			set @rCode = 0
			return 0
		end
		if(@id > 0 and not exists(select top 1 1 from TB_REQUEST_CORRECTION_TEMPLATE_INFORMATION where id = @id))
		begin
			set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,' شناسه درخواست شده معتبر نیست'); 
			set @rCode = 0
			return 0
		end
		if(@id > 0 and not exists(select top 1 1 from TB_REQUEST_CORRECTION_TEMPLATE_INFORMATION where id = @id and fk_store_id = @storeId))
		begin
			set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,'درخواست متعلق به پنل شما نیست'); 
			set @rCode = 0
			return 0
		end
		if(@id > 0 and (select fk_status_id from TB_REQUEST_CORRECTION_TEMPLATE_INFORMATION where id = @id) = 402)
		begin
			set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,'درخواست بررسی شده و شما قادر به ویرایش ان نیستید، لطفا درخواست جدید ثبت نمایید'); 
			set @rCode = 0
			return 0
		end
		begin try
		if(@id > 0 )
		begin
			update TB_REQUEST_CORRECTION_TEMPLATE_INFORMATION set suggestedTitle = @suggestedTitle,suggestedBarcode = @suggestedBarcode,description = @description where id = @id
			if(@@ROWCOUNT > 0)
			begin
				set @rMsg = 'success'
				set @rCode = 1
				return 0
			end
		end
		else
		begin
			insert into TB_REQUEST_CORRECTION_TEMPLATE_INFORMATION(fk_store_id,fk_usr_id,fk_item_id,suggestedTitle,suggestedBarcode,description) values(@storeId,@userId,@itemId,@suggestedTitle,@suggestedBarcode,@description)
				set @id = scope_identity()
				
		
		end
		if((select count(*) from @documentList) > 0)
		begin
			delete from TB_DOCUMENT_REQUEST_CORRECTION_ITEM_TEMPLATE_INFORMATION where pk_fk_request_correction_id = @id
			insert into TB_DOCUMENT_REQUEST_CORRECTION_ITEM_TEMPLATE_INFORMATION(pk_fk_document_id,pk_fk_request_correction_id) select id,@id from @documentList
		end
		set @rMsg = 'success'
		set @rCode = 1
		return 0
		end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,ERROR_MESSAGE())
	end catch
RETURN 0
