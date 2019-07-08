CREATE FUNCTION [dbo].[func_subGrpItemByGrpItemId]
(
	@itemGrpId as bigint
)
RETURNS TABLE 
AS
RETURN 
(

with GrpItemHierarchy as
(
  select Id
  from TB_TYP_ITEM_GRP
  where Id = @itemGrpId or @itemGrpId = 0
  union all
  select c.Id
  from TB_TYP_ITEM_GRP c
    inner join GrpItemHierarchy ch on c.fk_item_grp_ref = ch.Id
)
select distinct id from GrpItemHierarchy
  
)
