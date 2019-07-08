CREATE FUNCTION [dbo].[func_getDistanceUnitByLanguage]
(
	@clientLanguage char(2),
	@distance as int
)
RETURNS nvarchar(50)
AS
BEGIN
	declare @result nvarchar(50)
	
	if(@distance < 1000)
	begin
		if(@clientLanguage = 'fa' or @clientLanguage = 'ar')
		begin
			set @result =case when (@distance % 100 = 0) then CAST(cast(@distance as decimal(10,0)) as varchar(20)) + ' متر ' else CAST(cast(@distance as decimal(10,1)) as varchar(20)) + ' متر ' END
		end
		else if(@clientLanguage = 'en')
		begin
			set @result =case when (@distance % 100 = 0) then CAST(cast(@distance as decimal(10,0)) as varchar(20)) +  ' M ' else CAST(cast(@distance as decimal(10,1)) as varchar(20)) +  ' M ' END
		end
	end
	else
	begin
		if(@clientLanguage = 'fa' or @clientLanguage = 'ar')
		begin
			set @result =case when (@distance % 100 = 0) then CAST(cast((@distance / 1000) as decimal(10,0)) as varchar(20)) +' کیلومتر ' else CAST(cast((@distance / 1000) as decimal(10,1)) as varchar(20)) +' کیلومتر ' END
		end
		else if(@clientLanguage = 'en')
		begin
			set @result =case when (@distance % 100 = 0) then CAST(cast((@distance / 1000) as decimal(10,0)) as varchar(20)) + ' Km ' else CAST(cast((@distance / 1000) as decimal(10,1)) as varchar(20)) + ' Km ' END
		end
	end
	return @result
	
END
