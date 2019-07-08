CREATE PROCEDURE [dbo].[SP_getStoreColorList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20) = null,
	@storeId as bigint,
	@justActiveColors as bit = 0
AS
	set nocount on
	select * into #items from (select distinct pk_fk_item_id from TB_STORE_ITEM_COLOR where pk_fk_store_id = @storeId and (isActive = case when @justActiveColors = 1 then 1 END or @justActiveColors = 0)) as t
	ORDER BY pk_fk_item_id
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;

	select id,title from TB_ITEM where id in(select pk_fk_item_id from #items)

	select
		i.pk_fk_item_id itemId,
		c.id colorId,
		ISNULL(Cr.title,c.title) colorTitle	,
		SI.isActive,
		SI.effectONPrice
	from
	 TB_STORE_ITEM_COLOR SI
	 inner join
	 #items I on SI.pk_fk_item_id = i.pk_fk_item_id
	 inner join 
	 TB_COLOR C on si.fk_color_id = c.id
	 left join
	 TB_COLOR_TRANSLATIONS Cr on c.id = Cr.id and cr.lan = @clientLanguage
	 where
	 SI.pk_fk_store_id = @storeId
	 and
	 (si.isActive = case when @justActiveColors = 1 then 1 END or @justActiveColors = 0)

RETURN 0

