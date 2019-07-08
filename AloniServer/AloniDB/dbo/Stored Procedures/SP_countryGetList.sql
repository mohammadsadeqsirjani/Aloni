CREATE PROCEDURE [dbo].[SP_countryGetList]
 @clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20),
	@userId as bigint = null
AS
	select id,title,callingCode from TB_COUNTRY with (nolock)
	where isActive = 1 and (@search is null or @search = '' or title like '%'+@search+'%' )
	ORDER BY Id
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;