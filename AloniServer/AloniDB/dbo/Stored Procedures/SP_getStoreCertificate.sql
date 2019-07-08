CREATE PROCEDURE [dbo].[SP_getStoreCertificate]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100)=null,
	@parent as varchar(20) = null ,
	@userId as bigint,
	@storeId as bigint
	
AS
	set nocount on;

	select 
		c.id,c.title,c.dsc,ISNULL(SR.title,ST.title) status_,st.id statusId
	from 
		TB_STORE S
		inner join TB_STORE_CERTIFICATE C on s.id = c.fk_store_id
		left join TB_STATUS ST on c.fk_status_id = ST.id
		left join TB_STATUS_TRANSLATIONS SR on ST.id = SR.id and SR.lan = @clientLanguage
	where 
		s.id =  @storeId
	
	select 
		c.id,d.id guid_,d.thumbcompeleteLink,d.completeLink
	from 
		TB_STORE S
		inner join TB_STORE_CERTIFICATE C on s.id = c.fk_store_id
		inner join TB_DOCUMENT_STORE_CERTIFICATE DS on c.id = DS.pk_fk_store_certificate_id
		inner join TB_DOCUMENT D on ds.pk_fk_document_id = D.id
	where 
		s.id = @storeId;
RETURN 0
