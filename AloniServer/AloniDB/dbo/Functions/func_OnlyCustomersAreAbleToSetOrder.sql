CREATE FUNCTION [dbo].[func_OnlyCustomersAreAbleToSetOrder]
(
	@storeId as bigint
	--و@cstmrId as bigint = null
)
RETURNS bit
AS
BEGIN
	declare @o as bit;
	select @o = OnlyCustomersAreAbleToSetOrder from TB_STORE with(nolock)
	where id= @storeId;
	--if(@o = 1 and @cstmrId is not null)
	--begin
	--select @o =  1
	--from TB_STORE_CUSTOMER with(nolock)
	--where pk_fk_store_id = @storeId and pk_fk_usr_cstmrId = @cstmrId and fk_status_id = 32;
	--end

	return @o;
END