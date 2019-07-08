CREATE PROCEDURE [dbo].[SP_setStoreAccount]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@validationCode as char(5),
	@id as bigint,
	@sessionId as bigint
AS
	declare @account as varchar(50)
	declare @bankId as int
	declare @storeId as bigint

	if((select fk_usr_id from TB_USR_SESSION where id = (select fk_usr_session_id from TB_STORE_TEMPACCOUNTDATA where id = @id)) <> @userId or (select fk_usr_session_id from TB_STORE_TEMPACCOUNTDATA where id = @id) <> @sessionId)
	begin
		set @rCode = 0 
		set @rMsg = dbo.func_getSysMsg('invalid request',OBJECT_NAME(@@PROCID),@clientLanguage,'access denied!')
		return
	end
	if((select validationCode from TB_STORE_TEMPACCOUNTDATA where id = @id) <> @validationCode)
	begin
		set @rCode = 0 
		set @rMsg = dbo.func_getSysMsg('invalid code',OBJECT_NAME(@@PROCID),@clientLanguage,'Validation code is not valid!')
		return
	end
	select @account = account , @bankId = fk_bank_id , @storeId = fk_store_id from TB_STORE_TEMPACCOUNTDATA where id = @id
	update TB_STORE_TEMPACCOUNTDATA set validationDateTime = GETDATE() where id = @id
	update TB_STORE set account = @account, fk_bank_id = @bankId , fk_OnlinePayment_StatusId = 12 , GetwayPaymentValidationCode = @validationCode where id = @storeId
	set @rCode = 1
	set @rMsg = 'success'
	return


RETURN 0
