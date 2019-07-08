CREATE PROCEDURE [dbo].[SP_deleteStoreCertificate]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@id as bigint,
	@storeId as bigint
AS
	begin try
		if(dbo.func_GetUserStaffStore(@userId,@storeId) <> 11)
		begin
			set @rCode = 0
			set @rMsg = 'این عملیات برای شما مجاز نیست'
			return
		end
		delete from TB_DOCUMENT_STORE_CERTIFICATE where pk_fk_store_certificate_id = @id
		delete from TB_STORE_CERTIFICATE where id = @id
		if(@@ROWCOUNT > 0)
		begin
			set @rMsg = 'success'
		end
		else
		begin
			set @rMsg = 'هیچ گواهی ای با این شناسه موجود نمی باشد'
		end
		set @rCode = 1
	end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@PROCID),@clientLanguage, ERROR_MESSAGE())
	end catch
RETURN 0
