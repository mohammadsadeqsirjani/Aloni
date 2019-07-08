CREATE FUNCTION [dbo].[func_pt_itemOfficial_ref_Count]
(
	@statusId AS int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT DISTINCT 
                         I.id
FROM            dbo.TB_ITEM AS I INNER JOIN
                         dbo.TB_TYP_ITEM_GRP AS IG ON I.fk_itemGrp_id = IG.id LEFT OUTER JOIN
                         dbo.TB_DOCUMENT_ITEM AS di ON I.id = di.pk_fk_item_id AND di.isDefault = 1 LEFT OUTER JOIN
                         dbo.TB_DOCUMENT AS d ON di.pk_fk_document_id = d.id LEFT OUTER JOIN
                         dbo.TB_USR AS U ON I.fk_usr_saveUser = U.id LEFT OUTER JOIN
                         dbo.TB_USR AS U2 ON I.fk_modify_usr_id = U2.id LEFT OUTER JOIN
                         dbo.TB_STATUS AS S ON I.fk_status_id = S.id LEFT OUTER JOIN
                         dbo.TB_STATUS_TRANSLATIONS AS ST ON S.id = ST.id AND ST.lan = 'fa' LEFT OUTER JOIN
						 dbo.func_pt_countOfImgItem() As imgCount ON I.id = imgCount.fk_item_id
WHERE                    (I.isTemplate = 1) AND (I.displayMode IS NULL OR I.displayMode = 0) AND (S.id = @statusId OR @statusId IS NULL)  AND I.itemType = 1
)
