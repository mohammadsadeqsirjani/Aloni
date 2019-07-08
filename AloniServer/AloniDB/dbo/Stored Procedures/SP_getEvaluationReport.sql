CREATE PROCEDURE [dbo].[SP_getEvaluationReport]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@userId as bigint,
	@search as nvarchar(100),
	@parent as varchar(20) = null,
	@storeId as bigint,
	@type as int
AS
	set nocount on
	declare @spotSearch as nvarchar(100)= case when @search = '' or @search is null then '""' else @search end
	select
		 i.id,
		 i.title,
		 technicalTitle,
		 barcode,
		 i.uniqueBarcode,
		 (select COUNT(sie.id) from TB_STORE_ITEM_EVALUATION sie where sie.fk_item_id = i.id and sie.fk_store_id = @storeId) evaluationCnt,
		 cast((select SUM(sie.rate) / COUNT(sie.id) from TB_STORE_ITEM_EVALUATION sie where sie.fk_item_id = i.id and sie.fk_store_id = @storeId) as decimal(10,2)) evaluationAvg,
	     (select COUNT(msg.id) from TB_STORE_ITEM_EVALUATION sie inner join TB_CONVERSATION c on sie.id = c.fk_conversationAbout_ItemEvaluationId inner join TB_MESSAGE msg on msg.fk_conversation_id = c.id where sie.fk_item_id = i.id and sie.fk_store_id = @storeId) messageCnt
	from
		 TB_ITEM I with(nolock) 
		 INNER JOIN TB_STORE_ITEM_QTY siq on i.id = siq.pk_fk_item_id
		
	where
	 i.itemType = @type
	 and
		siq.pk_fk_store_id = @storeId
		and 
		((freetext((i.title,technicalTitle,barcode),@spotSearch)) or @search is null or @search = '')	
	ORDER BY i.id
	--OFFSET (@pageNo * 10 ) ROWS
	--FETCH NEXT 10 ROWS ONLY;
RETURN 0

