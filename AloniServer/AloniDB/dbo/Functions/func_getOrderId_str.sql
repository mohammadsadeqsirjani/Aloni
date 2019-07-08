CREATE FUNCTION [dbo].[func_getOrderId_str]
(
	@userId as bigint
)
RETURNS varchar(36)
AS
BEGIN
	declare @result as varchar(36);
	set @result = cast((888 + @userId) as varchar(10)) + CAST((DATEDIFF(SECOND,{d '1970-01-01'}, GETDATE())) as varchar(36))
	return @result
END
