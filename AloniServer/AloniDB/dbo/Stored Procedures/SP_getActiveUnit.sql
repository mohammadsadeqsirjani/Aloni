CREATE PROCEDURE [dbo].[SP_getActiveUnit]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20)
AS
	SET NOCOUNT ON
	set @pageNo = ISNULL(@pageNo,0)
	SELECT
		id,title
	FROM
		TB_TYP_UNIT with (nolock)
    WHERE 
		isActive = 1
		and
		title like case when @search is not null and @search <> '' then '%'+@search+'%' else title end
	order by id
	OFFSET (@pageNo * 10) ROWS
	FETCH NEXT 10 ROWS ONLY;
RETURN 0
