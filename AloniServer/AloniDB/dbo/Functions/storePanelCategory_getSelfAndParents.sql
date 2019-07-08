CREATE FUNCTION [dbo].[storePanelCategory_getSelfAndParents]
(
	@storeId bigint
)
RETURNS @returntable TABLE
(
	itemGrpId bigint
)
AS
BEGIN

	;with name_tree
	as 
	(
	  select id, fk_item_grp_ref
	  from TB_TYP_ITEM_GRP as g
	  --where id = 21532
	  join TB_STORE_ITEMGRP_PANEL_CATEGORY as p with(nolock)
	   on g.id = p.pk_fk_itemGrp_id and p.pk_fk_store_id = @storeId
	  union all
	  select C.id, C.fk_item_grp_ref
	  from TB_TYP_ITEM_GRP c with(nolock)
	  join name_tree p on C.id = P.fk_item_grp_ref  
	) 






	INSERT @returntable
		select id from name_tree
	RETURN
END
