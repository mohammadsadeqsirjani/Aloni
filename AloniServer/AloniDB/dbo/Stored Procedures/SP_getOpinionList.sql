CREATE PROCEDURE [dbo].[SP_getOpinionList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null ,
	@userId as bigint,
	@storeId as bigint,
	@itemId as bigint,
	@filterStatus as int = 0

AS
	set nocount on
	set @pageNo = ISNULL(@pageNo,0)

	select
	sum(rate) / count(id) useresRateAverrage,
	COUNT(id) commentMember 
	from TB_STORE_ITEM_EVALUATION
	where 
	      fk_item_id = @itemId and fk_store_id = @storeId
		  and
		  ((fk_status_id = 106 and @appId = 2) or @appId <> 2)
		  and
		  (fk_status_id = @filterStatus or @filterStatus = 0)

	select 
		e.id,
		case when (select ss.itemEvaluationShowName from TB_STORE ss where id = e.fk_store_id) = 1 and @appId = 2 then  u.fname + ' ' +ISNULL(u.lname,'') else '' END usrName,
		dbo.func_getDateByLanguage(@clientLanguage,e.saveDateTime,0) [date],
		rate,
		comment ,
		ISNULL(e.fk_status_id,107) statusId,
		ISNULL(ISNULL(st.title,s.title),'مشخص نشده') statusTitle
    from 
		TB_STORE_ITEM_EVALUATION e with (nolock ) 
		inner join TB_USR u on e.fk_usr_id = u.id
		left join TB_STATUS s on s.id = e.fk_status_id
		left join TB_STATUS_TRANSLATIONS st on s.id = st.id and lan = @clientLanguage
	where 
	 fk_item_id = @itemId and fk_store_id = @storeId 
	 and
	 (u.fname like case when  @search is not null and @search <> '' then '%'+@search+'%' else u.fname end or u.lname like case when  @search is not null and @search <> '' then '%'+@search+'%' else u.lname end)
	 and
		  ((e.fk_status_id = 106 and @appId = 2) or @appId <> 2)
	 and
		  (e.fk_status_id = @filterStatus or @filterStatus = 0)
	order by e.saveDateTime desc
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;

RETURN 0
