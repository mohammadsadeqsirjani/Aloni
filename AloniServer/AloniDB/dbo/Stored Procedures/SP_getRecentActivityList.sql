CREATE PROCEDURE [dbo].[SP_getRecentActivityList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@pageNo as int = null,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null
as
	SET NOCOUNT ON
	set @pageNo = ISNULL(@pageNo,0)
	select
		l.fk_sent_usr_id,
		case when fk_event_id = 1 then REPLACE(replace(isnull(er.title,e.title),'{0}',u.fname+' '+isnull(u.lname,'')),'{1}',s.title)
			 when fk_event_id = 2 then REPLACE(replace(isnull(er.title,e.title),'{0}',s.title),'{1}',i.title)  end title,
		dd.completeLink,dd.thumbcompeleteLink,dbo.func_calcActionOrderTime(@clientLanguage,l.saveDateTime) datetime_,s.id
	from 
		TB_USR_LOG L inner join TB_EVENT E on L.fk_event_id = e.id left join TB_EVENT_TRANSLATION ER on e.id = ER.id and er.lan = @clientLanguage
		left join TB_USR U on L.fk_sent_usr_id = u.id
		left join tb_usr U1 on l.fk_dst_user_id = u1.id 
		left join TB_STORE S on S.id = l.fk_store_id
		left join TB_ITEM I on i.id = L.fk_item_id
		left join TB_DOCUMENT_ITEM D on i.id = d.pk_fk_item_id and d.isDefault = 1
		left join TB_DOCUMENT DD on D.pk_fk_document_id = DD.id --and dd.fk_documentType_id = 5  -- logo store
	
	where l.fk_dst_user_id = @userId or l.fk_sent_usr_id = @userId 
	order by l.saveDateTime desc
	OFFSET (@pageNo * 10) ROWS
	FETCH NEXT 10 ROWS ONLY;
RETURN 0
