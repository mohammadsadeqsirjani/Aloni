CREATE PROCEDURE [dbo].[SP_initApplication]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@sessionId AS BIGINT,

	@osType as tinyint,

	@inputAppVersion as varchar(60),
	@dbAppVersion as varchar(60),
	--@dbTermsAndConditions as money,




	@isNewVersion as bit out,
	@newVer_version as varchar(60) out,
	@newVer_releasNote as text out,
	@newVer_releaseDateTime_dsc as varchar(100) out,
	@enhancementIsMandatory as bit out,


	@isNewTermsAndConditions as bit out,
	@newTC_termsAndConditions as money out,
	@newTC_title as varchar(50) out,
	@newTC_description as text out,
	@newTC_saveDateTime_dsc as varchar(100) out,
	@downloadLink as nvarchar(500) out,

	@rCode AS TINYINT OUT,
	@rMsg AS NVARCHAR(max) OUT
AS
	SET NOCOUNT ON



	set @isNewVersion = 0;
	set @isNewTermsAndConditions = 0;
	set @enhancementIsMandatory = 0;

	
	SELECT top(1)
			 @isNewVersion = 1
			,@enhancementIsMandatory = case when exists(select 1 from TB_SYS_VERSION as csv WITH (NOLOCK) WHERE csv.pk_osType = @osType AND csv.pk_fk_app_Id = @appId AND csv.pk_version > @inputAppVersion and csv.isActive = 1 and csv.isCritical = 1 and GETDATE() >= csv.[start]) then 1 else 0 end
			,@newVer_version = sv.pk_version
			,@newVer_releasNote = ISNULL(sv_trn.releasNote, sv.releasNote)
			,@newVer_releaseDateTime_dsc = dbo.func_getDateByLanguage(@clientLanguage,sv.[start],1)
			,@downloadLink = sv.downloadLink
	FROM TB_SYS_VERSION as sv WITH (NOLOCK)
	left join TB_SYS_VERSION_TRANSLATIONS as sv_trn on sv.pk_osType = sv_trn.pk_osType and sv.pk_fk_app_Id = sv_trn.pk_fk_app_Id and sv.pk_version = sv_trn.pk_version and sv_trn.pk_lan = @clientLanguage
	WHERE sv.pk_osType = @osType
		AND sv.pk_fk_app_Id = @appId
		AND dbo.func_compare_versionCodes(sv.pk_version,@inputAppVersion) > 0 --AND sv.pk_version > @inputAppVersion
		AND GETDATE() > sv.[start]
		AND sv.isActive = 1
		order by sv.pk_version desc;





		select top(1)
		@isNewTermsAndConditions = 1
		,@newTC_termsAndConditions = tc.pk_version
		,@newTC_title = isnull(tc_trn.title,tc.title)
		,@newTC_description = ISNULL(tc_trn.[description],tc.[description])
		,@newTC_saveDateTime_dsc = dbo.func_getDateByLanguage(@clientLanguage,tc.saveDateTime,1)
		from TB_TERMS_AND_CONDITIONS as tc with(nolock)
		left join TB_TERMS_AND_CONDITIONS_TRANSLATIONS as tc_trn with(nolock) on tc.pk_fk_app_id = tc_trn.pk_fk_app_id and tc.pk_version = tc_trn.pk_version and tc_trn.pk_lan = @clientLanguage
		where tc.pk_fk_app_id = @appId and tc.isActive = 1
		and (@userId is null or tc.pk_version > (select max(us.tcVersion)
									 from TB_USR_SESSION as us with(nolock)
									   where us.fk_usr_id = @userId and us.fk_app_id = @appId ))
		order by tc.pk_version desc;


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






	if(@sessionId is not null and @inputAppVersion is not null and (@dbAppVersion is null or @dbAppVersion <> @inputAppVersion))
	begin
	   update TB_USR_SESSION set appVersion = @inputAppVersion where id = @sessionId;
	end

success:
SET @rCode = 1;
SET @rMsg = 'success.';
RETURN 0;
fail:
SET @rCode = 0;
RETURN 0;