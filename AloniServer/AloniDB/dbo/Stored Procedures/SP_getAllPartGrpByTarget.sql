-- =============================================
-- Author:		Saeed Khorsand
-- Create date: 13960829
-- Description:	SP_getAllPartGrpByLevel Support [Paging,Search,Level]
-- =============================================
CREATE PROCEDURE [dbo].[SP_getAllPartGrpByTarget]
	@page int,
	@target int,
	@search varchar(100)
AS
BEGIN
	SET NOCOUNT ON;

	select tbl.id
	,tbl.title
	,tbl.parent
	,case
		when childCount <> '0'
		then childCount
		else 'ندارد'
	end as childCount
	,tbl.page_title
	,CASE WHEN  tbl.itemGrpTyp = 1 THEN 'کالا' WHEN tbl.itemGrpTyp = 2 THEN 'پرسنل' WHEN tbl.itemGrpTyp = 3 THEN 'مشاغل' WHEN tbl.itemGrpTyp = 4 THEN 'اشیاء' WHEN tbl.itemGrpTyp = 5 THEN 'سازمان' WHEN tbl.itemGrpTyp = 6 THEN 'شعب' ELSE '' END AS itemGrpType
	 from ( select GRP.id,GRP.title,GRP_PARENT.title as parent , GRP.type AS itemGrpTyp , (select cast(count(*) as varchar(20)) as cnt from TB_TYP_ITEM_GRP C_GRP where C_GRP.fk_item_grp_ref = GRP.id ) as childCount ,
	P.title page_title
	from TB_TYP_ITEM_GRP GRP
	left join TB_TYP_ITEM_GRP GRP_PARENT 
	on GRP.fk_item_grp_ref = GRP_PARENT.id
	left join TB_TECHNICALINFO_PAGE P
	on GRP.fk_technicalinfo_page_id = P.Id
	where (@target = 0 or GRP.fk_item_grp_ref = @target ) AND  (@search is null or @search = '' or GRP.title like '%'+@search+'%' ) ) as tbl
	where (@target <> 0 or parent is null)
	ORDER BY Id


END