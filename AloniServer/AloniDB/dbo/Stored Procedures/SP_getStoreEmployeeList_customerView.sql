CREATE PROCEDURE [dbo].[SP_getStoreEmployeeList_customerView] @clientLanguage AS CHAR(2)
	,@appId AS TINYINT
	,@clientIp AS VARCHAR(50)
	,@userId AS BIGINT
	,@pageNo AS INT = 0
	,@search AS NVARCHAR(100) = NULL
	,@parent AS VARCHAR(20) = NULL
	,@storeId AS BIGINT
AS
SET NOCOUNT ON
SET @pageNo = ISNULL(@pageNo, 0)

SELECT se.id
	,se.fullname AS [name]
	,se.mobile
	,se.staff
	,se.[description]
	,d.completeLink
	,d.thumbcompeleteLink
FROM TB_STORE_EMPLOYEE SE
LEFT JOIN TB_DOCUMENT D ON se.fk_document_id = d.id
WHERE SE.fk_store_id = @storeId
	AND se.fullname LIKE CASE 
		WHEN @search IS NOT NULL
			AND @search <> ''
			THEN '%' + @search + '%'
		ELSE se.fullname
		END
ORDER BY se.id OFFSET(@pageNo * 10) ROWS

FETCH NEXT 10 ROWS ONLY;

RETURN 0
