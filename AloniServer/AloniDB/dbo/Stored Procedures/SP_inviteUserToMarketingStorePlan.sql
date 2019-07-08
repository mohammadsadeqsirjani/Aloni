CREATE PROCEDURE [dbo].[SP_inviteUserToMarketingStorePlan]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@userMobile as varchar(20),
	@storeId as bigint
	
AS
	declare @storePlanId bigint= (select id from TB_STORE_MARKETING where fk_store_id = @storeId and fk_status_id = 48)
	declare @dstUserId as bigint = (select id from TB_USR where mobile = @userMobile)
	if(@dstUserId is null)
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('invalid request',OBJECT_NAME(@@PROCID),@clientLanguage,'user not found.!')
		return
	end
	if(@storePlanId is null)
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('invalid request',OBJECT_NAME(@@PROCID),@clientLanguage,'store have not active marketing plan')
		return
	end
	if(exists(select id from TB_STORE_MARKETING_MEMBER where @storePlanId = fk_store_marketing_id and (fk_usr_id = @dstUserId or fk_parent_usr_id = @dstUserId)))
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('invalid request',OBJECT_NAME(@@PROCID),@clientLanguage,'The user you are already a member of the marketing plan for this store.!')
		return
	end
	if(not exists(select id from TB_USR_STAFF where fk_store_id = @storeId and fk_usr_id = @userId))
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('invalid request',OBJECT_NAME(@@PROCID),@clientLanguage,'invalid request')
		return
	end
	begin try
		 insert into TB_USR_LOG(fk_event_id,fk_store_id,fk_sent_usr_id,fk_dst_user_id) values (1,@storeId,@userId,@dstUserId)
		 set @rCode = 1
		 set @rMsg = 'ok'		
	end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
	end catch
RETURN 0
