
CREATE FUNCTION [dbo].[func_getCityById]
(	
	@id as int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT CT.id , CT.title , CT.fk_country_id , CO.title as cTitle FROM TB_CITY CT
	left join TB_COUNTRY CO
	on  CT.fk_country_id = CO.id
	where CT.id  = @id and CT.isActive <> 0
)