CREATE PROCEDURE [dbo].[SP_getMathItemWithBarcode]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = null,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@userId as bigint,
	@storeId as bigint,
	@barcodeList as dbo.StringType readonly
AS
	set nocount on
	select distinct
		case when i.id is not null  then i.id when SIQ.pk_fk_item_id is not null then SIQ.pk_fk_item_id else 0 end id,
		case when title is null then 'نامشخص' else title end title ,
		case when barcode is null then b.id else barcode end barcode,
		case when i.id is null and SIQ.localBarcode is null then 'آیتمی با این بارکد در پنل موجود نیست' when istemplate = 1 then 'آیتم مرجع می باشد و امکان اختصاص تصویر با آن امکانپذیر نیست' when d.id is not null then 'آیتم دارای عکس می باشد' else 'آیتم در پنل موجود است' ENd status_dsc,
		case when i.id is null and SIQ.localBarcode is null then 0 when istemplate = 1 then 1 when d.id is not null or d1.id is not null then 2 else 3 ENd status_id,
		dbo.func_udf_Gregorian_To_Persian_withTime(d.creationDate) date_,
		d.creationDate date__
		
	from
		@barcodeList B left join
		TB_ITEM I with(nolock) on I.barcode = B.id and fk_savestore_id = @storeId 
		Left JOIN TB_STORE_ITEM_QTY SIQ with(nolock) on B.id = SIQ.localBarcode and pk_fk_store_id = @storeId
	    left join tb_document_item di with(nolock) on i.id = di.pk_fk_item_id
		left join TB_DOCUMENT_ITEM di1 with(nolock) on di1.pk_fk_item_id = SIQ.pk_fk_item_id
		left join tb_document d with(nolock) on di.pk_fk_document_id = d.id and d.isdeleted <> 1
		left join TB_DOCUMENT d1 with(nolock) on d1.id = di1.pk_fk_document_id and d1.isDeleted <> 1
		
RETURN 0
