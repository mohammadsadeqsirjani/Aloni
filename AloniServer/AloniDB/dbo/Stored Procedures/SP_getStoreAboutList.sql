CREATE PROCEDURE [dbo].[SP_getStoreAboutList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = null,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@userId as bigint,
	@storeId as bigint
AS
	set nocount on
	select 
		sa.id,SA.description,fk_language_id,l.title lanTitle,sa.title
	from
		TB_STORE_ABOUT SA
		inner join TB_LANGUAGE L on L.id = SA.fk_language_id
		
	where
		sa.fk_store_id = @storeId --and sa.fk_language_id = case when @appId = 2 then @clientLanguage end or @appId = 1
	order by sa.id
	OFFSET (@pageNo * 10) ROWS
	FETCH NEXT 10 ROWS ONLY;

	select 
		sa.id,D1.completeLink,D1.thumbcompeleteLink,d.isDefault,D1.id imageId
	from
		TB_STORE_ABOUT SA
		inner join TB_DOCUMENT_STORE_ABOUT D on sa.id = d.pk_fk_store_about_id
		inner join TB_DOCUMENT D1 on d.pk_fk_document_id = D1.id 
	
RETURN 0