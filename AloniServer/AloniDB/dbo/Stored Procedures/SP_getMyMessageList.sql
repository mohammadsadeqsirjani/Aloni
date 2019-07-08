CREATE PROCEDURE [dbo].[SP_getMyMessageList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@pageNo as int,
	@search as nvarchar(100) = NULL,
	@parent as varchar(20) = NULL,
	@storeId as bigint
AS
	SET NOCOUNT ON
	IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp;
	IF OBJECT_ID('tempdb..#temp2') IS NOT NULL DROP TABLE #temp2;
	if(@storeId is not null)
	begin
		;with target_
	as
	(
		select
			case when fk_store_destStoreId is not null then fk_store_destStoreId when fk_usr_destUserId is not null then fk_usr_destUserId when fk_staff_destStaffId is not null then fk_staff_destStaffId end destId,
			saveDateTime,seenDateTime,[message],m.id,case when fk_usr_senderUser is not null then fk_usr_senderUser when fk_staff_senderStaffId is not null then fk_staff_senderStaffId when fk_store_senderStoreId is not null then fk_store_senderStoreId end sentId,
			case when fk_store_destStoreId is not null then 2 when fk_usr_destUserId is not null then 1 when fk_staff_destStaffId is not null then 3 end destEntityType,
			case when fk_usr_senderUser is not null then 1 when fk_staff_senderStaffId is not null then 3 when fk_store_senderStoreId is not null then 2 end sentEntityType,
			fk_conversation_id,
			fk_conversationAbout_ItemId,
			conversationWithPortal,
			conversationWithStore,
			c.fk_conversationAbout_ItemEvaluationId,
			c.fk_conversationAbout_opinionPollId
	    from 
			TB_MESSAGE M inner join TB_CONVERSATION C on m.fk_conversation_id = c.id
		where 
			dbo.Func_GetUserStaffStore(@userId,@storeId) = 11
			and 
			(m.fk_store_destStoreId =  @storeId or m.fk_store_senderStoreId = @storeId)
			and 
			c.conversationWithStore = 1
	)
	
	    select * into #temp from [target_] order by saveDateTime 
		declare @temp1 as table(destId bigint,sentId bigint,lastId bigint,unreadMessage int,convId bigint)
		insert into @temp1(lastId,convId)
		select max(id),fk_conversation_id from #temp group by fk_conversation_id

		select 
		case when sentEntityType = 1 then m.sentId end sentUserId,
		case when sentEntityType = 2 then m.sentId end sentStoreId,
		case when m.sentId = @storeId then case when m.destEntityType = 1 then (select fname+' '+isnull(lname,'') from TB_USR where id = m.destId) when m.destEntityType = 2 then (select title from TB_STORE where id = m.destId) END
		else
		case when m.sentEntityType = 1 then (select fname+' '+isnull(lname,'') from TB_USR where id = m.sentId) when m.sentEntityType = 2 then (select title from TB_STORE where id = m.sentId) END END title,
		
		case when s1.id is not null then s1.title when u.id is not null then u.fname + ' ' +isnull(u.lname,'') end [sent],
		case when s.id is not null then s.title when u1.id is not null then U1.fname+' '+ISNULL(u1.lname,'') end dest,
		case when s.id is not null then s.id end destStoreId,
		case when u1.id is not null then U1.id end destUserId,
		m.message,
		dbo.func_getDateByLanguage(@clientLanguage, m.saveDateTime,1) date_,
		m.fk_conversation_id,
		ISNULL(m.fk_conversationAbout_ItemId,0) fk_conversationAbout_ItemId,
		m.conversationWithPortal,
		m.conversationWithStore,
		ISNULL(m.fk_conversationAbout_opinionPollId,0) fk_conversationAbout_opinionPollId,
		ISNULL(m.fk_conversationAbout_ItemEvaluationId,0) fk_conversationAbout_ItemEvaluationId
	from 
		#temp M
		inner join @temp1 T on m.id = t.lastId
		left join TB_STORE S on s.id = m.destId and destEntityType = 2
		left join TB_STORE S1 on m.sentId = S1.id and sentEntityType = 2
		left join TB_USR U on m.sentId = u.id and sentEntityType = 1 
		left join TB_USR U1 on m.destId = U1.id and destEntityType = 1
	where 
		m.id in (select lastId from @temp1)
		and (s.id = case when @storeId is not null then @storeId else s.id end or s1.id = case when @storeId is not null then @storeId else s1.id end)
		and (m.[message] like case when  @search is not null and @search = '' then '%'+@search+'%' end or @search is null or @search = '')

		select count(id) unread,sentId from #temp where seenDateTime is null and  destId = @storeId group by sentId
		
	end
	else
	begin
		;with target__
	as
	(
		select
			case when fk_store_destStoreId is not null then fk_store_destStoreId when fk_usr_destUserId is not null then fk_usr_destUserId when fk_staff_destStaffId is not null then fk_staff_destStaffId end destId,
			saveDateTime,seenDateTime,[message],id,case when fk_usr_senderUser is not null and messageAsStore = 0 then fk_usr_senderUser when fk_staff_senderStaffId is not null then fk_staff_senderStaffId when fk_store_senderStoreId is not null and messageAsStore = 1 then fk_store_senderStoreId end sentId,
			case when fk_store_destStoreId is not null then 2 when fk_usr_destUserId is not null then 1 when fk_staff_destStaffId is not null then 3 end destEntityType,
			case when fk_usr_senderUser is not null and messageAsStore = 0 then 1 when fk_staff_senderStaffId is not null then 3 when fk_store_senderStoreId is not null and messageAsStore = 1 then 2 end sentEntityType,
			fk_conversation_id
	
		
	    from 
			TB_MESSAGE M
		where 
			((m.fk_usr_senderUser = @userId and fk_store_senderStoreId is null) or (m.fk_usr_destUserId = @userId and fk_store_destStoreId is null))
			
	
	)

	select * into #temp2 from [target__] order by saveDateTime 
		
		insert into @temp1(lastId,convId)
		select max(id),fk_conversation_id from #temp2 group by fk_conversation_id
	
		select
		
		case when sentEntityType = 1 then m.sentId end sentUserId,
		case when sentEntityType = 2 then m.sentId end sentStoreId,
		case when fk_conversationAbout_ItemId is not NULL then (select I.title from TB_ITEM I where id = fk_conversationAbout_ItemId) 
			 when fk_conversationAbout_opinionPollId is not null then (select s.title from TB_STORE_ITEM_OPINIONPOLL S where id = fk_conversationAbout_opinionPollId)
			 when fk_conversationAbout_ItemEvaluationId is not null then (select f.comment from TB_STORE_ITEM_EVALUATION F where id = fk_conversationAbout_ItemEvaluationId)
		     when m.sentId = @userId then 
										case when m.destEntityType = 1 
												then (select fname+' '+isnull(lname,'') from TB_USR where id = m.destId) 
											 when m.destEntityType = 2 
												then (select title from TB_STORE where id = m.destId) END
		else
		case when m.sentEntityType = 1 then (select fname+' '+isnull(lname,'') from TB_USR where id = m.sentId) when m.sentEntityType = 2 then (select title from TB_STORE where id = m.sentId) END END title,
		
		case when s1.id is not null then s1.title when u.id is not null then u.fname + ' ' +isnull(u.lname,'') end [sent],
		case when s.id is not null then s.title when u1.id is not null then U1.fname+' '+ISNULL(u1.lname,'') end dest,
		case when s.id is not null then s.id end destStoreId,
		case when u1.id is not null then U1.id end destUserId,
		m.message,
		dbo.func_getDateByLanguage(@clientLanguage, m.saveDateTime,1) date_,
		m.fk_conversation_id,
		ISNULL(CCC.fk_conversationAbout_ItemId,0) fk_conversationAbout_ItemId,
		ccc.conversationWithPortal,
		CCC.conversationWithStore,
		ISNULL(CCC.fk_conversationAbout_opinionPollId,0) fk_conversationAbout_opinionPollId,
		ISNULL(CCC.fk_conversationAbout_ItemEvaluationId,0) fk_conversationAbout_ItemEvaluationId
	from 
		#temp2 M

		inner join @temp1 T on m.id = t.lastId
		inner join TB_CONVERSATION CCC on CCC.id = M.fk_conversation_id
		left join TB_STORE S on s.id = m.destId and destEntityType = 2
		left join TB_STORE S1 on m.sentId = S1.id and sentEntityType = 2
		left join TB_USR U on m.sentId = u.id and sentEntityType = 1
		left join TB_USR U1 on m.destId = U1.id and destEntityType = 1
	where 
		m.id in (select lastId from @temp1)
		and (s.id = case when @storeId is not null then @storeId end or @storeId is null)
		and ((m.[message] like case when  @search is not null and @search = '' then '%'+@search+'%' end or @search is null or @search = '') or @search is null or @search = '')
		select count(id) unread,sentId from #temp2 where seenDateTime is null and  destId = @userId group by sentId
	end

	
RETURN 0