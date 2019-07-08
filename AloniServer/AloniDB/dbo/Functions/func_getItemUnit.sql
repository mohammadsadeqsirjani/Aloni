CREATE FUNCTION [dbo].[func_getItemUnit]
(
	@clientLanguage as char(2),
	@itemId as bigint
)
RETURNS varchar(max)
AS
BEGIN
	declare @result varchar(max)
	select
		@result = ISNULL(UY.title,U.title)
	from
		 TB_ITEM I
		 inner join  TB_TYP_UNIT U on i.fk_unit_id = u.id
		 left join TB_TYP_UNIT_TRANSLATIONS UY on U.id = UY.id and UY.lan = @clientLanguage
	where 
	i.id = @itemId

	return @result
END
