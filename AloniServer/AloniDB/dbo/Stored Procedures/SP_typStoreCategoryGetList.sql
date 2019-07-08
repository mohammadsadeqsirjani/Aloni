CREATE PROCEDURE [dbo].[SP_typStoreCategoryGetList]
@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100) = null,
	@parent as varchar(20),
	@userId as bigint = null
AS
	SET NOCOUNT ON
	set @pageNo = ISNULL(@pageNo,0)
	select s.id,isnull(tr.title,s.title)title from TB_TYP_STORE_CATEGORY S with (nolock) inner join TB_TYP_STORE_CATEGORY_TRANSLATIONS TR with(nolock) on s.id = tr.id and lan = @clientLanguage
	where isActive = 1 
	and ( (s.title like case when @search is not null and @search <> '' then '%'+@search+'%' else s.title end ) or  (TR.title like case when @search is not null and @search <> '' then '%'+@search+'%' else TR.title end))
	ORDER BY s.id
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;