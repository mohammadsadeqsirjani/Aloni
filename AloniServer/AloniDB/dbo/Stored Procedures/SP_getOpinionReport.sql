CREATE PROCEDURE [dbo].[SP_getOpinionReport]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = null,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@userId as bigint,
	@storeId as bigint,
	@type as smallint,
	@itemGrpId as bigint,
	@startDateTime as datetime = null,
	@endDatetime as datetime = null
AS
	SET NOCOUNT ON
	SELECT 
	I.id,
	I.title,
	I.technicalTitle,
	I.barcode,
	SIQ.localBarcode,
	I.uniqueBarcode,
	COUNT(SI.id) opinionCnt,
	(select cast(isnull(sum(isnull(II.avgOpinions,0)) / count(II.id),0) as decimal(10,2)) from TB_STORE_ITEM_OPINIONPOLL_OPTIONS II where	 II.fk_opinionpoll_id = (select max(id) from TB_STORE_ITEM_OPINIONPOLL where fk_store_id = @storeId and fk_item_id = I.id and isActive = 1)) opinionAvg,
	(select count(t.pk_fk_usr_id) from (select distinct  pk_fk_usr_id from TB_STORE_ITEM_OPINIONPOLL_OPINIONS where fk_opinionPollId = (select max(id) from TB_STORE_ITEM_OPINIONPOLL where fk_store_id = @storeId and fk_item_id = I.id and isActive = 1)) as t) participateCnt,
	(select count(id) from TB_STORE_ITEM_EVALUATION where fk_store_id = @storeId and fk_item_id = I.id) evaluationCnt,
	(select cast(isnull(sum(isnull(rate,0)) / count(id),0) as decimal(10,2)) from TB_STORE_ITEM_EVALUATION where fk_store_id = @storeId and fk_item_id = I.id) evaluationAvg
FROM 
	TB_ITEM I 
	INNER JOIN TB_STORE_ITEM_OPINIONPOLL SI ON I.id = SI.fk_item_id
	INNER JOIN TB_STORE_ITEM_QTY SIQ ON SIQ.pk_fk_item_id = I.id
WHERE
	SIQ.pk_fk_store_id = @storeId
	AND
	SI.fk_store_id = @storeId
	AND
	(SI.startDateTime >= @startDateTime or @startDateTime is null)
	AND
	(SI.endDateTime <= @endDatetime or @endDatetime is null)
	AND
	(i.fk_itemGrp_id = @itemGrpId or @itemGrpId is null or @itemGrpId = 0)
	AND
	i.itemType = @type
GROUP BY
	I.id,
	I.title,
	I.technicalTitle,
	I.barcode,
	SIQ.localBarcode,
	I.uniqueBarcode

ORDER BY 
	I.id
	
RETURN 0
