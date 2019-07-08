CREATE PROCEDURE [dbo].[SP_deleteInvite]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@inviteId as bigint
AS
	declare @storeId bigint = (select fk_store_id from TB_USR_STAFF where id = @inviteId)
	if((select fk_staff_id from TB_USR_STAFF where fk_store_id = @storeId and fk_usr_id = @userId) <> 11 )
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@PROCID),@clientLanguage,'شما مجاز به انجام این عملیات نیستید'); 
		return
	end
		if((select fk_usr_id from TB_USR_STAFF where id = @inviteId) = @userId )
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@PROCID),@clientLanguage,'you are not have permission for this action!'); 
		return
	end
	declare @statusId as int = (select fk_status_id from TB_USR_STAFF where id = @inviteId )
	if(@statusId = 6) -- change state to cancelInvitation
	begin
		update TB_USR_STAFF set fk_status_id = 42 where id=@inviteId
		set @rCode = 1
		set @rMsg = dbo.func_getSysMsg('done',OBJECT_NAME(@@PROCID),@clientLanguage,'success!'); 
		return
	end
	if(@statusId = 8) -- change state to fired
	begin
		update TB_USR_STAFF set fk_status_id = 10 where id=@inviteId
		set @rCode = 1
		set @rMsg = dbo.func_getSysMsg('done',OBJECT_NAME(@@PROCID),@clientLanguage,'success!'); 
		return
	end

RETURN 0
