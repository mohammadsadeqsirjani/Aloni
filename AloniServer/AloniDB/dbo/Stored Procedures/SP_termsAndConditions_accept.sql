CREATE PROCEDURE [dbo].[SP_termsAndConditions_accept]
	 @clientLanguage AS CHAR(2)
	,@clientIp AS VARCHAR(50)
	,@appId as tinyint
	,@userId as bigint
	,@sessionId AS BIGINT
	,@version as money
	,@rCode as tinyint out
	,@rMsg as nvarchar(max) out
	,@storeId as bigint
AS



if(@version is null)
begin
set @rMsg = dbo.func_getSysMsg('error_versionIdIsRequired',OBJECT_NAME(@@PROCID),@clientLanguage,'error: versionId as required.'); 
goto fail;
end
if(@appId <> 1)
begin
update TB_USR_SESSION
set tcVersion = @version
where id = @sessionId and fk_status_id = 4 and fk_app_id = @appId and fk_usr_id = @userId;


if(@@ROWCOUNT <> 1)
begin
set @rMsg = dbo.func_getSysMsg('error_invalidRequest',OBJECT_NAME(@@PROCID),@clientLanguage,'invalid request!'); 
goto fail;
end
end
else
begin
	if(@storeId is null)
	begin
	set @rMsg = dbo.func_getSysMsg('error_versionIdIsRequired',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه پنل وارد نشده است'); 
	goto fail;
	end
	if(dbo.func_GetUserStaffStore(@userId,@storeId) <> 11)
		begin
			set @rCode = 0
			set @rMsg = 'این عملیات برای شما مجاز نیست'
			return
	end
	if(exists (select top 1 1 from TB_TERMS_AND_CONDITIONS_ACCEPT where pk_fk_version = @version and pk_fk_app_id = @appId and fk_store_id = @storeId))
	begin	
		goto success
	end
	insert into TB_TERMS_AND_CONDITIONS_ACCEPT(pk_fk_app_id,pk_fk_version,fk_user_id,fk_store_id) select @appId,@version,@userId,@storeId
end

success:

SET @rCode = 1;
SET @rMsg = 'success.';

RETURN 0;

fail:

--ROLLBACK TRAN t1;

SET @rCode = 0;

RETURN 0;




