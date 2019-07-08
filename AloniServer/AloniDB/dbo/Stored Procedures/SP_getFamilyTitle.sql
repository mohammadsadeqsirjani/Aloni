CREATE PROCEDURE [dbo].[SP_getFamilyTitle]
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
		A.id ,isnull(B.title,A.title) title 
	from 
		  TB_FAMILY_TITLE A 
		left join 
		  TB_FAMILY_TITLE_TRANSLATION B on A.id = B.Id and b.lan = @clientLanguage
	
	
RETURN 0
