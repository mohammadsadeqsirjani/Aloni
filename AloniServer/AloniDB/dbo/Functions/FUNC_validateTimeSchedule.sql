
-- =============================================
-- Author:		Abolfazl Kabiri
-- Create date: 2019/01/13
-- Description:	Validate Time Schedule
-- =============================================
CREATE FUNCTION FUNC_validateTimeSchedule
(
	@timeList as [dbo].[ScheduleType] readonly
)
RETURNS bit
AS
BEGIN
	
	declare @result as bit = 1
	declare @onDayOfWeek as tinyint
	declare @isActiveFrom as time(7)
	declare @activeUntil as time(7)
	declare @onDayOfWeek_old as tinyint = null
	declare @isActiveFrom_old as time(7) = null
	declare @activeUntil_old as time(7) = null
	declare @i as int= 0;
	declare cr cursor for
		select onDayOfWeek,isActiveFrom,activeUntil from @timeList order by onDayOfWeek,isActiveFrom,activeUntil
	open cr
	fetch next from cr into @onDayOfWeek,@isActiveFrom,@activeUntil
	while @@FETCH_STATUS = 0
	begin
		if(@onDayOfWeek_old is null and @activeUntil_old is null and @isActiveFrom_old is null and @i = 0)
		begin
			set @onDayOfWeek_old = @onDayOfWeek
			set @isActiveFrom_old = @isActiveFrom
			set @activeUntil_old = @activeUntil
		end
		else
		begin
			if(@onDayOfWeek = @onDayOfWeek_old and (@isActiveFrom <= @activeUntil_old or @isActiveFrom >= @activeUntil or @isActiveFrom_old >= @activeUntil_old))
			begin
				set @result = 0
				break
			end
		end
		set @i+=1
	fetch next from cr into @onDayOfWeek,@isActiveFrom,@activeUntil
	end
	close cr 
	deallocate cr
	return @result
END