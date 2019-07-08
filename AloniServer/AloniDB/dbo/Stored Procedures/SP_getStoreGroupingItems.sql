CREATE PROCEDURE [dbo].[SP_getStoreGroupingItems]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint, 
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20),
	@storeGroupingId as bigint,
	@storeId as bigint
AS
	SET NOCOUNT ON
	set @pageNo = ISNULL(@pageNo,0)
	select 
		i.id,i.title,i.barcode,siq.localBarcode,tyg.title groupName,tyg.id groupId
	from 
		TB_STORE_GROUPING sg with(nolock) inner join TB_STORE_ITEM_GROUPING sig with(nolock) on sg.id = sig.pk_fk_grouping_id
		inner join TB_ITEM i with(nolock) on sig.pk_fk_item_id = i.id 
		inner join TB_TYP_ITEM_GRP tyg with (nolock) on i.fk_itemGrp_id = tyg.id 
		inner join TB_STORE_ITEM_QTY siq with(nolock) on i.id = siq.pk_fk_item_id  
	where
		siq.pk_fk_store_id = @storeId and sg.id = @storeGroupingId
		and i.title like case when @search is not null and @search <> ''  then '%'+@search+'%' else i.title end
	order by i.id  
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;
	
RETURN 0
