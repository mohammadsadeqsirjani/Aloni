CREATE PROCEDURE [dbo].[SP_getStatisticItemGroup]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint, 
	@pageNo as int = null,
	@search as nvarchar(100),
	@parent as varchar(20) = null,
	@storeId as bigint,
	@withoutExistsItems as bit = 0,
	@type as smallint = 1,
	@catId as bigint = 0
AS
	set nocount on;
	set @pageNo = ISNULL(@pageNo,0)
	-- get leaf
	--;with result
	--as
	--(
	--	SELECT id,
    --  fk_item_grp_ref,
	--  title
	--  FROM   TB_TYP_ITEM_GRP t
	--  WHERE  NOT EXISTS (SELECT 1
    --  FROM   TB_TYP_ITEM_GRP
    --  WHERE  fk_item_grp_ref = t.id)  
	--)
	if(@withoutExistsItems = 1)
	begin
	;with result
	as
	(
	select distinct
	 tyg.id,
	 tyg.title,
	 (select g.fk_item_grp_ref from TB_TYP_ITEM_GRP G where g.id = tyg.id ) Parent,
	 (select COUNT(*) from TB_TYP_ITEM_GRP G where g.fk_item_grp_ref = tyg.id ) childMember,
	 case when @catId is null or @catId = 0 
	 then 
			0
			--select 
			--	COUNT(I.id) from TB_ITEM I
			--where 
			--i.fk_itemGrp_id in(select * from dbo.func_subGrpItemByGrpItemId(tyg.id)) and i.id not in(select pk_fk_item_id from TB_STORE_ITEM_QTY SIQ where pk_fk_store_id = @storeId) and i.isTemplate = 1 and fk_status_id = 15)
		  else 
		  (
		  select COUNT(I.id) from TB_ITEM I 
				inner join TB_STORE_item_qty siq on i.id=siq.pk_fk_item_id
				inner join [dbo].[vw_itemGrp_fullPath] ff on i.fk_itemGrp_id = ff.id and ff.id = tyg.id
		  where 
				i.fk_itemGrp_id in(select id from dbo.func_subGrpItemByGrpItemId(tyg.id))
				and
				i.id not in  
(select CI.pk_fk_item_id from TB_STORE_CUSTOMCATEGORY_ITEM CI where CI.pk_fk_custom_category_id = @catId )  and i.fk_status_id = 15 and siq.fk_status_id=15
and siq.pk_fk_store_id=@storeId

		  )
		  END
	  itemCount
	from 
	--TB_STORE s with(nolock) inner join TB_STORE_EXPERTISE se with(nolock) on s.id = se.pk_fk_store_id
	--inner join TB_EXPERTISE_ITEMGRP ex with(nolock) on se.pk_fk_expertise_id = ex.pk_fk_expertise_id
	--inner join
	 TB_TYP_ITEM_GRP tyg --with(nolock) on ex.pk_fk_itemGrp_id = tyg.id
	where 
	--s.id = @storeId 
	--and
	((tyg.[type] =  @type and @type <> 6) or (tyg.[type] in(3,5) and @type = 6) or @type = 0)
	--and tyg.id in ((select id from result)) 
	and  tyg.title like case when @search is not null and @search <> '' then '%'+@search+'%' else tyg.title end
	--and tyg.isActive = 1
	
	)
	select * into #temp from result
	select id,title,case when Parent not in (select id from #temp) then NULL else Parent end Parent,childMember,itemCount from #temp 
	order by id
	select count(i.id) itemCnt,i.fk_itemGrp_id from TB_ITEM i inner join TB_TYP_ITEM_GRP tyg on i.fk_itemGrp_id = tyg.id where (tyg.type = @type or @type = 0) and i.fk_status_id = 15 and i.isTemplate = 1 and i.id not in(select pk_fk_item_id from TB_STORE_ITEM_QTY SIQ where pk_fk_store_id = @storeId)  group by fk_itemGrp_id
	end
	else
	begin
		;with result
	as
	(
	select distinct
	 tyg.id,
	 tyg.title,
	 (select g.fk_item_grp_ref from TB_TYP_ITEM_GRP G where g.id = tyg.id ) Parent,
	 (select COUNT(*) from TB_TYP_ITEM_GRP G where g.fk_item_grp_ref = tyg.id ) childMember,
	 -- (select COUNT(I.id) from TB_ITEM I where i.fk_itemGrp_id in(select * from dbo.func_subGrpItemByGrpItemId(tyg.id)) and i.isTemplate = 1 and fk_status_id = 15) 
	 0 itemCount
	from 
	--TB_STORE s with(nolock) inner join TB_STORE_EXPERTISE se with(nolock) on s.id = se.pk_fk_store_id
	--inner join TB_EXPERTISE_ITEMGRP as ex with(nolock) on se.pk_fk_expertise_id = ex.pk_fk_expertise_id
	--inner join 
	TB_TYP_ITEM_GRP tyg --with(nolock) on ex.pk_fk_itemGrp_id = tyg.id
	where 
	--s.id = @storeId 
	--and
	tyg.[type] =  @type 
	--and tyg.id in ((select id from result)) 
	and  tyg.title like case when @search is not null and @search <> '' then '%'+@search+'%' else tyg.title end
	--and tyg.isActive = 1
	)
	select * into #temp1 from result
	select id,title,case when Parent not in (select id from #temp1) then NULL else Parent end Parent,childMember,itemCount from #temp1 
	order by id
	select count(i.id) itemCnt,i.fk_itemGrp_id from TB_ITEM i inner join TB_TYP_ITEM_GRP tyg on i.fk_itemGrp_id = tyg.id where (tyg.type = @type or @type = 0) and i.fk_status_id = 15 and i.isTemplate = 1 group by fk_itemGrp_id
	end
	--OFFSET (@pageNo * 10) ROWS
	--FETCH NEXT 10 ROWS ONLY;

RETURN 0
