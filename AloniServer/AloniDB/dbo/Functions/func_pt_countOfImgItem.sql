CREATE FUNCTION [dbo].[func_pt_countOfImgItem]
(

)
RETURNS @returntable TABLE
(
	fk_item_id bigint,
	countOfImg bigint
)
AS
BEGIN
	INSERT @returntable
	select di.pk_fk_item_id AS fk_item_id,COUNT(*) AS countOfImg from
	 TB_DOCUMENT_ITEM as di
	 join TB_DOCUMENT as d
	 on di.pk_fk_document_id = d.id
	 group by di.pk_fk_item_id
	RETURN
END
