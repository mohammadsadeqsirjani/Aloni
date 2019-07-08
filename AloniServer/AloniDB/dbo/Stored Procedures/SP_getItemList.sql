CREATE PROCEDURE [dbo].[SP_getItemList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = null,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@userId as bigint,
	@storeId as bigint,
	@type as smallint,
	@itemGrpId as bigint = 0,
	@justCreateByPanel as bit = 0
AS
	SET NOCOUNT ON
	
	if(@justCreateByPanel = 0)
	begin
	select distinct
		i.id,title,i.technicalTitle,i.barcode,i.uniqueBarcode,SIQ.localBarcode,d.thumbcompeleteLink
	from 
		TB_ITEM i with(nolock) 
		inner join TB_STORE_ITEM_QTY SIQ with(nolock) on i.id = SIQ.pk_fk_item_id
		left join TB_DOCUMENT_ITEM DI with(nolock) on i.id = DI.pk_fk_item_id and DI.isDefault = 1
		left join TB_DOCUMENT D with(nolock) on d.id = DI.pk_fk_document_id
	where
		pk_fk_store_id = @storeId and i.itemType = @type
		and
		(i.fk_itemGrp_id = @itemGrpId or @itemGrpId = 0)
		and
		i.fk_status_id not in(16,57)
		
	end
	else
	begin
		select distinct
		i.id,title,i.technicalTitle,i.barcode,i.uniqueBarcode,SIQ.localBarcode,d.thumbcompeleteLink
	from 
		TB_ITEM i with(nolock) 
		inner join TB_STORE_ITEM_QTY SIQ with(nolock) on i.id = SIQ.pk_fk_item_id
		left join TB_DOCUMENT_ITEM DI with(nolock) on i.id = DI.pk_fk_item_id and DI.isDefault = 1
		left join TB_DOCUMENT D with(nolock) on d.id = DI.pk_fk_document_id
	where
		pk_fk_store_id = @storeId and i.itemType = @type
		and
		(i.fk_itemGrp_id = @itemGrpId or @itemGrpId = 0)
		and
		i.fk_status_id not in(16,57)
		and
		i.isTemplate = 0  and i.fk_savestore_id = @storeId 
		and
		i.id not in(select ODL.fk_item_id from TB_ORDER_DTL ODL)
	end
RETURN 0
