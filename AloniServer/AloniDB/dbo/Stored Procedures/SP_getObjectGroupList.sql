CREATE PROCEDURE [dbo].[SP_getObjectGroupList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint, 
	@pageNo as int = null,
	@parent as varchar(20) = null,
	@search as nvarchar(100),
	@type as smallint = null
AS
	set nocount on;
	set @pageNo = ISNULL(@pageNo,0)
	select 
	 OG.id,
	 ISNULL(OGR.title,OG.title) title
	from
	 TB_TYP_OBJECT_GRP OG with(nolock) left join TB_TYP_OBJECT_GRP_TRANSLATIONS OGR with(nolock) on OG.id = OGR.id and OGR.lan = @clientLanguage
	where 
		(OG.title like '%'+@search+'%' or OGR.title like '%'+@search+'%' or @search is null or @search = '')
		AND 
		OG.isActive = 1
		AND 
		(OG.type = @type or @type is null or @type = 0)
	order by OG.id
	OFFSET (@pageNo * 10) ROWS
	FETCH NEXT 10 ROWS ONLY;
RETURN 0