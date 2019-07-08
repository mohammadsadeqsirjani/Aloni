CREATE PROCEDURE [dbo].[SP_getEmployeeinStoreList]
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
	,@type as smallint = 2
	,@itemGrpId	as bigint 
	,@showInStoreStatus	as smallint =0
	,@pollStatus as smallint =0
	,@sexStatus	 as smallint=0

AS
SET NOCOUNT ON
SET @pageNo = isnull(@pageNo, 0)
IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp;
   ;with data_
   as
   (
	SELECT distinct
		 si.pk_fk_item_id,i.barcode localBarcode,i.title,i.uniqueBarcode,si.dontShowinginStoreItem		
		,d.completeLink
		,d.thumbcompeleteLink
		,i.technicalTitle
		,ISNULL(tryg.title, tyg.title) grpTitle,tyg.id grpId,
		i.unitName,
		sio.id,
		(select (sum(avgOpinions)/COUNT(id)) from TB_STORE_ITEM_OPINIONPOLL_OPTIONS where fk_opinionpoll_id = SIO.id group by fk_opinionpoll_id) avgOpinions,--SIOPT.avgOpinions,
		(select top 1 cntOpinions from TB_STORE_ITEM_OPINIONPOLL_OPTIONS where fk_opinionpoll_id = SIO.id order by cntOpinions desc) cntOpinions,
		dbo.func_getDateByLanguage(@clientLanguage, SIO.startDateTime,0) startDateTime,
		dbo.func_getDateByLanguage(@clientLanguage, SIO.endDateTime,0) endDateTime,
		case when SIO.id is not null then 1 else 0 end hasOpinion,
		SIO.resultIsPublic,
		SIO.id pollId,
		i.findJustBarcode,
		isnull(i.isLocked,0) isLocked,
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
		(i.itemType = 2)
	 AND
	    (tyg.id = @itemGrpId or @itemGrpId = 0)
	 AND
		((i.sex =case when @sexStatus = 1 then 0 when @sexStatus = 2 then 1 end) or @sexStatus = 0)
	 AND
		((si.dontShowinginStoreItem = case when @showInStoreStatus = 1 then 0 when @showInStoreStatus = 2 then 1 end) or @showInStoreStatus = 0)
	 AND
		((SIO.isActive = case when @pollStatus = 1 then 1 when @pollStatus = 2 then 0 end and SIO.startDateTime <= case when @pollStatus = 1 then GETDATE() end and SIO.endDateTime > case when @pollStatus = 1 then GETDATE() end) or @pollStatus = 0)
	 AND
		i.fk_status_id not in(16,57)
	 AND
		si.fk_status_id not in(16,57)
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

	select cast((sum(rate)/COUNT(E.id)) as decimal(10,1)) as rate , COUNT(E.id) cnt,fk_item_id from TB_STORE_ITEM_EVALUATION E  where e.fk_store_id = @storeId and e.fk_item_id in(select distinct pk_fk_item_id from #temp) group by fk_item_id
RETURN 0
