CREATE PROCEDURE [dbo].[SP_getEducationList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = null,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@userId as bigint
AS
	SET NOCOUNT ON
	
	select
		ed.id id,
		ISNULL(edr.title,ed.title) title
	from
	 TB_TYP_EDUCATION ed left join TB_TYP_EDUCATION_TRANSLATION edr on ed.id = edr.id and edr.lan = @clientLanguage

	
	
RETURN 0