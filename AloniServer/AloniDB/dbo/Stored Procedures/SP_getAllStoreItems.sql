CREATE PROCEDURE [dbo].[SP_getAllStoreItems]
	 @clientLanguage AS CHAR(2)
	,@appId AS TINYINT
	,@clientIp AS VARCHAR(50)
	,@userId AS BIGINT
	,@pageNo AS INT = 0
	,@search AS NVARCHAR(100)
	,@parent AS VARCHAR(20) = NULL
	,@storeId AS BIGINT
	,@type as smallint = 0

AS
SET NOCOUNT ON
SET @pageNo = isnull(@pageNo, 0)


	SELECT 
		 si.pk_fk_item_id
		,i.title
		,d.completeLink
		,d.thumbcompeleteLink
		,ISNULL(tryg.title, tyg.title) grpTitle
		,tyg.id grpId
		,case when i.itemType = 1 or tyg.[type] is null then 'کالا'
			  when i.itemType = 2 then 'پرسنل'
			  when i.itemType = 3 then 'شغل'
			  when i.itemType = 4 then 'شی'
			  when i.itemType = 5 then 'سازمان'
			  when i.itemType = 6 then 'شعبه'
			  when i.itemType = 6 then 'مکان'
		 end itemType
		
	FROM
		TB_STORE_ITEM_QTY si WITH (NOLOCK)
		INNER JOIN TB_ITEM i WITH (NOLOCK) ON si.pk_fk_item_id = i.id
		INNER JOIN TB_TYP_ITEM_GRP tyg WITH (NOLOCK) ON tyg.id = i.fk_itemGrp_id
		LEFT JOIN TB_TYP_ITEM_GRP_TRANSLATIONS tryg WITH (NOLOCK) ON tryg.id = tyg.id	AND tryg.lan = @clientLanguage
		LEFT JOIN TB_DOCUMENT_ITEM DI WITH (NOLOCK) ON DI.pk_fk_item_id = i.id	AND DI.isDefault = 1
		LEFT JOIN TB_DOCUMENT D  WITH (NOLOCK) ON DI.pk_fk_document_id = D.id
	
	WHERE
		(i.itemType = @type or @type = 0)
	    AND
			si.pk_fk_store_id = @storeId
		 AND 
			(i.title LIKE '%' + @search + '%' or @search is null or @search = '')
		 AND
			(si.fk_status_id = 15 and i.fk_status_id = 15)
	order by i.id
	offset (@pageno *10) rows
	fetch next 10 row only	
	
RETURN 0
