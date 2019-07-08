
CREATE FUNCTION func_getActiveStoreTimeDay
(
	@clientLanguage as char(2),
	@storeId as bigint
)
RETURNS nvarchar(50)
AS
BEGIN
	
	declare @result as nvarchar(50)
	declare @dayOfweek as int = (SELECT DATEPART(dw,GETDATE()))
	declare @from as time(7)
	declare @to as time(7)
	if((select fk_status_id from TB_STORE where id = @storeId) = 19)
	begin
		if(exists(select id from TB_STORE_SCHEDULE where fk_store_id = @storeId and onDayOfWeek = @dayOfweek))
		begin
			select @from = isActiveFrom,@to = activeUntil from TB_STORE_SCHEDULE where fk_store_id = @storeId and onDayOfWeek = @dayOfweek
		end
		
	end
	else
	begin
		select @from = shiftStartTime, @to = shiftEndTime  from TB_STORE where id = @storeId
	end
	if(@from is null and @to is null)
	begin
		set @result = case when @clientLanguage = 'fa' then 'نامشخص'
							   when @clientLanguage = 'ar' then 'غير معروف'
							   when @clientLanguage = 'tr' then 'bilinmeyen'
							   else
							   'Unknown' end
	end
	else
	begin
		set @result = case when @clientLanguage = 'fa' then CAST(@from as nvarchar(7)) + ' الی ' + CAST(@to as nvarchar(7))
							   when @clientLanguage = 'ar' then CAST(@from as nvarchar(7)) + ' إلى ' + CAST(@to as nvarchar(7))
							   when @clientLanguage = 'tr' then CAST(@from as nvarchar(7)) + ' - ' + CAST(@to as nvarchar(7))
							   else
							   CAST(@from as nvarchar(7)) + ' to ' + CAST(@to as nvarchar(7)) end
	end
	return @result

END
GO

