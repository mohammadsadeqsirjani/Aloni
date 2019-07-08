CREATE PROCEDURE [dbo].[SP_updateItemReview]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@itemId as bigint,
	@review as text
AS
	UPDATE TB_ITEM SET review = @review WHERE id = @itemId
	IF(@@ROWCOUNT > 0)
	BEGIN
		SET @rMsg = 'SUCCESS'
		SET @rCode = 1
		RETURN 0
	END
	SET @rCode = 0
	SET @rMsg = 'ITEM ID NOT FOUND'
RETURN 0
