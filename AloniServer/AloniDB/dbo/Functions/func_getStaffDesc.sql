CREATE FUNCTION [dbo].[func_getStaffDesc]
(
	@id as smallint ,
	@lan as varchar(10) = 'fa'
)
RETURNS nvarchar(max)
AS
BEGIN
	declare @desc as varchar(100)

	select @desc  = title from TB_STAFF_TRANSLATIONS ST
	where ST.id = @id and lan = @lan

	return @desc
END