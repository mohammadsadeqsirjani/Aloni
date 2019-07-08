CREATE PROCEDURE [dbo].[SP_getLanguage]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = null,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@userId as bigint
AS
	SET NOCOUNT ON
	set @pageNo = ISNULL(@pageNo,0)
	select id,title,isRTL from TB_LANGUAGE with(nolock)
	where
	  title like case when @search is not null and @search <> '' then '%'+@search+'%' END or @search is null
	order by id
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROW ONLY
RETURN 0
