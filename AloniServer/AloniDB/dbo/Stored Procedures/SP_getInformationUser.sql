-- =============================================
-- Author:		Faramarz Bayatzadeh
-- Create date: 1397 01 27
-- Description:	return 4 table of user data
-- =============================================
CREATE PROCEDURE [dbo].[SP_getInformationUser]
	@clientLanguage as char(2) = null,
	@appId as tinyint = null,
	@clientIp as varchar(50) = null,
	@userId as bigint
AS
BEGIN
	SET NOCOUNT ON;

	-- اطلاعات عمومی کاربر
	select 
    usr.id AS id,
    ISNULL(usr.fname, '') AS fname,
    ISNULL(usr.lname, '') AS lname,
    ISNULL(usr.mobile, '') AS mobile,
    usr.fk_country_id AS countryId,
    ISNULL(country.title, '') AS countryTitle,
    usr.fk_cityId AS cityId,
    ISNULL(city.title, '') AS cityTitle,
    usr.fk_introducer AS introducerId,
    ISNULL(introducer.fname, '') AS introducerTitle,
    usr.fk_language_id AS languageId,
    ISNULL(lang.title, '') AS languageTitle,
    usr.fk_status_id AS statusId,
    ISNULL(sta.title, '') AS statusTitle,
    ISNULL(CAST(dbo.func_udf_Gregorian_To_Persian_withTime(usr.saveTime) AS varchar(50)), '') AS saveTime,
    ISNULL(usr.saveIp, '') AS saveIp,
    ISNULL(usr.id_str, '') AS idStr
    from TB_USR AS usr WITH (NOLOCK)
    left join TB_COUNTRY AS country
    on usr.fk_country_id = country.id
    left join TB_CITY AS city
    on usr.fk_cityId = city.id
    left join TB_LANGUAGE AS lang
    on usr.fk_language_id = lang.id
    left join TB_USR AS introducer
    on usr.fk_introducer = introducer.id
    left join TB_STATUS As sta
    on usr.fk_status_id = sta.id
    where usr.id = @userId

	-- اطلاعات ورود و خروجی کاربر
	select 
    sessionUsr.id AS id,
    sessionUsr.fk_usr_id AS userId,
    ISNULL(usr.fname, '') AS userTitle,
    sessionUsr.fk_app_id AS appId,
    ISNULL(app.title, '') AS appTitle,
    sessionUsr.fk_status_id AS statusId,
    ISNULL(sta.title, '') AS statusTitle,
    ISNULL(sessionUsr.deviceInfo, '') AS deviceInfo,
    ISNULL(CAST(dbo.func_udf_Gregorian_To_Persian_withTime(sessionUsr.lastActivityTime) AS varchar(50)), '') AS lastActivityTime,
    ISNULL(sessionUsr.otpCode, '') AS otpCode,
    ISNULL(sessionUsr.loginIp, '') AS loginIp,
    ISNULL(sessionUsr.currentIp, '') AS currentIp,
    ISNULL(sessionUsr.deviceId, '') AS deviceId,
    ISNULL(sessionUsr.deviceId_appDefined, '') AS deviceId_appDefined,
    ISNULL(CAST(sessionUsr.osType AS varchar(10)), '') AS osType,
    sessionUsr.loc AS loc,
    ISNULL(CAST(dbo.func_udf_Gregorian_To_Persian_withTime(sessionUsr.loc_updTime) AS varchar(50)), '') AS loc_updTime,
    ISNULL(CAST(sessionUsr.appVersion AS varchar(50)), '') AS appVersion,
    ISNULL(sessionUsr.salt, '') AS salt
    from TB_USR_SESSION AS sessionUsr WITH (NOLOCK)
    left join TB_USR AS usr
    on sessionUsr.fk_usr_id = usr.id
    left join TB_APP AS app
    on sessionUsr.fk_app_id = app.id
    left join TB_STATUS AS sta
    on sessionUsr.fk_status_id = sta.id
    where sessionUsr.fk_usr_id = @userId

	-- اطلاعات مربوط به سمت و فروشگاه کاربر
	select 
    usrStaff.id AS id,
    usrStaff.fk_usr_id AS userId,
    ISNULL(usr.fname, '') AS userTitle,
    usrStaff.fk_staff_id AS staffId,
    ISNULL(staff.title, '') AS staffTitle,
    usrStaff.fk_store_id AS storeId,
    ISNULL(store.title, '') AS storeTitle,
    usrStaff.fk_status_id AS statusId,
    ISNULL(sta.title, '') AS statusTitle,
    usrStaff.save_fk_usr_id AS saveUserId,
    ISNULL(saveUsr.fname, '') AS saveUserTitle,
    ISNULL(CAST(dbo.func_udf_Gregorian_To_Persian_withTime(usrStaff.saveTime) AS varchar(50)), '') AS saveTime
    from TB_USR_STAFF AS usrStaff WITH (NOLOCK)
    left join TB_USR AS usr
    on usrStaff.fk_usr_id = usr.id
    left join TB_STAff AS staff
    on usrStaff.fk_staff_id = staff.id
    left join TB_STORE AS store
    on usrStaff.fk_store_id = store.id
    left join TB_STATUS AS sta
    on usrStaff.fk_status_id = sta.id
    left join TB_USR AS saveUsr
    on usrStaff.save_fk_usr_id = saveUsr.id
    where usrStaff.fk_usr_id = @userId

	-- اطلاعات فامیلی کاربر
	select 
    usrFamily.id AS id,
    ISNULL(usrFamily.title, '') AS title,
    usrFamily.fk_usr_id AS userId,
    ISNULL(usr.fname, '') AS userTitle,
    usrFamily.fk_usr_requester_usr_id AS requesterUserId,
    ISNULL(requesterUsr.fname, '') AS requesterUserTitle,
    usrFamily.fk_status_id AS statusId,
    ISNULL(sta.title, '') AS statusTitle,
    ISNULL(CAST(dbo.func_udf_Gregorian_To_Persian_withTime(usrFamily.saveDateTime) AS varchar(50)), '') AS saveDateTime,
    ISNULL(CAST(dbo.func_udf_Gregorian_To_Persian_withTime(usrFamily.modifyDatetime) AS varchar(50)), '') AS modifyDatetime
    from TB_USR_FAMILY AS usrFamily WITH (NOLOCK)
    left join TB_USR AS usr
    on usrFamily.fk_usr_id = usr.id
    left join TB_USR AS requesterUsr
    on usrFamily.fk_usr_requester_usr_id = requesterUsr.id
    left join TB_STATUS AS sta
    on usrFamily.fk_status_id = sta.id
    where usrFamily.fk_usr_id = @userId

END