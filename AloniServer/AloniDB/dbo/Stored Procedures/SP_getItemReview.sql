CREATE PROCEDURE [dbo].[SP_getItemReview]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = 0,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@userId as bigint,
	@itemId as bigint
	
AS
	SET NOCOUNT ON
	SELECT review from TB_ITEM where id = @itemId
RETURN 0
