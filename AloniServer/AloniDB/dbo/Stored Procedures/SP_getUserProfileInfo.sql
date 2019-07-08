CREATE PROCEDURE [dbo].[SP_getUserProfileInfo]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = null,
	@search as nvarchar(100)=null,
	@parent as varchar(20) = null ,
	@userId as bigint

AS
	SET NOCOUNT ON
	SELECT 
		ISNULL(u.fname,'') + ' ' + ISNULL(U.lname,'') NAME,
		U.mobile,
		C.id COUNTRYID,
		C.title COUNTRYNAME,
		CI.id CITYID,
		CI.title CITYNAME,
		S.ID PROVINCEID,
		S.title PROVINCENAME
	FROM
		TB_USR U
		LEFT JOIN TB_COUNTRY C ON U.fk_country_id = C.id 
		LEFT JOIN TB_CITY CI ON U.fk_cityId = CI.id
		LEFT JOIN TB_STATE S ON CI.fk_state_id = S.id
	where
		U.id = @userId

	 
RETURN 0
