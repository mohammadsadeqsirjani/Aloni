CREATE FUNCTION [dbo].[func_addThousandsSeperator]
(
	@val money
)
RETURNS varchar(max)
AS
BEGIN
	set @val = ISNULL(@val,0)
	RETURN replace(convert(varchar,@val,1),'.00','')
END
