CREATE PROCEDURE [dbo].[SP_changeShowStoreActivityStatus]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint
AS
	update TB_STORE_CUSTOMER set notification = case when notification = 1 then 0 else 1 end where pk_fk_store_id = @storeId and pk_fk_usr_cstmrId = @userId
	if(@@rowcount > 0)
	begin
	set @rcode = 1
	set @rMsg = 'success'
	end
RETURN 0
