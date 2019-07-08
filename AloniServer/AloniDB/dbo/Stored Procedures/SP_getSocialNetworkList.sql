CREATE PROCEDURE [dbo].[SP_getSocialNetworkList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@pageNo as int,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@storeId as bigint
AS
	SET NOCOUNT ON
	set @pageNo = ISNULL(@pageNo,0)
	SELECT
		id,socialNetworkType,socialNetworkAccount
	FROM
		TB_STORE_SOCIALNETWORK with (nolock)
    WHERE 
		fk_store_id = @storeId
	order by id
	OFFSET (@pageNo * 10) ROWS
	FETCH NEXT 10 ROWS ONLY;
RETURN 0
