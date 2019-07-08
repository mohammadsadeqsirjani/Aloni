CREATE FUNCTION [dbo].[func_getStoreDefaultImage]
(
	 @documentType as smallint
)
RETURNS @returntable TABLE
(
     storeId bigint
	,imageId varchar(36)
	,imageUrl varchar(255)
	,image_thumbUrl varchar(255)
)
AS
BEGIN
	INSERT @returntable
	SELECT  ds.pk_fk_store_id, ds.pk_fk_document_id,d.completeLink,d.thumbcompeleteLink
	  from  TB_DOCUMENT_STORE AS ds JOIN TB_DOCUMENT AS d ON ds.pk_fk_document_id = d.id
	 where ds.isDefault = 1 and d.fk_documentType_id = @documentType 
	RETURN
END
