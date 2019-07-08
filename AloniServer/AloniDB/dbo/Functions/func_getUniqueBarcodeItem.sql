CREATE FUNCTION [dbo].[func_getUniqueBarcodeItem]
(
	@itemId as bigint
)
RETURNS nvarchar(50)
AS
BEGIN
	declare @result as nvarchar(50) = '864'
	declare @itemIdStr as nvarchar(50) = cast( @itemId as nvarchar(50))
	declare @subtractLen as int = 10 - len(@itemIdStr)

	declare @i as int = 1;
	while(@i <= @subtractLen)
	begin
		set @result +='0'
		set @i+=1
	end
	set @result +=@itemIdStr
	return @result
END
