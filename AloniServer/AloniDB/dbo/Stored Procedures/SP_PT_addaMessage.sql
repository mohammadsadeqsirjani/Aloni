CREATE PROCEDURE [dbo].[SP_PT_addaMessage]
	@clientLanguage as char(2) = null,
	@appId as tinyint = null,
	@clientIp as varchar(50) = null,
	@userId as bigint = null,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@message as nvarchar(max),
	@fk_staff_destStaffId as smallint = 11,
	@fk_store_destStoreId as bigint ,
	@fk_usr_senderUser as bigint ,
	@fk_send_staff_id as smallint 
AS

set nocount on
begin try
-- check validation
	if(@message is null)
	begin
		set @rMsg = dbo.func_getSysMsg('error_invalid_message',OBJECT_NAME(@@PROCID),@clientLanguage,'پیغام معتبر نمی باشد.'); 
		set @rCode = 0
		return 0
	end
	
declare @date as datetime = GETDATE()
insert into TB_MESSAGE
([message],fk_staff_destStaffId,fk_store_destStoreId,fk_usr_senderUser,fk_staff_senderStaffId,saveDateTime)
 values(@message,@fk_staff_destStaffId,@fk_store_destStoreId,@fk_usr_senderUser,@fk_send_staff_id,@date)
 set @rCode = 1;
end try
begin catch
set @rMsg = dbo.func_getSysMsg('Error_unExpected',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
set @rCode = 0
end catch
RETURN 0
