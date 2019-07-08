CREATE PROCEDURE [dbo].[SP_typeStoreReportTypeGetList]
 @clientLanguage AS CHAR(2)
	,@appId AS TINYINT
	,@clientIp AS VARCHAR(50)
	,@id AS VARCHAR(25) = NULL
	,@pageNo AS INT
	,@search AS NVARCHAR(100)
	,@parent AS VARCHAR(20)
	,@userId AS BIGINT = NULL
AS
SELECT id
	,title
	,usageInfo
FROM TB_TYP_STORE_REPORT_TYPE WITH (NOLOCK)
WHERE (
		@id IS NULL
		OR @id = ''
		OR id = CAST(@id AS BIGINT)
		)
	AND (
		@search IS NULL
		OR @search = ''
		OR title LIKE '%' + @search + '%'
		)
	--and ((@parent is null or @parent = '') or (@fk_state_id = CAST(@parent as int)))
	AND isActive = 1
ORDER BY Id OFFSET(@pageNo * 10) ROWS

FETCH NEXT 10 ROWS ONLY;