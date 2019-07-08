CREATE PROCEDURE [dbo].[SP_changeNotificationStore]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint
AS
	update TB_STORE_CUSTOMER set notification = case when notification = 1 then 0 else 1 end where pk_fk_store_id = @storeId and pk_fk_usr_cstmrId = @userId
	set @rCode = 1
	set @rMsg = 'success'
RETURN 0
