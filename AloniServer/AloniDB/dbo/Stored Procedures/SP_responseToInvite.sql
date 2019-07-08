CREATE PROCEDURE [dbo].[SP_responseToInvite]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@inviteId as bigint,
	@accept as bit
AS
	if((select fk_usr_id from TB_USR_STAFF where id = @inviteId) <> @userId)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'You do not have permission to do so!'); 
		set @rCode = 0
		return 0
	end
		update TB_USR_STAFF set fk_status_id = case when @accept = 1 then 8 else 7 end where id = @inviteId

		declare @requesterUserId bigint,@invetedPerson varchar(max),@storeId bigint,@managerId  bigint
		select @storeId = fk_store_id,@requesterUserId = save_fk_usr_id from TB_USR_STAFF where id = @inviteId
		set @managerId = (select top 1 fk_usr_id from TB_USR_STAFF where fk_staff_id = 11 and fk_status_id = 8 and fk_store_id = @storeId)
		set @invetedPerson = (select fname + ' ' + ISNULL(lname,'') from TB_USR where id = (select fk_usr_id from TB_USR_STAFF where id = @inviteId))
		DECLARE @RC int
		DECLARE @targetUserId bigint
		DECLARE @targetAppId tinyint
		DECLARE @targets [dbo].[UDT_pushNotiTargetType]
		DECLARE @content varchar(max)
		DECLARE @heading varchar(100)
		DECLARE @section varchar(20)
		DECLARE @action varchar(20)
		DECLARE @targetId varchar(20)
		DECLARE @par1 varchar(max)
		DECLARE @par2 varchar(max)
		DECLARE @par3 varchar(max)
		DECLARE @par4 varchar(max)
		DECLARE @sn_rCode tinyint
		DECLARE @sn_rMsg nvarchar(max);

		set @section = 'invite';
		set @action = 'response';
		set @targetUserId = @requesterUserId;
		set @targetAppId = 1;
		set @content = dbo.func_stringFormat_1( dbo.func_getSysMsg('invite_responce', OBJECT_NAME(@@PROCID), 'fa',case when @accept = 0 then 'دعوت  شما از  {0} توسط ایشان رد شد.' else 'دعوت  شما از  {0} توسط ایشان تایید شد.' END),@invetedPerson);
		set @heading = 'درخواست عضویت';
		set @targetId = @inviteId;
		set @par1 = @storeId;
		EXECUTE @RC = [dbo].[SP_SYS_sendPushNotification] 
			    @targetUserId
			   ,@targetAppId
			   ,@targets
			   ,@content
			   ,@heading
			   ,@section
			   ,@action
			   ,@targetId
			   ,@par1
			   ,@par2
			   ,@par3
			   ,@par4
			   ,@sn_rCode OUTPUT
			   ,@sn_rMsg OUTPUT
	if(@requesterUserId <> @managerId )
	begin
		set @targetUserId = @managerId;
		EXECUTE @RC = [dbo].[SP_SYS_sendPushNotification] 
			    @targetUserId
			   ,@targetAppId
			   ,@targets
			   ,@content
			   ,@heading
			   ,@section
			   ,@action
			   ,@targetId
			   ,@par1
			   ,@par2
			   ,@par3
			   ,@par4
			   ,@sn_rCode OUTPUT
			   ,@sn_rMsg OUTPUT
	end
		set @rCode = 1
		set @rMsg =  dbo.func_getSysMsg('done',OBJECT_NAME(@@PROCID),@clientLanguage,'success!'); 
RETURN 0
