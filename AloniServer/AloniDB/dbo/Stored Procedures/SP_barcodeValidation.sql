CREATE PROCEDURE [dbo].[SP_barcodeValidation]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@pageNo as int = 0,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@barcode as varchar(150),
	@storeId as bigint,
	@checkLocalBarcode as bit = 0,
	@type as smallint = 0,
	@searchInMyItems as bit = 0
AS
	SET NOCOUNT ON
	set @pageNo = ISNULL(@pageNo,0)
	if(@searchInMyItems = 1)
	begin
		SELECT distinct
			TYG.title grouptitle,i.id,i.title,
			d.completeLink,d.thumbcompeleteLink,
			i.technicalTitle,
			''  price,
			i.isTemplate,
			case when i.barcode = @barcode then 0 when SIQ.localBarcode = @barcode then 1 end matchWithLocalBarcode,
			case when i.isTemplate = 1 then 0 when i.isTemplate = 0 and i.fk_savestore_id <> @storeId then 0 else 1 end editable
		FROM 
			TB_ITEM I inner join TB_TYP_ITEM_GRP TYG on i.fk_itemGrp_id = TYG.id
			left join TB_STORE_ITEM_QTY SIQ on i.id = SIQ.pk_fk_item_id and pk_fk_store_id = @storeId 
			left join TB_DOCUMENT_ITEM DI on i.id = DI.pk_fk_item_id  and  isDefault = 1 
			left join TB_DOCUMENT D on DI.pk_fk_document_id = d.id and fk_documentType_id = 2 and isDeleted <> 1
		where
			(i.barcode = @barcode or SIQ.localBarcode = @barcode or I.uniqueBarcode = @barcode) and i.fk_status_id = 15 and SIQ.pk_fk_store_id = @storeId
		order by i.id
		OFFSET (@pageNo * 10) ROWS
		FETCH NEXT 10 ROWS ONLY;
	end
	else
	begin
		SELECT distinct
			TYG.title grouptitle,i.id,i.title,
			d.completeLink,d.thumbcompeleteLink,
			i.technicalTitle,
			case when (SIQ.price = 0 or SIQ.price is null) then '' else dbo.func_getPriceAsDisplayValue(SIQ.price,@clientLanguage,@storeId) end as  price,
			i.isTemplate,
			case when i.barcode = @barcode then 0 when SIQ.localBarcode = @barcode then 1 end matchWithLocalBarcode,
			case when i.isTemplate = 1 then 0 when i.isTemplate = 0 and i.fk_savestore_id <> @storeId then 0 else 1 end editable
		FROM 
			TB_ITEM I inner join TB_TYP_ITEM_GRP TYG on i.fk_itemGrp_id = TYG.id
			left join TB_STORE_ITEM_QTY SIQ on i.id = SIQ.pk_fk_item_id and pk_fk_store_id = @storeId 
			left join TB_DOCUMENT_ITEM DI on i.id = DI.pk_fk_item_id  and  isDefault = 1 
			left join TB_DOCUMENT D on DI.pk_fk_document_id = d.id and fk_documentType_id = 2 and isDeleted <> 1
		where
			(i.barcode = @barcode  or  SIQ.localBarcode = case when @checkLocalBarcode = 1 then @barcode end  or I.uniqueBarcode = @barcode)and (i.isTemplate = 1 or i.id in (select id from TB_ITEM where isTemplate = 0 and fk_savestore_id = @storeId))
			and (@type = 0 or @type is null or TYG.type = @type)
			and
				i.fk_status_id = 15
			
		order by i.id
		OFFSET (@pageNo * 10) ROWS
		FETCH NEXT 10 ROWS ONLY;
	end
RETURN 0
