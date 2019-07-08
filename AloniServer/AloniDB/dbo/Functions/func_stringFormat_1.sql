CREATE FUNCTION [dbo].[func_stringFormat_1]
(
	@srcString as nvarchar(max),
	@arg1 as nvarchar(max) = ''
)
RETURNS varchar(max)
AS
BEGIN
	RETURN  REPLACE(@srcString,'{0}',@arg1);
END
