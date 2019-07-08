create FUNCTION [dbo].[func_calcDistance]
(
	@clientLanguage char(2),
	@geo1 as geography,
	@geo2 as geography
)
RETURNS nvarchar(50)
AS
BEGIN
	declare @distance as float = @geo1.STDistance(@geo2)
	declare @result as nvarchar(50)
	set @result =-- cast(round((@distance / 1000),2) as nvarchar(50)) +
	 dbo.func_getDistanceUnitByLanguage(@clientLanguage,@distance)
	return @result
END


