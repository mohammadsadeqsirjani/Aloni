CREATE PROCEDURE [dbo].[SP_stateGetList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20),
	@userId as bigint = null
AS
select id,title from TB_STATE with (nolock)
	where isActive = 1 
	and (@search is null or @search = '' or title like '%'+@search+'%' )
	and (@parent is null or @parent = '' or fk_country_id = CAST(@parent as int) )
	ORDER BY id
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;
