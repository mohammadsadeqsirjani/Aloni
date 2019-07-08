CREATE PROCEDURE [dbo].[SP_opinionpoll_comments_getList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@opinionPollId as bigint
	,@pageNo AS INT
	,@search AS NVARCHAR(100) = null
	,@parent AS VARCHAR(20)
AS



with avgOfScores as (select pk_fk_usr_id, avg(score) as [avg]
		from TB_STORE_ITEM_OPINIONPOLL_OPINIONS
		where fk_opinionPollId = @opinionPollId 
		group by pk_fk_usr_id,fk_opinionPollId)

	select
	cm.id,
		u.id as userId,
		ISNULL(u.fname,'') + ' ' +isnull(u.lname,'') as [name],
		cm.comment,
		ascr.avg as avgOfScores,
		dbo.func_getDateByLanguage(@clientLanguage,cm.saveDateTime,1) as [time],
		cm.edited,
		d1.thumbcompeleteLink as p1_thumbcompeleteLink,
		d1.completeLink as p1_completeLink,
		d2.thumbcompeleteLink as p2_thumbcompeleteLink,
		d2.completeLink as p2_completeLink,
		d3.thumbcompeleteLink as p3_thumbcompeleteLink,
		d3.completeLink as p3_completeLink,
		d4.thumbcompeleteLink as p4_thumbcompeleteLink,
		d4.completeLink as p4_completeLink,
		d5.thumbcompeleteLink as p5_thumbcompeleteLink,
		d5.completeLink as p5_completeLink,
		cn.id as userAndStoreConversationId
		from TB_STORE_ITEM_OPINIONPOLL_COMMENTS as cm with(nolock)
		join TB_USR as u with(nolock) on cm.fk_usr_commentUserId = u.id
		join TB_STORE_ITEM_OPINIONPOLL as opl on cm.fk_opinionpoll_id = opl.id
		--join TB_STORE as s on cm
		left join TB_DOCUMENT as d1 with(nolock) on cm.fk_document_doc1 = d1.id
		left join TB_DOCUMENT as d2 with(nolock) on cm.fk_document_doc2 = d2.id
		left join TB_DOCUMENT as d3 with(nolock) on cm.fk_document_doc3 = d3.id
		left join TB_DOCUMENT as d4 with(nolock) on cm.fk_document_doc4 = d4.id
		left join TB_DOCUMENT as d5 with(nolock) on cm.fk_document_doc5 = d5.id
		left join avgOfScores as ascr on cm.fk_usr_commentUserId = ascr.pk_fk_usr_id
		left join TB_CONVERSATION as cn on ((u.id = cn.fk_from and cn.fk_to = opl.fk_store_id) or (u.id = cn.fk_to and cn.fk_from = opl.fk_store_id)) and cn.conversationWithStore = 1
		where 
		(cm.fk_opinionpoll_id = @opinionPollId)
		 and 
		 (@search is null or cm.comment like '%' + @search + '%')
		 and 
		 (@parent is null or cm.fk_usr_commentUserId = cast(@parent as bigint))
		and
		(resultIsPublic <> 0  or (resultIsPublic = 0 and exists(select top 1 1 from TB_USR_STAFF SS where SS.fk_usr_id = @userId and fk_store_id = opl.fk_store_id and fk_staff_id in(11,12,13))))

		ORDER BY cm.id DESC OFFSET(@pageNo * 10) ROWS
