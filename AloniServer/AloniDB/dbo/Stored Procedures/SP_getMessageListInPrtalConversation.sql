CREATE PROCEDURE [dbo].[SP_getMessageListInPrtalConversation]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20) = null,
	@userId as bigint,
	@convId as bigint

AS
	SET NOCOUNT ON
	set @pageNo = ISNULL(@pageNo,0)
	select 
			m.id,
			u.fname + ' ' + isnull(u.lname,'') senderName,
			u1.fname + ' ' + isnull(u1.lname,'') reciverName,
			ISNULL(sst.title,ss.title) senderStafftitle,
			dbo.func_getDateByLanguage(@clientLanguage,m.saveDateTime,1) saveDate,
		    substring(cast((cast(m.saveDateTime as time)) as varchar(50)),0,6)  saveTime,
			m.message,
			dbo.func_getDateByLanguage(@clientLanguage,m.seenDateTime,1) seenDate,
			substring(cast((CAST(m.seenDateTime as time)) as varchar(50)),0,6) seenTime,
			case when m.fk_usr_senderUser = @userId then 1 else 0 end isMine
	from 
			TB_MESSAGE m inner join tb_conversation C on m.fk_conversation_id = c.id
			left join TB_USR U on m.fk_usr_senderUser = u.id
			left join TB_USR U1 on m.fk_usr_destUserId = u1.id
			left join TB_USR_STAFF US on u.id = US.fk_usr_id
			left join TB_STAFF SS on US.fk_staff_id = SS.id
			left join TB_STAFF_TRANSLATIONS SST on ss.id = SST.id and SST.lan = @clientLanguage

	where
		c.id = @convId 
		and
		@appId = 3
		and 
		c.conversationWithPortal = 1
		and
		m.[message] like case when @search is not null or @search <> '' then '%'+@search+'%' else m.[message] end
		
		order by m.saveDateTime desc
		OFFSET (@pageNo * 50 ) ROWS
		FETCH NEXT 50 ROWS ONLY;
RETURN 0