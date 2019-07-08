CREATE PROCEDURE [dbo].[SP_checkValidationCode]

	@clientLanguage as char(2),
	@sessionId as bigint,
    --@mobile VARCHAR(20),
    @appId as tinyint,
	@otpCode as char(5),
	@clientIp as varchar(50),
	--@mobile as varchar(20),
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out
AS

declare @userId as bigint,@userSessionId as bigint;--,@sendTime as datetime


if(not exists (select 1 from TB_USR_SESSION with(nolock) where id = @sessionId and otpCode IS NOT NULL and  otpCode = @otpCode and fk_app_id = @appId ))
begin
set @rMsg = dbo.func_getSysMsg('fail',OBJECT_NAME(@@PROCID),@clientLanguage,'کد وارد شده صحیح نمی باشد.');
goto fail;
end

	  success:
	  set @rCode = 1;
	  set @rMsg = dbo.func_getSysMsg('success',OBJECT_NAME(@@PROCID),@clientLanguage,'کد صحیح است.');
	  return 0;
	  fail:
	  set @rCode = 0;
	  return 0;