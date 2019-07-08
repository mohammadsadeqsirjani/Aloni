CREATE PROCEDURE [dbo].[SP_storeItemLocationGet]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = 0,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@userId as bigint,
	@storeId as bigint
	
	
AS
	SET NOCOUNT ON
	SELECT
		 id,
		 title,
		 [location].Lat lat,
		 [location].Long lng,
		 address
	from	
		TB_STORE_FAVORITE_LOCATION with(nolock)
	where
		fk_store_id = @storeId
	order by id
	OFFSET (@pageNo * 10) ROWS
	FETCH NEXT 10 ROWS ONLY
RETURN 0
