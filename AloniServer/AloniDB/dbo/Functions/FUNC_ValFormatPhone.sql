CREATE FUNCTION [dbo].[FUNC_ValFormatPhone] (@phone NVARCHAR(255))
RETURNS bit
AS
BEGIN
declare @i int, @repCount int
declare @current_char char(1)
declare @phone_new varchar(50)
declare @result as bit = 0
set @phone_new = rtrim(ltrim(@phone))

if left(@phone_new, 1) = '1'
set @phone_new = right(@phone_new, len(@phone_new) -1)


set @i = 1
while @i <= len(@phone)
begin
set @repCount = 0
if @i > len(@phone_new)
break

set @current_char = substring(@phone_new, @i, 1)

if isnumeric(@current_char) <> 1
begin
set @repCount = len(@phone_new) - len(replace(@phone_new, @current_char, ''))
set @phone_new = replace(@phone_new, @current_char, '')
end

set @i = @i + 1 - @repCount
end

if isnumeric(@phone_new) = 1 and len(@phone_new) = 10 
set @result = 1

return @result
END