CREATE FUNCTION [dbo].[func_getUserDesc]
(
	@id as bigint
)
RETURNS nvarchar(max)
AS
BEGIN
	declare @desc as varchar(100)

	select @desc  = ISNULL(U.fname , '' ) + ISNULL(U.lname , '') from TB_USR U
	where U.id = @id 

	return @desc
END