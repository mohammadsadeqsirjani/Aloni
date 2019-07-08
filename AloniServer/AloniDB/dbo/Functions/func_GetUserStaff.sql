CREATE FUNCTION [dbo].[func_GetUserStaff]
(
	@userId as bigint,
	@storeId as bigint,
	@appId as tinyint
)
RETURNS smallint
AS
BEGIN
	RETURN case when @appId = 2 then 21 when @appId = 1 then (select fk_staff_id 
	from TB_USR_STAFF
	where fk_usr_id = @userId and  fk_store_id = @storeId
	and fk_status_id = 8)
	when @appId = 3 then 
	(select fk_staff_id 
	from TB_USR_STAFF
	where fk_usr_id = @userId and fk_store_id is null
	and fk_status_id = 37 --TODO: جرا برای سمت های پرتال از این کد وضعیت استفاده شده است؟! بایستی با کد وضعیت های اپ یکسان باشد
	)
	end
END
