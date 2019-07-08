CREATE PROCEDURE [dbo].[SP_itemEvaluationUpdateStatus]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@statusId as int,
	@evaluationId as bigint
AS
	declare @staff smallint = (dbo.func_GetUserStaffStore(@userId,@storeId))
	if(@staff is null or @staff = 0)
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,'شما مجاز به انجام این عملیات نیستید')
		return
	end
	if(not exists(select top 1 1 from TB_STORE_ITEM_EVALUATION where id = @evaluationId and fk_store_id = @storeId))
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,'آیتم مورد نظر در پنل شما فاقد نظرسنجی با مشخصات وارد شده می باشد')
		return
	end
	if(@statusId not in(106,107,108))
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,'وضعیت درخواست شده معتبر نمی باشد')
		return
	end
	begin try
		update
			TB_STORE_ITEM_EVALUATION 
		set 
			fk_status_id = @statusId,
			fk_confirmUsr_id = @userId,
			confirmDate = GETDATE()
		where
			id = @evaluationId
		set @rCode = 1
		set @rMsg = 'success'
		
	end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,ERROR_MESSAGE())
	end catch
RETURN 0

