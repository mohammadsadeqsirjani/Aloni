
-- =============================================
-- Author:		Saeed Khorsand
-- Create date: 13960830
-- Description:	get All Unit Support [Paging,Search ]
-- =============================================
CREATE PROCEDURE [dbo].[SP_getAllUnit] 
	@page int,
	@search varchar(100)
AS
BEGIN
	SET NOCOUNT ON;
	
	select U.id , U.title , U.isActive from TB_TYP_UNIT U
	where (@search is null or @search = '' or ISNULL(U.title, '') like '%'+@search+'%' )
	ORDER BY U.id
	OFFSET (@page * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;

END