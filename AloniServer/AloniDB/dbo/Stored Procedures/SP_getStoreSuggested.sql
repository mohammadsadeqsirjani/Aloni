CREATE PROCEDURE [dbo].[SP_getStoreSuggested]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint, 
	@pageNo as int = 0,
	@search as nvarchar(100) = null ,
	@parent as varchar(20) = null
AS
	SET NOCOUNT ON
	select distinct
	top 5 
		d.completeLink storeLogo,d.thumbcompeleteLink,s.id,s.title,s.title_second 
	from
		 TB_STORE s 
		 left join TB_DOCUMENT_STORE ds on s.id = ds.pk_fk_store_id 
		 left join TB_DOCUMENT d on ds.pk_fk_document_id = d.id and fk_documentType_id = 5
	where s.fk_status_id = 13 and s.fk_store_type_id = 1
RETURN 0
