﻿CREATE PROCEDURE [dbo].[SP_getCustomCategoryItemDetailList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = 0,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@userId as bigint,
	@storeId as bigint,
	@catId as bigint = null,
	@type as smallint = null,
	@sortType as tinyint = 1
AS
	SET NOCOUNT ON
	declare @offset int= (case when @catId = 0 or @catId is null then (@pageNo * 10) else (@pageNo * 10000) end)
	declare @fetch int= (case when @catId = 0 or @catId is null then 10 else 10000 end)
	declare @offset1 int= (case when @catId = 0 or @catId is null then (@pageNo * 10000) else (@pageNo * 10) end)
	declare @fetch1 int= (case when @catId = 0 or @catId is null then 10000 else 10 end)
	select 
		c.id,
		i.id itemId,
		i.title itemTitle,
		ISNULL(rtyg.title,tyg.title) grpTitle,
		d.thumbcompeleteLink image_
	from 
		TB_STORE_CUSTOM_CATEGORY C
		inner join TB_STORE_CUSTOMCATEGORY_ITEM CI on c.id = CI.pk_fk_custom_category_id
		inner join TB_ITEM I on CI.pk_fk_item_id = i.id
		inner join TB_TYP_ITEM_GRP tyg on tyg.id = i.fk_itemGrp_id
		left join TB_TYP_ITEM_GRP_TRANSLATIONS rtyg on tyg.id = rtyg.id and rtyg.lan= @clientLanguage
		left join TB_DOCUMENT_ITEM DI on i.id = di.pk_fk_item_id and di.isDefault = 1
		left join TB_DOCUMENT D on Di.pk_fk_document_id = D.id
	where 
		c.fk_store_id = @storeId
		and 
		c.id = @catId
		and
		(c.type = @type or @type = 0 or @type is null)
	    and
		(c.title like '%' + @search + '%' or @search is null or @search = '')
	order by c.id
	OFFSET case when @pageNo >= 0 then @offset1 else 1000000000 end ROWS
	FETCH NEXT case when @pageNo >= 0 then @fetch1 else 1000000000 end ROWS ONLY 
	
RETURN 0
