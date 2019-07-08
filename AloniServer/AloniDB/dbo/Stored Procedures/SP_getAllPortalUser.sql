-- =============================================
-- Author:		Saeed Khorsand
-- Create date: 13960829
-- Description:	GetAllPortalUser Support [Paging,Search ]
-- =============================================
CREATE PROCEDURE dbo.SP_getAllPortalUser 
	@page int,
	@search varchar(100)
AS
BEGIN
	SET NOCOUNT ON;

	select * from ( 
	select distinct USR.id,USR.fname , USR.lname , USR.fname + USR.lname as fullName , C.title as country , L.id as language FROM TB_USR USR
	left join TB_USR_STAFF USTF
	on USR.id = USTF.fk_usr_id and USTF.fk_staff_id in ( 31 , 32 , 33 )
	left join TB_COUNTRY C
	on USR.fk_country_id = C.id
	left join TB_LANGUAGE L
	on USR.fk_language_id = L.id ) as USR
	where (@search is null or @search = '' or fullName like '%'+@search+'%' )
	ORDER BY USR.Id
	OFFSET (@page * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;

END