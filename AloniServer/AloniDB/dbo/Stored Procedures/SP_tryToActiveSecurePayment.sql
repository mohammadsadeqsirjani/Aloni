CREATE PROCEDURE [dbo].[SP_tryToActiveSecurePayment]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@sessionId as bigint,
	@id as bigint out
AS
	declare @countryId as int 
	declare @mobile as varchar(20)
	declare @SP_sendSMS_rCode as tinyint
	declare @SP_sendSMS_rMsg as varchar(max)
	select @mobile = mobile , @countryId = fk_country_id from TB_USR where id = (select fk_usr_id from TB_USR_STAFF where fk_store_id = @storeId and fk_staff_id = 11)
	declare @validationCode as char(5) = dbo.func_RandomString(5,1)
	declare @objName as varchar(60) = OBJECT_NAME(@@procID)
	exec [dbo].[SP_sendSMS]	 
	 @userId = @userId,
	 @countryId = @countryId,
	 @mobile = @mobile,
	 @SYSTEMMESSAGE_msgKey = 'sms_validationSecurePayment',
	 @SYSTEMMESSAGE_objectName = @objName,
	 @SYSTEMMESSAGE_lan = @clientLanguage,
	 @arg1 = @validationCode,
	 @rCode = @SP_sendSMS_rCode OUTPUT,
	 @rMsg = @SP_sendSMS_rMsg OUTPUT
	 if(@SP_sendSMS_rCode = 1)
	 begin
		set @rCode = 1
		insert into TB_STORE_TEMPACCOUNTDATA(fk_usr_session_id,fk_store_id,saveDateTime,validationCode,account) 
					values(@sessionId,@storeId,GETDATE(),@validationCode,'for secure payment')
		set @id = SCOPE_IDENTITY()
		set @rMsg = 'success'
		return
	 end
	 else
	 begin
		set @rCode = 0
		set @rMsg = 'faild to send sms'
		return
	 end 
RETURN 0