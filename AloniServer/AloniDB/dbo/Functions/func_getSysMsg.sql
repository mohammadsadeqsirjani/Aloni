CREATE FUNCTION [dbo].[func_getSysMsg]
(
	@msgKey as varchar(50),
	@objectName as varchar(60),
	@lan as char(2),
	@defaultBody as nvarchar(1000) = ''
)
RETURNS nvarchar(max)
AS
BEGIN
	select @defaultBody = body
	from TB_SYSTEMMESSAGE with(nolock) 
	where msgKey = @msgKey and objectName = @objectName and lan = @lan
	return @defaultBody
END
