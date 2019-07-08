CREATE FUNCTION [dbo].[func_getItemDefaultImage]
(
     @documentType as smallint
)
RETURNS @returntable TABLE
(
     itemId bigint
	,imageId varchar(36)
	,imageUrl varchar(255)
	,image_thumbUrl varchar(255)
)
AS
BEGIN
	INSERT @returntable
	SELECT  di.pk_fk_item_id, di.pk_fk_document_id,d.completeLink,d.thumbcompeleteLink
	  from  TB_DOCUMENT_ITEM AS di JOIN TB_DOCUMENT AS d ON di.pk_fk_document_id = d.id
	 where di.isDefault = 1 and d.fk_documentType_id = @documentType;
	RETURN
END
