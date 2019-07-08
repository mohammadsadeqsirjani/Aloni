-- =============================================
-- Author:		Saeed Khorsand
-- Create date: 13960829
-- Description:	SP_getAllPartGrpByLevel Support [Paging,Search,Level]
-- =============================================
CREATE PROCEDURE dbo.SP_getAllPartGrpByLevel
	@page int,
	@level int,
	@search varchar(100)
AS
BEGIN
	SET NOCOUNT ON;

	select id,title,0 as level from TB_TYP_ITEM_GRP
	where (@search is null or @search = '' or title like '%'+@search+'%' )
	ORDER BY Id


END