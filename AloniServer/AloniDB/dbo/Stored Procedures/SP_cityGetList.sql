CREATE PROCEDURE [dbo].[SP_cityGetList]
@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20),
	@userId as bigint = null,
	@withAllItem as bit = 0
AS
	if(@withAllItem = 0)
	begin
		select id,title from TB_CITY with (nolock)
		where 
		isActive = 1 
		and (@search is null or @search = '' or title like '%'+@search+'%' )
		and (@parent is null or @parent = '' or fk_state_id = CAST(@parent as int) )
		ORDER BY Id
		OFFSET (@pageNo * 10 ) ROWS
		FETCH NEXT 10 ROWS ONLY;
	end
	else
	begin
	    select 0 id,'همه' title
		union all
		select id,title from TB_CITY with (nolock)
		where 
		isActive = 1 
		and (@search is null or @search = '' or title like '%'+@search+'%' )
		and (@parent is null or @parent = '' or fk_state_id = CAST(@parent as int) )
		ORDER BY Id
		OFFSET (@pageNo * 10 ) ROWS
		FETCH NEXT 10 ROWS ONLY;
	end