CREATE FUNCTION [dbo].[func_checkToken]
(
	@privateToken as varchar(150),
	@publicToken as varchar(150)
)
RETURNS INT
AS
BEGIN
return 1;
END