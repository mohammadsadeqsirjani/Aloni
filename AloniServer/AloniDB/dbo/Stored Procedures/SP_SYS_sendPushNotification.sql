CREATE PROCEDURE [dbo].[SP_SYS_sendPushNotification]
	 @targetUserId as bigint
	,@targetAppId as tinyint
 	,@targets as [dbo].[UDT_pushNotiTargetType] readonly
	,@content as varchar(max)
	--,@pushNotificationId as varchar(50) = null
	,@heading as varchar(100) = 'Aloni'
	,@section as varchar(50) = null
	,@action as varchar(20) = null
	,@targetId as varchar(20) = null
	,@par1 as varchar(max) = null
	,@par2 as varchar(max) = null
	,@par3 as varchar(max) = null
	,@par4 as varchar(max) = null
	,@rCode as tinyint out
	,@rMsg as nvarchar(max) out
AS

declare @proxy_host as varchar(255),
 @proxy_port as int,
  @proxy_username as varchar(50),
  @proxy_password as varchar(50);

  --set @proxy_host = 'nrayvarz.ir';
  --set @proxy_port = 8585;
  --set @proxy_username = 'rayvarz';
  --set @proxy_password = 'rayvarz';








declare @t as [dbo].[UDT_pushNotiTargetType];
insert into @t select * from @targets;


if(@targetUserId is not null and @targetAppId is not null)
begin
insert into @t (targetUserId,targetAppId) values (@targetUserId,@targetAppId);
end


--declare @address as varchar(255),@authorization as varchar(100),@appid as varchar(100),@playerIds as varchar(max);
--set @address = 'https://onesignal.com/api/v1/notifications';
--set @authorization = 'Basic N2U3NWFhNDItYjFlMC00NWM4LTkwYzgtOTM1ZDY5YWRjNTVl';
--set @appid = '0b0308d0-d613-4af8-ad3d-213d28abb01e';


--Select @playerIds =
--    substring(
--        (
--            Select ',"'+ us.pushNotiId + '"'  as [text()]
--            From TB_USR_SESSION as us
--			join @t as ts
--			on us.fk_usr_id = ts.targetUserId and us.fk_app_id = ts.targetAppId
--			--where fk_usr_id = @targetUserId
--			--and fk_app_id = @targetAppId
--			where us.fk_status_id = 4
--            ORDER BY us.id
--            For XML PATH ('')
--        ), 2, 2147483647);

--declare @sendResult as varchar(max);
--set @sendResult = dbo.func_sendPushNotification(@address,@authorization,@appid,@playerIds,isnull(@section,''),isnull(@action,''),isnull(@targetId,''),isnull(@par1,''),isnull(@par2,''),isnull(@heading,''),isnull(@content,''));


declare @c_targetUserId as bigint,
	 @c_targetAppId as tinyint;

	 declare @c_pushNotiId as varchar(250),@c_pushNotiProvider as tinyint,@c_fk_language_id as char(2),@c_osType as tinyint;
	 declare @address as varchar(255),@authorization as varchar(100),@appid as varchar(100);

declare cr cursor
for select targetUserId,targetAppId from @t;
open cr;
fetch next from cr into @c_targetUserId,@c_targetAppId;

while @@FETCH_STATUS = 0
begin

declare crr cursor
for select us.pushNotiId,us.pushNotiProvider,us.fk_language_id,us.osType
from TB_USR_SESSION as us
where us.fk_usr_id = @c_targetUserId and us.fk_app_id = @c_targetAppId and us.fk_status_id = 4 and us.pushNotiId is not null and us.pushNotiProvider is not null

open crr
fetch next from crr into @c_pushNotiId,@c_pushNotiProvider,@c_fk_language_id,@c_osType
while @@FETCH_STATUS = 0
begin

set @address = case when @c_pushNotiProvider = 1 then '' when @c_pushNotiProvider = 2 then 'https://fcm.googleapis.com/fcm/send' when @c_pushNotiProvider = 3 then 'https://onesignal.com/api/v1/notifications' else '' end;
if @c_osType = 1
begin--android
set @authorization = case when @c_pushNotiProvider = 1 then '' when @c_pushNotiProvider = 2 then 'key=AIzaSyCiwnfqf_-Sfs1oXU134fTnLnNcPsjXP9M' when @c_pushNotiProvider = 3 then 'Basic N2U3NWFhNDItYjFlMC00NWM4LTkwYzgtOTM1ZDY5YWRjNTVl' else '' end;
set @appid = case when @c_pushNotiProvider = 1 then '' when @c_pushNotiProvider = 2 then '' when @c_pushNotiProvider = 3 then '0b0308d0-d613-4af8-ad3d-213d28abb01e' else '' end;
end
else if @c_osType = 2
begin--IOS
set @authorization = case when @c_pushNotiProvider = 1 then '' when @c_pushNotiProvider = 2 then 'key=AIzaSyAzlUBfPAlPfoOq_lm0QLDfvh1bpotRLS4' when @c_pushNotiProvider = 3 then '' else '' end;
set @appid = case when @c_pushNotiProvider = 1 then '' when @c_pushNotiProvider = 2 then '' when @c_pushNotiProvider = 3 then '' else '' end;
end

--call send function
select dbo.func_sendPushNotification(@address,
        @authorization,
        isnull(@appid,''),
        @c_pushNotiId,
        isnull(@section,''),isnull(@action,''),isnull(@targetId,''),isnull(@par1,''),isnull(@par2,''),isnull(@par3,''),isnull(@par4,''),isnull(@heading,''),isnull(@content,''),
        @c_pushNotiProvider,
        @proxy_host,
        @proxy_port,
        @proxy_username,
        @proxy_password,
        @c_osType);




fetch next from crr into @c_pushNotiId,@c_pushNotiProvider,@c_fk_language_id,@c_osType
end
close crr;
deallocate crr;


fetch next from cr into @c_targetUserId,@c_targetAppId;
end

close cr;
deallocate cr;










set @rCode = 1;
set @rMsg = 'sent';






----usage:
--DECLARE @RC int
--DECLARE @targetUserId bigint
--DECLARE @targetAppId tinyint
--DECLARE @targets [dbo].[UDT_pushNotiTargetType]
--DECLARE @content varchar(max)
--DECLARE @heading varchar(100)
--DECLARE @section varchar(20)
--DECLARE @action varchar(20)
--DECLARE @targetId varchar(20)
--DECLARE @par1 varchar(max)
--DECLARE @par2 varchar(max)
--DECLARE @rCode tinyint
--DECLARE @rMsg nvarchar(max)

---- TODO: Set parameter values here.
--set @targetUserId = 20101;
--set @targetAppId = 2;
--set @content = 'سل"ام';
--set @heading = 'تست"سس';

--EXECUTE @RC = [dbo].[SP_SYS_sendPushNotification] 
--   @targetUserId
--  ,@targetAppId
--  ,@targets
--  ,@content
--  ,@heading
--  ,@section
--  ,@action
--  ,@targetId
--  ,@par1
--  ,@par2
--  ,@rCode OUTPUT
--  ,@rMsg OUTPUT

--  print @rMsg


