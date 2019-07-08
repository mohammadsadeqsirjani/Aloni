CREATE TYPE [dbo].[ScheduleType] AS TABLE (
    [storeId] BigINT NULL,
	[onDayOfWeek] tinyint NULL,
	[isActiveFrom] time(7) NULL,
	[activeUntil] time(7) NULL);
