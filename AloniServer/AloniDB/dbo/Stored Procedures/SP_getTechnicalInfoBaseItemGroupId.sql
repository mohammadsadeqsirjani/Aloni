CREATE PROCEDURE [dbo].[SP_getTechnicalInfoBaseItemGroupId]
	 @clientLanguage AS CHAR(2)
	,@appId AS TINYINT
	,@clientIp AS VARCHAR(50)
	,@userId AS BIGINT
	,@pageNo AS INT = 0
	,@search AS NVARCHAR(100) = null
	,@parent AS NVARCHAR(100) = null
	,@id as bigint
AS
	Set nocount on
	select id,title,type from TB_TYP_TECHNICALINFO where fk_technicalinfo_page_id =(select fk_technicalinfo_page_id from TB_TYP_ITEM_GRP where id = @id) and type <> 5
RETURN 0
