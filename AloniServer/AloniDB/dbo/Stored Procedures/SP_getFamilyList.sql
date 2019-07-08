CREATE PROCEDURE [dbo].[SP_getFamilyList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = null,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@userId as bigint,
	@seeRequested as bit = 0
AS
		select 
			uf.id,
			d.completeLink,
			d.thumbcompeleteLink,
			case when UF.fk_usr_requester_usr_id = @userId then  u.fname + ISNULL(u.lname,'') when UF.fk_usr_id = @userId then (select fname + ' '+ lname from TB_USR where id = @userId)   end name,
			case when s.id != 46 then '--' else  case when uf.fk_usr_requester_usr_id = @userId then uf.title when uf.fk_usr_id = @userId then UF.reqTitle end end title ,
			ISNULL(st.title,s.title) status_,
			S.id stId, 
			case when uf.fk_usr_requester_usr_id = @userId then 1 when uf.fk_usr_id = @userId then 0 end isMine
		from TB_USR_FAMILY UF
		 inner join TB_STATUS S on uf.fk_status_id = s.id 
		 inner join TB_USR U on uf.fk_usr_id = u.id
		 left join TB_STATUS_TRANSLATIONS ST on s.id = ST.id and ST.lan = @clientLanguage
		 left join TB_DOCUMENT_USR DU on DU.pk_fk_usr_id = uf.fk_usr_id
		 left join TB_DOCUMENT D on du.pk_fk_document_id = D.id	
		where
			(UF.fk_usr_requester_usr_id = @userId or UF.fk_usr_id = @userId)
			and
			uf.fk_status_id != 47
		ORDER BY 
			creationDate DESC
	
RETURN 0