CREATE PROCEDURE [dbo].[SP_typStorePesrsonalityTypeGetList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = 0,
	@search as nvarchar(100),
	@parent as varchar(20) = null,
	@userId as bigint = null
AS
	set nocount on
	select s.id,
	isnull(ts.title,s.title)title 
	from TB_TYP_STORE_PERSONALITY_TYPE S with (nolock) 
	left join TB_TYP_STORE_PERSONALITY_TYPE_TRANSLATIONS TS with (nolock)  on s.id = TS.id and lan = @clientLanguage
	where  
	@search is null or @search = '' or s.title like '%'+@search+'%' or ts.title like '%'+@search+'%'
	order by s.id
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;
RETURN 0
