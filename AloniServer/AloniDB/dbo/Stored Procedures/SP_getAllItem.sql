
-- =============================================
-- Author:		Saeed Khorsand
-- Create date: 13960830
-- Description:	get All Item Support [Paging,Search ]
-- =============================================
CREATE PROCEDURE [dbo].[SP_getAllItem] 
	@page int,
	@search varchar(100)
AS
BEGIN
	SET NOCOUNT ON;
	
	select I.id , I.title,I.technicalTitle , G.title as gTitle from TB_ITEM I with(nolock)
	left join TB_TYP_ITEM_GRP G with(nolock)
	on I.fk_itemGrp_id = G.id
	where (@search is null or @search = '' or (ISNULL(I.title, '')+' '+ ISNULL(I.technicalTitle,'') + '' + ISNULL(G.title,'') ) like '%'+@search+'%' )
	ORDER BY G.id
	OFFSET (@page * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;

END