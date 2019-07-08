
-- =============================================
-- Author:		Saeed Khorsand
-- Create date: 13960829
-- Description:	GetAllPortalUser Support [Paging,Search ]
-- =============================================
CREATE PROCEDURE [dbo].[SP_getAllCounty] 
	@page int,
	@search varchar(100)
AS
BEGIN
	SET NOCOUNT ON;

	select id,title from TB_COUNTRY
	where  (@search is null or @search = '' or title like '%'+@search+'%' )
	ORDER BY Id
	OFFSET (@page * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;

END