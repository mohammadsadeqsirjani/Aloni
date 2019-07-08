CREATE PROCEDURE [dbo].[SP_getItemGroupIncludingItem]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint, 
	@pageNo as int = null,
	@search as nvarchar(100),
	@parent as varchar(20) = null,
	@storeId as bigint,
	@type as smallint
AS
	set nocount on;
	set @pageNo = ISNULL(@pageNo,0)
	
	-- get leaf
	;with result
	as
	(
		SELECT id,
       fk_item_grp_ref,
	   title
	   FROM   TB_TYP_ITEM_GRP t
	   WHERE  NOT EXISTS (SELECT 1
       FROM   TB_TYP_ITEM_GRP
       WHERE  fk_item_grp_ref = t.id)  
	)
	select distinct
	 tyg.id,
	 tyg.title
	
	from 
	 TB_TYP_ITEM_GRP tyg
	where
	tyg.id in ((select id from result)) 
	and 
	((tyg.[type] = @type and @type <> 6) or @type is null or @type = 0 or (tyg.[type] in(3,5) and @type = 6))
	and  
	(tyg.title like '%'+@search+'%' or tyg.keywords like '%'+@search+'%' or @search is null or @search = '' or id = Try_CAST(@search as bigint))
	
	order by tyg.id
	OFFSET (@pageNo * 10) ROWS
	FETCH NEXT 10 ROWS ONLY;
RETURN 0

