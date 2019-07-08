CREATE PROCEDURE [dbo].[SP_getStoreGroupingList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint, 
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20)=null,
	@parentStoreGroupingId as bigint,
	@storeId as bigint
AS
	SET NOCOUNT ON
	set @pageNo = ISNULL(@pageNo,0)
	if(@parentStoreGroupingId is null)
	begin
		select sg.id,sg.title
		from TB_STORE_GROUPING sg with(nolock) 
		where fk_storeGrouping_parent is null and fk_store_id = @storeId
		 and
		 sg.title like case when @search is not null and @search <> '' then '%'+@search+'%' else sg.title end
		order by id  
		OFFSET (@pageNo * 10 ) ROWS
		FETCH NEXT 10 ROWS ONLY;
	end
	else
	begin
		select sg.id,sg.title
		from TB_STORE_GROUPING sg with(nolock) 
		where fk_storeGrouping_parent = @parentStoreGroupingId and fk_store_id = @storeId
			  and
			  sg.title like case when @search is not null and @search <> '' then '%'+@search+'%' else sg.title end
		order by id  
		OFFSET (@pageNo * 10 ) ROWS
		FETCH NEXT 10 ROWS ONLY;
	end
RETURN 0
