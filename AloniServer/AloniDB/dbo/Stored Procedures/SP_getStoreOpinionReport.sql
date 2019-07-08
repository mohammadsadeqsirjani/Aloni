CREATE PROCEDURE [dbo].[SP_getStoreOpinionReport]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = null,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@userId as bigint,
	@storeId as bigint,
	@fk_status_id as int
AS
	SET NOCOUNT ON
	SELECT 
	    itemId,
		itemTitle,
		storeId,
		storeTitle,
		opinionId,
		opinionTitle,
		comment,
		dbo.func_udf_Gregorian_To_Persian(saveDateTime) dateTime,
		userId,
		userName
    FROM 
		VW_storeCommentOpinion
WHERE
	storeId = @storeId
	AND
	(statusId = @fk_status_id or @fk_status_id is null or @fk_status_id = 0)

ORDER BY 
	opinionId
OFFSET (isnull(@pageNo,0) * 10) ROWS
FETCH NEXT 10 ROWS ONLY;

SELECT 
	    itemId,
		itemTitle,
		storeId,
		storeTitle,
		evaluationId,
		comment,
		dbo.func_udf_Gregorian_To_Persian(saveDateTime) dateTime,
		userId,
		userName
    FROM 
		VW_storeEvaluation
WHERE
	storeId = @storeId
	AND
	(statusId = @fk_status_id or @fk_status_id is null or @fk_status_id = 0)

ORDER BY 
	evaluationId
OFFSET (isnull(@pageNo,0) * 10) ROWS
FETCH NEXT 10 ROWS ONLY;	
RETURN 0
