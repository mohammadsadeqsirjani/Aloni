CREATE PROCEDURE [dbo].[SP_getStoreSocialNetwork]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@pageNo as int = NULL,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@storeId as bigint
AS
	SET NOCOUNT ON
	
	SELECT
		instagramAccount,
		telegramAccount,
		twitterAccount,
		emailAccount
	FROM
		TB_STORE
    WHERE 
		id = @storeId
	
RETURN 0