CREATE PROCEDURE [dbo].[SP_termsAndConditions_getLastVersion]
	 @clientLanguage AS CHAR(2)
	,@clientIp AS VARCHAR(50)
	,@appId as tinyint

	,@version as money out
	,@title as varchar(50) out
	,@description as varchar(max) out
	,@saveDateTime_dsc as varchar(20) out


	,@rCode as tinyint out
	,@rMsg as nvarchar(max) out
AS
	


	set @rCode = 1;
	set @rMsg = 'success';

	select top(1)
	 @version = tc.pk_version
	,@title = ISNULL(tc_trn.title,tc.title)
	,@description = ISNULL(tc_trn.[description],tc.[description])
	,@saveDateTime_dsc = dbo.func_getDateByLanguage(@clientLanguage,tc.saveDateTime,1)
	from TB_TERMS_AND_CONDITIONS as tc
	left join TB_TERMS_AND_CONDITIONS_TRANSLATIONS as tc_trn on tc.pk_fk_app_id = tc_trn.pk_fk_app_id and tc.pk_version = tc_trn.pk_version and tc_trn.pk_lan = @clientLanguage
	where tc.pk_fk_app_id = @appId and tc.isActive = 1
	order by tc.pk_version desc