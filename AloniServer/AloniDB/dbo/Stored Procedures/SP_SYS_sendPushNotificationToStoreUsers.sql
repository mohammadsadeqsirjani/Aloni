CREATE PROCEDURE [dbo].[SP_SYS_sendPushNotificationToStoreUsers]
 	@targetStoreId as bigint
	,@targetStoreIds as [dbo].[LongType] readonly
	,@funcId as varchar(100)
	,@content as varchar(max)
	,@heading as varchar(100) = null
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

declare @_targetStoreIds as [dbo].[LongType],@targetUsers as [dbo].[UDT_pushNotiTargetType];
insert into @_targetStoreIds select * from @targetStoreIds;


if(@targetStoreId is not null)
begin
insert into @_targetStoreIds (id) values (@targetStoreId);
end



insert into @targetUsers
select us.fk_usr_id,1
from 
@_targetStoreIds as ts
join 
TB_USR_STAFF as us
on us.fk_store_id = ts.id and us.fk_status_id = 8
join
TB_APP_FUNC_USR as afu
on ((us.fk_usr_id = afu.fk_usr_id) or (us.fk_staff_id = afu.fk_staff_id)) and afu.hasAccess = 1 and afu.fk_func_id = @funcId
join TB_USR as u
on us.fk_usr_id = u.id and u.fk_status_id = 1
--join TB_STORE 




--declare @address as varchar(255),@authorization as varchar(100),@appid as varchar(100),@playerIds as varchar(max);
--set @address = 'https://onesignal.com/api/v1/notifications';
--set @authorization = 'Basic N2U3NWFhNDItYjFlMC00NWM4LTkwYzgtOTM1ZDY5YWRjNTVl';
--set @appid = '0b0308d0-d613-4af8-ad3d-213d28abb01e';

--Select @playerIds =
--    substring(
--        (
--            Select ',"'+ us.pushNotiId + '"'  as [text()]
--            From TB_USR_SESSION as us
--			join @targetUsers as tu
--			on us.fk_usr_id = tu.id and us.fk_app_id = 1
--			--where fk_usr_id = @targetUserId
--			--and fk_app_id = @targetAppId
--			where us.fk_status_id = 4
--            ORDER BY us.id
--            For XML PATH ('')
--        ), 2, 2147483647);

--declare @sendResult as varchar(max);
--set @sendResult = dbo.func_sendPushNotification(@address,@authorization,@appid,@playerIds,isnull(@section,''),isnull(@action,''),isnull(@targetId,''),isnull(@par1,''),isnull(@par2,''),isnull(@heading,''),isnull(@content,''));


--DECLARE @RC int;
--DECLARE @targetUserIds [dbo].[UDT_pushNotiTargetType];
--insert into @targetUsers select id,1 from @targetUsers;

EXECUTE [dbo].[SP_SYS_sendPushNotification] 
   null
  ,null
  ,@targetUsers
  ,@content
  ,@heading
  ,@section
  ,@action
  ,@targetId
  ,@par1
  ,@par2
  ,@par3
  ,@par4
  ,@rCode OUTPUT
  ,@rMsg OUTPUT








--set @rCode = 1;
--set @rMsg = 'sent';






----usage:
--DECLARE @RC int
--DECLARE @targetStoreId bigint
--DECLARE @targetStoreIds [dbo].[LongType]
--DECLARE @funcId varchar(100)
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
--set @targetStoreId = 9;
--set @funcId = 'MARKETER_NOTI_ORDER_NEW';
--set @content = 'body test';
--set @heading = 'heading test';

--EXECUTE @RC = [dbo].[SP_SYS_sendPushNotificationToStoreUsers] 
--   @targetStoreId
--  ,@targetStoreIds
--  ,@funcId
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
--GO


