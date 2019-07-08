CREATE FUNCTION [dbo].[func_pt_itemOfficial_all_count]
(	
	@storeId as bigint
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT DISTINCT 
                         I.id
    FROM                 dbo.TB_ITEM AS I with(nolock) INNER JOIN
                         dbo.TB_TYP_ITEM_GRP AS IG with(nolock) ON I.fk_itemGrp_id = IG.id LEFT OUTER JOIN
                         dbo.TB_DOCUMENT_ITEM AS di with(nolock) ON I.id = di.pk_fk_item_id AND di.isDefault = 1 LEFT OUTER JOIN
                         dbo.TB_DOCUMENT AS d with(nolock) ON di.pk_fk_document_id = d.id LEFT OUTER JOIN
                         dbo.TB_USR AS U with(nolock) ON I.fk_usr_saveUser = U.id LEFT OUTER JOIN
                         dbo.TB_USR AS U2 with(nolock) ON I.fk_modify_usr_id = U2.id LEFT OUTER JOIN
                         dbo.TB_STATUS AS S with(nolock) ON I.fk_status_id = S.id LEFT OUTER JOIN
						 dbo.TB_STATUS_TRANSLATIONS AS ST with(nolock) ON S.id = ST.id AND ST.lan = 'fa' LEFT OUTER JOIN
						 dbo.func_pt_countOfImgItem() As imgCount ON I.id = imgCount.fk_item_id LEFT OUTER JOIN
						 dbo.TB_STORE_ITEM_QTY AS IQ with(nolock) ON IQ.pk_fk_item_id = I.id
						 where (I.displayMode IS NULL OR I.displayMode = 0) AND (IQ.pk_fk_store_id = @storeId OR @storeId is Null) AND I.itemType = 1
)
