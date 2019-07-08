CREATE PROCEDURE [dbo].[SP_getMessageListInSpecialConversation]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20) = null,
	@userId as bigint,
	@convId as bigint,
	@storeId as bigint = 0,
	@convAsPortal as bit = 0,
	@evalId as bigint = 0,
	@commentId as bigint = 0
AS
	SET NOCOUNT ON
	set @pageNo = ISNULL(@pageNo,0)
	declare @destId bigint
	declare @id bigint = case when @storeId is not null then @storeId else @userId end
	select @destId = case when fk_from = @id then fk_to when fk_to = @id then fk_from end from TB_CONVERSATION where id = @convId
	if(@storeId > 0 and @convId > 0)
	begin
		select 
			m.id,
			dbo.func_getDateByLanguage(@clientLanguage,m.saveDateTime,1) saveDate,
		    substring(cast((cast(m.saveDateTime as time)) as varchar(50)),0,6)  saveTime,
			m.message,
			dbo.func_getDateByLanguage(@clientLanguage,m.seenDateTime,1) seenDate,
			substring(cast((CAST(m.seenDateTime as time))  as varchar(50)),0,6) seenTime,
			case when m.fk_store_senderStoreId = @storeId then 1 else 0 end isMine
		from 
			TB_MESSAGE m inner join tb_conversation C on m.fk_conversation_id = c.id
			--left join TB_USR U on m.fk_usr_senderUser = u.id
			--left join TB_USR U1 on m.fk_usr_destUserId = u1.id
			left join TB_STORE s on m.fk_store_senderStoreId = s.id
			left join TB_STORE s1 on m.fk_store_destStoreId = s1.id
		where
			c.id = @convId or @convId = 0
			AND
			(m.fk_usr_senderUser = @userId or m.fk_usr_destUserId  = @userId or @storeId is not null) or (@convAsPortal = 1)
			and 
			(m.fk_store_senderStoreId = @destId or m.fk_store_destStoreId = @destId or m.fk_usr_senderUser = @destId or m.fk_usr_destUserId  = @destId) or (@convAsPortal = 1)
			and
			 m.[message] like case when @search is not null or @search <> '' then '%'+@search+'%' else m.[message] end

		
		order by m.saveDateTime desc
		OFFSET (@pageNo * 50 ) ROWS
		FETCH NEXT 50 ROWS ONLY;
		
	end
	else if(@storeId > 0 and @convId is null)
	begin
		set @convId = (select id from TB_CONVERSATION where (fk_from = @userId or fk_from = @storeId) and (fk_to = @userId or fk_to = @storeId))
		select @destId = case when fk_from = @id then fk_to when fk_to = @id then fk_from end from TB_CONVERSATION where id = @convId
		select 
			m.id,
			dbo.func_getDateByLanguage(@clientLanguage,m.saveDateTime,1) saveDate,
		    substring(cast((cast(m.saveDateTime as time)) as varchar(50)),0,6)  saveTime,
			m.message,
			dbo.func_getDateByLanguage(@clientLanguage,m.seenDateTime,1) seenDate,
			substring(cast((CAST(m.seenDateTime as time))  as varchar(50)),0,6) seenTime,
			case when m.fk_store_senderStoreId = @storeId then 1 else 0 end isMine
		from 
			TB_MESSAGE m inner join tb_conversation C on m.fk_conversation_id = c.id
			left join TB_STORE s on m.fk_store_senderStoreId = s.id
			left join TB_STORE s1 on m.fk_store_destStoreId = s1.id
		where
			(c.id = @convId or @convId = 0 or @convId is null)
			AND
			(c.fk_conversationAbout_ItemEvaluationId = @evalId or @evalId = 0)
			AND
			(c.fk_conversationAbout_opinionPollId = @commentId or @commentId = 0)
			and
			((m.fk_usr_senderUser = @userId or m.fk_usr_destUserId  = @userId or @storeId is not null) and (c.fk_conversationAbout_opinionPollId is null or c.fk_conversationAbout_ItemEvaluationId is null)) or (@convAsPortal = 1)
			and 
			((m.fk_store_senderStoreId = @destId or m.fk_store_destStoreId = @destId or m.fk_usr_senderUser = @destId or m.fk_usr_destUserId  = @destId) and (c.fk_conversationAbout_opinionPollId is null or c.fk_conversationAbout_ItemEvaluationId is null)) or (@convAsPortal = 1)
			and
			 m.[message] like case when @search is not null or @search <> '' then '%'+@search+'%' else m.[message] end
		
		order by m.saveDateTime desc
		OFFSET (@pageNo * 50 ) ROWS
		FETCH NEXT 50 ROWS ONLY;
		
	end
	else 
	begin
		select 
			m.id,
			dbo.func_getDateByLanguage(@clientLanguage,m.saveDateTime,1) saveDate,
		    substring(cast((cast(m.saveDateTime as time)) as varchar(50)),0,6)  saveTime,
			m.message,
			dbo.func_getDateByLanguage(@clientLanguage,m.seenDateTime,1) seenDate,
			substring(cast((CAST(m.seenDateTime as time))  as varchar(50)),0,6) seenTime,
			case when m.fk_usr_senderUser = @userId then 1 else 0 end isMine
		from 
			TB_MESSAGE m inner join 
			 tb_conversation C on m.fk_conversation_id = c.id
			--left join TB_USR U on m.fk_usr_senderUser = u.id
			--left join TB_USR U1 on m.fk_usr_destUserId = u1.id
			left join TB_STORE s on m.fk_store_senderStoreId = s.id
			left join TB_STORE s1 on m.fk_store_destStoreId = s1.id
		where
			(c.id = @convId or @convId = 0 or @convId is null)
			AND
			(c.fk_conversationAbout_ItemEvaluationId = @evalId or @evalId = 0 or @evalId is null)
			AND
			(c.fk_conversationAbout_opinionPollId = @commentId or @commentId = 0 or @commentId is null)
			and
			((m.fk_usr_senderUser = @userId or m.fk_usr_destUserId  = @userId or @storeId is not null) and (c.fk_conversationAbout_opinionPollId is null or c.fk_conversationAbout_ItemEvaluationId is null)) or (@convAsPortal = 1)
			and 
			((m.fk_store_senderStoreId = @destId or m.fk_store_destStoreId = @destId or m.fk_usr_senderUser = @destId or m.fk_usr_destUserId  = @destId) and (c.fk_conversationAbout_opinionPollId is null or c.fk_conversationAbout_ItemEvaluationId is null)) or (@convAsPortal = 1) 
			and
			 m.[message] like case when @search is not null or @search <> '' then '%'+@search+'%' else m.[message] end
		
		order by m.saveDateTime desc
		OFFSET (@pageNo * 50 ) ROWS
		FETCH NEXT 50 ROWS ONLY;
	end



RETURN 0
