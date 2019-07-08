CREATE PROCEDURE [dbo].[SP_getStoreEmployeeList] @clientLanguage AS CHAR(2)
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

SELECT us.id
	,u.fname + ' ' + ISNULL(u.lname, '') [name]
	,u.mobile
	,store.title storeInfo
	,ISNULL(STT.title, st.title) semat_pishnahadi
	,ISNULL(STAR.title, STA.title) status_
FROM 
	TB_USR U WITH (NOLOCK)
	INNER JOIN TB_USR_STAFF US WITH (NOLOCK) ON u.id = US.fk_usr_id	AND US.fk_staff_id <> 11
	INNER JOIN TB_STORE store WITH (NOLOCK) ON us.fk_store_id = store.id
	INNER JOIN TB_STAFF ST WITH (NOLOCK) ON US.fk_staff_id = ST.id
	LEFT JOIN TB_STAFF_TRANSLATIONS STT WITH (NOLOCK) ON ST.id = STT.id	AND STT.lan = @clientLanguage
	INNER JOIN TB_STATUS STA WITH (NOLOCK) ON US.fk_status_id = STA.id
	LEFT JOIN TB_STATUS_TRANSLATIONS STAR WITH (NOLOCK) ON STA.id = STAR.id AND STAR.lan = @clientLanguage
WHERE 
	us.fk_store_id = @storeId
	AND 
	fk_usr_id <> @userId
	AND
	 us.fk_status_id not in (42,10,7)
	AND 
	u.fname LIKE CASE 
		WHEN @search IS NOT NULL
			AND @search <> ''
			THEN '%' + @search + '%'
		ELSE u.fname
		END
	AND 
	us.fk_status_id <> 10
ORDER BY
	 us.id
OFFSET(@pageNo * 10) ROWS
FETCH NEXT 10 ROWS ONLY;

RETURN 0
