CREATE PROCEDURE [dbo].[SP_getObjectinStoreList]
	
	 @clientLanguage AS CHAR(2)
	,@appId AS TINYINT
	,@clientIp AS VARCHAR(50)
	,@userId AS BIGINT
	,@pageNo AS INT = 0
	,@search AS NVARCHAR(100)
	,@parent AS VARCHAR(20) = NULL
	,@storeId AS BIGINT
	,@state AS TINYINT
	,@orderType AS SMALLINT = 1
	,@type as smallint = 4
	,@itemGrp as bigint = 0
	,@dontShowinginStoreItem as smallint = 0
	,@hasOpinion as smallint = 0


AS
SET NOCOUNT ON
SET @pageNo = isnull(@pageNo, 0)
IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp;
   ;with data_
   as
   (
	SELECT distinct
		 si.pk_fk_item_id,si.localBarcode,i.title,i.uniqueBarcode,si.dontShowinginStoreItem		
		,d.completeLink
		,d.thumbcompeleteLink
		,i.technicalTitle
		,ISNULL(tryg.title, tyg.title) grpTitle,tyg.id grpId,
		i.unitName,
		sio.id,
		(select (sum(avgOpinions)/COUNT(id)) from TB_STORE_ITEM_OPINIONPOLL_OPTIONS where fk_opinionpoll_id = SIO.id group by fk_opinionpoll_id) avgOpinions,--SIOPT.avgOpinions,
		SIOPT.cntOpinions,
		dbo.func_getDateByLanguage(@clientLanguage, SIO.startDateTime,0) startDateTime,
		dbo.func_getDateByLanguage(@clientLanguage, SIO.endDateTime,0) endDateTime,
		case when SIO.id is not null then 1 else 0 end hasOpinion,
		SIO.resultIsPublic,
		SIO.id pollId,
		ISNULL(i.isLocked,0) isLocked,
		(select count(id) from  TB_STORE_ITEM_EVALUATION SIE with(nolock) where i.id = sie.fk_item_id and fk_status_id = 107 and fk_store_id = @storeId) commentWaitForConfirmCnt

	FROM
	TB_STORE_ITEM_QTY si WITH (NOLOCK)
	INNER JOIN TB_ITEM i WITH (NOLOCK) ON si.pk_fk_item_id = i.id
	INNER JOIN TB_TYP_ITEM_GRP tyg WITH (NOLOCK) ON tyg.id = i.fk_itemGrp_id

	LEFT join TB_STORE_ITEM_OPINIONPOLL SIO WITH (NOLOCK) ON si.pk_fk_item_id = SIO.fk_item_id
	LEFT join TB_STORE_ITEM_OPINIONPOLL_OPINIONS SIOO WITH (NOLOCK) ON SIOO.fk_opinionPollId = SIO.id
	LEFT join TB_STORE_ITEM_OPINIONPOLL_OPTIONS SIOPT WITH (NOLOCK) ON SIOPT.fk_opinionpoll_id = SIO.id
	LEFT JOIN TB_TYP_ITEM_GRP_TRANSLATIONS tryg WITH (NOLOCK) ON tryg.id = tyg.id AND tryg.lan = @clientLanguage
	LEFT JOIN TB_DOCUMENT_ITEM DI WITH (NOLOCK) ON DI.pk_fk_item_id = i.id AND DI.isDefault = 1
	LEFT JOIN TB_DOCUMENT D ON DI.pk_fk_document_id = D.id
	
	WHERE
	  si.pk_fk_store_id = @storeId
	 AND
	  ((i.title LIKE CASE WHEN @search IS NOT NULL AND @search <> '' THEN '%' + @search + '%' ELSE i.title END)OR(i.barcode LIKE CASE WHEN @search IS NOT NULL AND @search <> '' THEN '%' + @search + '%' ELSE i.barcode END or	@search is null or @search = '')
	 OR
	  (si.localBarcode LIKE CASE WHEN @search IS NOT NULL AND @search <> ''	THEN '%' + @search + '%' ELSE si.localBarcode END or @search is null or	@search = ''))
	
	 AND 
		(isnull(SIO.isActive,0) = CASE WHEN @state = 1  THEN 1 WHEN @state = 2 THEN 0 END OR @state = 0)
	 AND
		(itemType = @type or @type = 0 or @type is null) 
	AND
		(tyg.id = @itemGrp or @itemGrp = 0 or @itemGrp is null)
	 And
		((si.dontShowinginStoreItem = case when @dontShowinginStoreItem = 2 then 1 when @dontShowinginStoreItem = 1 then 0 end) or @dontShowinginStoreItem = 0 or @dontShowinginStoreItem is null)
	AND
		((SIO.isActive = case when @hasOpinion = 1 then 1 when @hasOpinion = 2 then 0 end and SIO.startDateTime <= case when @hasOpinion = 1 then GETDATE() end and SIO.endDateTime > case when @hasOpinion = 1 then GETDATE() end) or @hasOpinion = 0)
	AND (i.id = cast(@parent as bigint) or @parent is null or @parent = '0')
	)

	select *  into #temp from data_
	declare @temp table(lastId int,itemId bigint)
	insert into @temp select max(id),pk_fk_item_id from #temp group by pk_fk_item_id
	select * from #temp where id in(select lastId from @temp) or id is null
	ORDER BY CASE 
				WHEN @orderType = 5	THEN avgOpinions END ASC
		    ,CASE 
				WHEN @orderType = 6	THEN avgOpinions END DESC
			,CASE 
				WHEN @orderType = 7 THEN cntOpinions END ASC
			,CASE 
				WHEN @orderType = 8 THEN cntOpinions END DESC
			
    OFFSET(@pageNo * 10) ROWS
	FETCH NEXT 10 ROWS ONLY;

	select cast((sum(rate)/COUNT(E.id)) as decimal(10,1)) as rate , COUNT(E.id) cnt,fk_item_id from TB_STORE_ITEM_EVALUATION E inner join #temp T on T.pk_fk_item_id = E.fk_item_id  group by fk_item_id

	select
		GG.id catId,GG.title catTitle,t.pk_fk_item_id
	from
		#temp t
	inner join TB_STORE_CUSTOMCATEGORY_ITEM cti with(nolock) on cti.pk_fk_item_id = t.pk_fk_item_id
	inner JOIN TB_STORE_CUSTOM_CATEGORY GG WITH(NOLOCK) ON GG.id = cti.pk_fk_custom_category_id
RETURN 0

