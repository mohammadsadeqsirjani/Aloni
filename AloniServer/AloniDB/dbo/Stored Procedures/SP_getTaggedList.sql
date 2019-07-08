CREATE PROCEDURE [dbo].[SP_getTaggedList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = null,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@userId as bigint
AS
	set @pageNo = ISNULL(@pageNo,0)
	set nocount on
	
		select * into #temp from( 
		SELECT 
			s.id, s.title,s.address,ISNULL(TSR.title,TS.title) storeStatus,TS.id as stId
		from
			 TB_STORE_CUSTOMER as SC 
			 inner join TB_STORE as S on SC.pk_fk_store_id = s.id
			 inner join TB_STATUS as TS on s.fk_status_shiftStatus = TS.id
			 left join TB_STATUS_TRANSLATIONS as TSR on TS.id = TSR.id and TSR.lan = @clientLanguage
		where 
			SC.pk_fk_usr_cstmrId = @userId and SC.fk_status_id = 32
		order by s.id
		OFFSET (@pageNo * 10 ) ROWS
		FETCH NEXT 10 ROWS ONLY
		) as t
	select * from #temp
	select 
		s.id,
		d.completeLink,
		d.thumbcompeleteLink
	from
		 TB_STORE as s
		 inner join TB_DOCUMENT_STORE as DS on s.id = DS.pk_fk_store_id and DS.isDefault = 1
		 inner join TB_DOCUMENT as D on DS.pk_fk_document_id = d.id and d.fk_documentType_id = 5
	where
		s.id in(select id from #temp)
RETURN 0
