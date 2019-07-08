
CREATE FUNCTION [dbo].[func_udf_Gregorian_To_Persian_withTime]
(@date datetime)
Returns varchar(20)
as
Begin
 return [dbo].[func_udf_Gregorian_To_Persian](@date) + ' ' + CONVERT(varchar(5), @date, 108)
End