CREATE PROCEDURE [dbo].[SP_getItemSizeList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20) = null,
	@storeId as bigint
AS
	set nocount on
	declare @itemId as bigint = case when @parent is null or @parent = '' then 0 else cast(@parent as bigint) end
	SELECT * INTO #ItemList FROM
	(
		SELECT distinct
			I.id,
			I.title
		FROM
			TB_ITEM I WITH(NOLOCK) 
			INNER JOIN TB_STORE_ITEM_QTY SIQ WITH(NOLOCK) ON I.id = SIQ.pk_fk_item_id 
			INNER JOIN TB_STORE_ITEM_SIZE SIZ ON I.id = SIZ.pk_fk_item_id
		WHERE
			SIZ.pk_fk_store_id = @storeId
			AND
			((I.fk_status_id = 15 and @appId = 2) or @appId <> 2)
			AND
			((SIQ.fk_status_id = 15 and @appId = 2) or @appId <> 2)
			AND
			(I.id = @itemId or @parent is null or @parent = '')
		ORDER BY I.id
		OFFSET (@pageNo * 10) ROWS
		FETCH NEXT 10 ROW ONLY
	) AS SUBQUERY

	SELECT * FROM #ItemList
	
	select distinct
		 I.id itemId,
		 si.pk_sizeInfo sizeInfo,
		 si.isActive,
		 ISNULL(si.sizeCost,0) sizeCost
	from
		 TB_STORE_ITEM_SIZE si with(nolock)
		 INNER JOIN #ItemList I ON I.id = si.pk_fk_item_id
		
	where
		 (si.pk_sizeInfo like '%'+@search+'%' OR @search IS NULL OR @search = '')
		
RETURN 0

