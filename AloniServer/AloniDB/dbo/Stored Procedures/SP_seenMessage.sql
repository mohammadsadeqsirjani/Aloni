CREATE PROCEDURE [dbo].[SP_seenMessage]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@messageId as bigint,
	@conversationId as bigint,
	@orderId as bigint = 0
AS
set nocount on
begin try
if(@orderId = 0)
begin

	declare @targetId as bigint = (select case when fk_from = @userId then fk_to else fk_from end from TB_CONVERSATION where id = @conversationId)
	if(@targetId is null)
	begin
		set @rMsg = dbo.func_getSysMsg('Error_unExpected',OBJECT_NAME(@@PROCID),@clientLanguage,'گفتگو مربوط به شما نیست')
		set @rCode = 0
		return
	end
	if(not exists(select top 1 1 from TB_MESSAGE where fk_conversation_id = @conversationId and id= @messageId))
	begin
		set @rMsg = dbo.func_getSysMsg('Error_unExpected',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه پیام مربوط به گفتگوی شما نیست')
		set @rCode = 0
		return
	end
	update TB_MESSAGE set seenDateTime = GETDATE() where id <= @messageId and fk_conversation_id = @conversationId and (fk_usr_destUserId = @targetId or fk_store_destStoreId = @targetId)
end
else
begin
	if(not exists(select top 1 1 from TB_ORDER_CORRESPONDENCE where fk_order_orderId = @orderId and id= @messageId))
	begin
		set @rMsg = dbo.func_getSysMsg('Error_unExpected',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه پیام مربوط به سفارش مد نظر شما نیست')
		set @rCode = 0
		return
	end
	update TB_ORDER_CORRESPONDENCE set controlDateTime = GETDATE() where fk_order_orderId = @orderId and id <= @messageId
end
	set @rCode = 1;
	set @rMsg = 'success'
end try
begin catch
set @rMsg = dbo.func_getSysMsg('Error_unExpected',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
set @rCode = 0
end catch
RETURN 0
