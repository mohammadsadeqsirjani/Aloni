CREATE PROCEDURE [dbo].[SP_getCommentMessageListConversation]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20) = null,
	@userId as bigint,
	@evalId as bigint = 0,
	@commentId as bigint = 0
AS
	SET NOCOUNT ON
	set @pageNo = ISNULL(@pageNo,0)

		select 
			m.id,
			dbo.func_getDateByLanguage(@clientLanguage,m.saveDateTime,1) saveDate,
		    substring(cast((cast(m.saveDateTime as time)) as varchar(50)),0,6)  saveTime,
			m.message,
			dbo.func_getDateByLanguage(@clientLanguage,m.seenDateTime,1) seenDate,
			substring(cast((CAST(m.seenDateTime as time))  as varchar(50)),0,6) seenTime,
			case when m.fk_usr_senderUser = @userId then 1 else 0 end isMine,
			u.fname + ' '+ISNULL(u.lname,'') senderName
			
		from 
			TB_MESSAGE m 
			inner join tb_conversation C on m.fk_conversation_id = c.id
			left join TB_USR U on m.fk_usr_senderUser = u.id
			
			
		where
			(c.fk_conversationAbout_ItemEvaluationId = @evalId or @evalId = 0 or @evalId is null)
			AND
			(c.fk_conversationAbout_opinionPollId = @commentId or @commentId = 0 or @commentId is null)
			
			and
			 m.[message] like case when @search is not null or @search <> '' then '%'+@search+'%' else m.[message] end
		
		order by m.saveDateTime desc
		OFFSET (@pageNo * 50 ) ROWS
		FETCH NEXT 50 ROWS ONLY;
	



RETURN 0
