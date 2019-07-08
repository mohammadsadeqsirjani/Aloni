CREATE PROCEDURE [dbo].[SP_leftCustomerFromStore]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint
	
AS
	if(@appId <> 2) 
	return
		update TB_STORE_CUSTOMER
		set		fk_status_id = 33
		where pk_fk_store_id = @storeId and pk_fk_usr_cstmrId = @userId
		if(@@ROWCOUNT > 0)
		begin
			set @rCode = 1
			set @rMsg = 'success'
		end
	
RETURN 0
