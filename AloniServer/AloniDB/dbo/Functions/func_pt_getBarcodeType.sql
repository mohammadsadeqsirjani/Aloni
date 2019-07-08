CREATE FUNCTION [dbo].[func_pt_getBarcodeType]
(
	@barcode AS varchar(150)
)
RETURNS varchar(50)
AS
BEGIN
    declare @result AS varchar(50);
	select @result = 'بارکد' from TB_ITEM AS I
    left join TB_STORE_ITEM_QTY AS SIQ ON I.id = SIQ.pk_fk_item_id
    where I.itemType = 1 AND I.barcode = @barcode
	select @result = 'بارکد محلی' from TB_ITEM AS I
	left join TB_STORE_ITEM_QTY AS SIQ ON I.id = SIQ.pk_fk_item_id
	where I.itemType = 1 AND  SIQ.localBarcode = @barcode 
	select @result = 'بارکد یکتا' from TB_ITEM AS I
	left join TB_STORE_ITEM_QTY AS SIQ ON I.id = SIQ.pk_fk_item_id
	where I.itemType = 1 AND I.uniqueBarcode = @barcode
	--select @result = 'بارکد و بارکد محلی' ,@flag = 1 from TB_ITEM AS I
	--left join TB_STORE_ITEM_QTY AS SIQ ON I.id = SIQ.pk_fk_item_id
	--where I.itemType = 1 AND @flag = 0 AND I.barcode = @barcode OR SIQ.localBarcode = @barcode
	--select @result = 'بارکد و بارکد یکتا' from TB_ITEM AS I
	--left join TB_STORE_ITEM_QTY AS SIQ ON I.id = SIQ.pk_fk_item_id
	--where I.itemType = 1 AND @flag = 0 AND I.barcode = @barcode OR SIQ.uniqueBarcode = @barcode
	RETURN @result
END
