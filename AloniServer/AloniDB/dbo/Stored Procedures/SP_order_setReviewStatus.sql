CREATE PROCEDURE [dbo].[SP_order_setReviewStatus]
     @clientLanguage AS CHAR(2)
	,@appId as tinyint
	,@clientIp AS VARCHAR(50)
	,@userId as bigint

	,@orderId as bigint
	,@sessionId as bigint
	,@storeId as bigint


	,@rCode AS TINYINT OUT
	,@rMsg AS NVARCHAR(max) OUT
AS


update TB_ORDER
set fk_usr_reviewerUserId = @userId
   ,reviewDateTime = GETDATE()

   where id  = @orderId and fk_store_storeId = @storeId and fk_usr_reviewerUserId is null










SET @rCode = 1;
SET @rMsg = 'success.';

RETURN 0;

fail:

SET @rCode = 0;

RETURN 0;