CREATE FUNCTION [dbo].[func_stringFormat_2]
(
	@srcString as nvarchar(max),
	@arg1 as nvarchar(max) = '',
	@arg2 as nvarchar(max) = ''
)
RETURNS varchar(max)
AS
BEGIN
	RETURN  (REPLACE(REPLACE(@srcString,'{0}',@arg1),'{1}',@arg2));
END