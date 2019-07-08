CREATE FUNCTION [dbo].[func_isUserJoinedToStoreCustomers]
(
	@storeId as bigint,
	@userId as bigint
)
RETURNS bit
AS
BEGIN
declare @o as bit;
set @o = 0;
	select @o =  1
	from TB_STORE_CUSTOMER with(nolock)
	where pk_fk_store_id = @storeId and pk_fk_usr_cstmrId = @userId and fk_status_id = 32;
	return @o;
END
