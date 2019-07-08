CREATE FUNCTION [dbo].[func_pt_getCountOfImageItem]
(
	@itemId as bigint
)
RETURNS int
AS
BEGIN
	declare @CountImage AS int;
	set @CountImage = 0;
	set @CountImage = (select COUNT(*) from
	 TB_DOCUMENT_ITEM as di
	 join TB_DOCUMENT as d
	 on di.pk_fk_document_id = d.id
	 where di.pk_fk_item_id = @itemId);
	 return @CountImage
END