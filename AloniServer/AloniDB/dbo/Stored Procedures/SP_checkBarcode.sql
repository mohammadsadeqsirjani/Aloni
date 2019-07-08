CREATE PROCEDURE [dbo].[SP_checkBarcode]
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
	SET NOCOUNT ON
	
	select i.id,title,i.barcode,'موجود در پنل شما' [status]
	from TB_ITEM I  with(nolock) inner join TB_STORE_ITEM_QTY SIQ   with(nolock) on i.id = SIQ.pk_fk_item_id
	inner join @barcodeList B 
	 on b.id = i.barcode 
	where
	  SIQ.pk_fk_store_id = @storeId and i.fk_status_id = 15 
	union all 
	select i.id,title,i.barcode,'موجود در آیتم های مرجع' [status]
	from TB_ITEM I  with(nolock)
	inner join @barcodeList B 
	 on b.id = i.barcode and i.isTemplate = 1
	where
	  i.fk_status_id = 15 
RETURN 0