CREATE PROCEDURE [dbo].[SP_getItemListbyItemGroup]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint, 
	@pageNo as int,
	@search as nvarchar(100),
	@type as smallint,
	@parent as varchar(20) = null,
	@itemGroups as dbo.LongType readonly,
	@withoutExistsItems as bit = 0,
	@storeId as bigint
	
AS
	set nocount on
	set @pageNo = ISNULL(@pageNo,0)
	if(@withoutExistsItems = 1)
	begin
	select 
	i.*,tyg.title itemGroupTitle,D.thumbcompeleteLink,D.completeLink
	from
	TB_ITEM i with(nolock) inner join TB_TYP_ITEM_GRP tyg with(nolock) on i.fk_itemGrp_id = tyg.id and i.id not in(select pk_fk_item_id from TB_STORE_ITEM_QTY where pk_fk_store_id = @storeId)
	left join TB_DOCUMENT_ITEM DI with(nolock) on DI.pk_fk_item_id = I.id and DI.isDefault = 1
	left join TB_DOCUMENT D with(nolock) on D.id = DI.pk_fk_document_id
	where
	 i.fk_itemGrp_id in (select id from @itemGroups) and i.fk_status_id = 15 and i.isTemplate = 1
	 and
	 ( i.title like case when @search is not null and @search <> '' then '%'+@search+'%' else i.title end or  i.technicalTitle like case when @search is not null and @search <> ''  then '%'+@search+'%' else i.technicalTitle end)
	 and (tyg.[type] = @type or @type = 0 or @type is null)
	order by i.id
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;
	end
	else
	begin
	select 
	i.*,tyg.title itemGroupTitle,D.thumbcompeleteLink,D.completeLink
	from
	TB_ITEM i with(nolock) inner join TB_TYP_ITEM_GRP tyg with(nolock) on i.fk_itemGrp_id = tyg.id
	left join TB_DOCUMENT_ITEM DI with(nolock) on DI.pk_fk_item_id = I.id and DI.isDefault = 1
	left join TB_DOCUMENT D with(nolock) on D.id = DI.pk_fk_document_id
	where
	 i.fk_itemGrp_id in (select id from @itemGroups) and i.fk_status_id = 15 and i.isTemplate = 1
	 and
	     (i.title like case when @search is not null and @search <> '' then '%'+@search+'%' else i.title end or  i.technicalTitle like case when @search is not null and @search <> ''  then '%'+@search+'%' else i.technicalTitle end)
	 and (tyg.[type] = @type or @type = 0 or @type is null)
	order by i.id
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;
	end
RETURN 0
