CREATE FUNCTION [dbo].[func_calcActionOrderTime]
(
	@clientLanguage char(2),
	@actionDatetime datetime
)
RETURNS nvarchar(50)
AS
BEGIN
	
	declare @result as nvarchar(50)
	declare @diffDateBaseMinute as int = (select datediff(MI, @actionDatetime , GETDATE()))
	if(@diffDateBaseMinute = 0)
	begin
		set @result = case
						   when @clientLanguage = 'fa' then ' لحظاتی قبل '
						   when @clientLanguage = 'en' then ' Moments ago '
						   when @clientLanguage = 'ar' then ' قبل لحظات '
						   when @clientLanguage = 'tr' then ' Birkaç dakika önce '
					  end
	end
	else if(@diffDateBaseMinute < 1440)
	begin
		if(@diffDateBaseMinute < 60)
		begin
					set @result = case 
						   when @clientLanguage = 'fa' then CAST(@diffDateBaseMinute as varchar(10)) + ' دقیقه قبل '
						   when @clientLanguage = 'en' then CAST(@diffDateBaseMinute as varchar(10)) + ' minute ago '
						   when @clientLanguage = 'ar' then CAST(@diffDateBaseMinute as varchar(10)) + ' قبل دقیقه '
						   when @clientLanguage = 'tr' then CAST(@diffDateBaseMinute as varchar(10)) + ' dakika önce '
					  end
		end
		else
		begin
					set @result = case 
						   when @clientLanguage = 'fa' then CAST(@diffDateBaseMinute / 60 as varchar(10)) + ' ساعت قبل '
						   when @clientLanguage = 'en' then CAST(@diffDateBaseMinute / 60 as varchar(10)) + ' hour ago '
						   when @clientLanguage = 'ar' then CAST(@diffDateBaseMinute / 60 as varchar(10)) + ' قبل ساعته '
						   when @clientLanguage = 'tr' then CAST(@diffDateBaseMinute / 60 as varchar(10)) + ' saat önce '
					  end
		end
	end
	else if(@diffDateBaseMinute < 2880)
	begin
		set @result = case 
						   when @clientLanguage = 'fa' then ' دیروز '
						   when @clientLanguage = 'en' then 'yesterday '
						   when @clientLanguage = 'ar' then ' أمس '
						   when @clientLanguage = 'tr' then ' dün '
					  end
	end
	else
	begin
		set @result = (select dbo.func_getDateByLanguage(@clientLanguage,@actionDatetime,0) + ' ساعت ' + CAST(CAST(@actionDatetime as time) as varchar(5)))
	end
	return @result

END



