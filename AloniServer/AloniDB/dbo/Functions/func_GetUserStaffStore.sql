CREATE FUNCTION [dbo].[func_GetUserStaffStore]
(
	@userId as bigint,
	@storeId as bigint
)
RETURNS smallint
AS
BEGIN
	RETURN (select fk_staff_id 
	from TB_USR_STAFF
	where fk_usr_id = @userId and fk_store_id = @storeId
	and fk_status_id = 8)
END
