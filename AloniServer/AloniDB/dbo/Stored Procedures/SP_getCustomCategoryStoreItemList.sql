CREATE PROCEDURE [dbo].[SP_getCustomCategoryStoreItemList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint, 
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20) = null,
	@customCategoryId as bigint = 0,
	@storeId as bigint,
	@itemGroups as dbo.LongType readonly,
	@type as smallint = null
	
AS
	set nocount on
	set @pageNo = ISNULL(@pageNo,0)
	select 
	i.id,
	i.title,
	i.fk_itemGrp_id,
	tyg.title itemGroupTitle,
	i.saveDateTime,
	i.fk_usr_saveUser,
	i.barcode,
	i.fk_status_id,
	i.fk_country_Manufacturer,
	i.fk_unit_id,
	i.manufacturerCo,
	i.technicalTitle,
	i.importerCo,
	i.isTemplate,
	D.thumbcompeleteLink,
	D.completeLink,
	COUNT(i.id) cnt
	from
	TB_ITEM i with(nolock) 
	inner join TB_TYP_ITEM_GRP tyg with(nolock) on i.fk_itemGrp_id = tyg.id
	inner join @itemGroups iteyg on iteyg.id = tyg.id
	inner join TB_STORE_ITEM_QTY SIQ with(nolock) on SIQ.pk_fk_item_id = i.id
	left join TB_DOCUMENT_ITEM DI with(nolock) on DI.pk_fk_item_id = I.id and DI.isDefault = 1
	left join TB_DOCUMENT D with(nolock) on D.id = DI.pk_fk_document_id
	where
	SIQ.pk_fk_store_id = @storeId
	and
	SIQ.pk_fk_item_id not in (select i.pk_fk_item_id from TB_STORE_CUSTOMCATEGORY_ITEM I inner join TB_STORE_CUSTOM_CATEGORY C on c.id = i.pk_fk_custom_category_id where I.pk_fk_custom_category_id = @customCategoryId and (C.type = @type or @type = 0 or @type is null))
	and
	 i.fk_status_id = 15 
	and
	 (i.title like case when @search is not null and @search <> '' then '%'+@search+'%' else i.title end or  i.technicalTitle like case when @search is not null and @search <> ''  then '%'+@search+'%' else i.technicalTitle end)
	
	group by
	i.id,
	i.title,
	i.fk_itemGrp_id,
	tyg.title,
	i.saveDateTime,
	i.fk_usr_saveUser,
	i.barcode,
	i.fk_status_id,
	i.fk_country_Manufacturer,
	i.fk_unit_id,
	i.manufacturerCo,
	i.technicalTitle,
	i.importerCo,
	i.isTemplate,
	D.thumbcompeleteLink,
	D.completeLink
	order by i.id
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;
	
RETURN 0

