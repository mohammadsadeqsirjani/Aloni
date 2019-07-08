CREATE PROCEDURE [dbo].[SP_getStoreItemColorList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20) = null,
	@storeId as bigint,
	@justActiveColors AS BIT = 0
AS
	set nocount on
	
	--with item as
	--(
	--	SELECT 
	--		I.id,
	--		I.title
	--	FROM
	--		TB_ITEM I WITH(NOLOCK) 
	--		INNER JOIN TB_STORE_ITEM_QTY SIQ WITH(NOLOCK) ON I.id = SIQ.pk_fk_item_id 
	--		INNER JOIN TB_STORE_ITEM_COLOR SIC ON I.id = SIC.pk_fk_item_id
	--	WHERE
	--		SIC.pk_fk_store_id = @storeId
	--		AND
	--		I.fk_status_id = 15
	--		AND
	--		SIQ.fk_status_id = 15
	--	ORDER BY I.id
	--	OFFSET (@pageNo * 10) ROWS
	--	FETCH NEXT 10 ROW ONLY
	--) select * into #ItemList from item

	SELECT * INTO #ItemList FROM
	(
		SELECT 
			I.id,
			I.title
		FROM
			TB_ITEM I WITH(NOLOCK) 
			INNER JOIN TB_STORE_ITEM_QTY SIQ WITH(NOLOCK) ON I.id = SIQ.pk_fk_item_id 
			INNER JOIN TB_STORE_ITEM_COLOR SIC ON I.id = SIC.pk_fk_item_id
		WHERE
			SIC.pk_fk_store_id = @storeId
			AND
			I.fk_status_id = 15
			AND
			SIQ.fk_status_id = 15
		ORDER BY I.id
		OFFSET (@pageNo * 10) ROWS
		FETCH NEXT 10 ROW ONLY
	) AS SUBQUERY

	SELECT * FROM #ItemList

	
	select
		 I.id itemId,
		 c.id, 
		 ISNULL(ct.title,c.title) as title ,
		 si.isActive,
		 ISNULL(si.colorCost,0) as colorCost
	from
		 TB_STORE_ITEM_COLOR as si with(nolock)
		 inner join TB_COLOR as c with (nolock) on c.id = si.fk_color_id
		 INNER JOIN #ItemList as I ON I.id = si.pk_fk_item_id
		 left join TB_COLOR_TRANSLATIONS as ct with(nolock) on c.id = ct.id and ct.lan = @clientLanguage
	where
		 (c.title like '%'+@search+'%' OR @search IS NULL OR @search = '')
		 and 
		 ((si.isActive = 1 and @justActiveColors = 1) or @justActiveColors = 0)
	
RETURN 0

