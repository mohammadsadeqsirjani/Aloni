CREATE FUNCTION [dbo].[func_pt_getItemsByBarcode]
(
	@barcode AS varchar(150)
)
RETURNS TABLE 
AS
RETURN 
(
	select 
	I.id AS id
	,CAST(I.id AS varchar(50)) + ' - ' +  I.title AS title
	,I.fk_itemGrp_id
	,IG.title AS  fk_itemGrp_Dsc
	,ISNULL(I.barcode, '') AS barcode
	,ISNULL(SIQ.localBarcode, '') AS localBarcode
	,ISNULL(SIQ.uniqueBarcode, '') AS uniqueBarcode
	,SIQ.pk_fk_store_id AS storeId
	,S.title AS storeTitle
	,I.fk_status_id
	,ST.title AS fk_status_Dsc 
	 from TB_ITEM AS I
	LEFT JOIN TB_TYP_ITEM_GRP AS IG ON I.fk_itemGrp_id = IG.id
	LEFT JOIN TB_STATUS AS ST ON I.fk_status_id = ST.id
	LEFT JOIN TB_STORE_ITEM_QTY AS SIQ ON I.id = SIQ.pk_fk_item_id
	LEFT JOIN TB_STORE AS S ON SIQ.pk_fk_store_id = S.id
	where I.itemType = 1 AND @barcode IS NULL OR I.barcode = @barcode OR SIQ.localBarcode = @barcode OR I.uniqueBarcode = @barcode
)
