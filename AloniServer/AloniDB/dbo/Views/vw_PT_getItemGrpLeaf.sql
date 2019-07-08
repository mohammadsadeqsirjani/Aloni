CREATE VIEW [dbo].[vw_PT_getItemGrpLeaf]
	AS SELECT t.id,
              t.fk_item_grp_ref,
              fullPath.FullPath AS title,
			  t.title AS stitle,
			  t.type AS [type]
     FROM   TB_TYP_ITEM_GRP t inner join 
	 vw_itemGrp_fullPath AS fullPath ON t.id = fullPath.id 
     WHERE  NOT EXISTS (SELECT 1
       FROM   TB_TYP_ITEM_GRP
       WHERE  fk_item_grp_ref = t.id) 
