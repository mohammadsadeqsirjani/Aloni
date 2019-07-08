create view [dbo].[vw_itemGrp_fullPath]
AS
select id , ISNULL(title , 'فاقد عنوان') as title , fk_item_grp_ref , dbo.func_getFullItemGrpDscPath(id , 1) as FullPath, [type] from dbo.TB_TYP_ITEM_GRP