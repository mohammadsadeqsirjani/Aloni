CREATE FUNCTION [dbo].[func_getDateByLanguage]
(
	@language char(2),
	@dateTime datetime,
	@includeTime bit = 0
)
RETURNS varchar(max)
AS
BEGIN
	declare @result varchar(max)
	if(@language = 'fa')
	begin
		set @result = (select [dbo].[func_udf_Gregorian_To_Persian](@dateTime))
	end
	else if(@language = 'en')
	begin
		set @result = (SELECT CONVERT(date, @dateTime))
	end
	else if(@language = 'ar')
	begin
		set @result = (CONVERT(VARCHAR(max),@DateTime,131))
	end
	set @result  = case when @includeTime = 1 then @result + ' ' + CONVERT(varchar(5), @dateTime, 108) else @result end
	return @result; 
END
