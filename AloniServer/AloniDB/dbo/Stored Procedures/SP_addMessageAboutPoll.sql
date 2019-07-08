CREATE PROCEDURE [dbo].[SP_addMessageAboutPoll]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@message as text,
	@storeId as bigint,
	--@fk_usr_destUserId as bigint,
	@conversationAbout_ItemEvaluationId as bigint = NULL,
	@conversationAbout_ItemOppinionPollId as bigint = NULL,
	@conversationId as bigint = 0
AS

set nocount on
begin try

	declare @destId as bigint
	if(dbo.func_GetUserStaffStore(@userId,@storeId) <> 11)
	begin
		set @rMsg = dbo.func_getSysMsg('invalidAction',OBJECT_NAME(@@PROCID),@clientLanguage,'شما مجاز به ارسال پیام نیستید'); 
		set @rCode = 0
		return 0
	end
	if(@conversationAbout_ItemEvaluationId > 0 and @conversationAbout_ItemOppinionPollId > 0)
	begin
		set @rMsg = dbo.func_getSysMsg('invalidAction',OBJECT_NAME(@@PROCID),@clientLanguage,'لطفا یکی از حالت های ارزیابی و یا کامنت را انتخاب نمایید'); 
		set @rCode = 0
		return 0
	end
	if(@conversationAbout_ItemEvaluationId > 0 and not exists(select top 1 1 from TB_STORE_ITEM_EVALUATION where id = @conversationAbout_ItemEvaluationId and fk_store_id = @storeId))
	begin
		set @rMsg = dbo.func_getSysMsg('invalidAction',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه ارزیابی معتبر نیست'); 
		set @rCode = 0
		return 0
	end
	if(@conversationAbout_ItemOppinionPollId > 0 and not exists(select top 1 1 from TB_STORE_ITEM_OPINIONPOLL_COMMENTS ic,TB_STORE_ITEM_OPINIONPOLL op where ic.fk_opinionpoll_id = op.id and ic.id = @conversationAbout_ItemOppinionPollId and op.fk_store_id = @storeId))
	begin
		set @rMsg = dbo.func_getSysMsg('invalidAction',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه کامنت نظرسنجی معتبر نیست'); 
		set @rCode = 0
		return 0
	end
	--validation
	--if(@conversationId > 0)
	--begin
	--	select @destId = case when fk_from = @userId then fk_to when fk_to = @userId then fk_from end from TB_CONVERSATION where @conversationId = id
	--	if(not exists(select id from TB_CONVERSATION where (fk_from = @userId or fk_to = @userId) and id = @conversationId ))
	--	begin
	--		set @rMsg = dbo.func_getSysMsg('invalidConversationId',OBJECT_NAME(@@PROCID),@clientLanguage,'این گفتگو مربوط به شما نیست'); 
	--		set @rCode = 0
	--		return 0
	--	end
	--end
	if(@message is null)
	begin
		set @rMsg = dbo.func_getSysMsg('message_requierd',OBJECT_NAME(@@PROCID),@clientLanguage,'ورود متن پیام الزامی می باشد.'); 
		set @rCode = 0
		return 0
	end
	if(@conversationId = 0 and @storeId is not null and not exists(select id from TB_STORE where id= @storeId))
		begin
			set @rMsg = dbo.func_getSysMsg('error_invalid_storeId',OBJECT_NAME(@@PROCID),@clientLanguage,'کد فروشگاه وارد شده معتبر نمی باشد.'); 
			set @rCode = 0
			return 0
		end
	
	
	
    if(@conversationId = 0 and not exists(select top 1 1 from TB_CONVERSATION where fk_conversationAbout_ItemEvaluationId = @conversationAbout_ItemEvaluationId or fk_conversationAbout_opinionPollId = @conversationAbout_ItemOppinionPollId))
	begin
		 insert into TB_CONVERSATION(fk_from,fk_to,fk_conversationAbout_ItemEvaluationId,fk_conversationAbout_opinionPollId) values(@userId,@userId,case when @conversationAbout_ItemEvaluationId = 0 then NULL else @conversationAbout_ItemEvaluationId end,case when @conversationAbout_ItemOppinionPollId = 0 then NULL else @conversationAbout_ItemOppinionPollId end)
		 set @conversationId = SCOPE_IDENTITY()
		 set @rMsg =cast(@conversationId as varchar(10))
		 insert into TB_MESSAGE
		 ([message],fk_usr_destUserId,fk_store_destStoreId,fk_store_senderStoreId,fk_usr_senderUser,saveDateTime,fk_orderHdr_RelatedOrderId,displayAsTicket,messageAsStore,fk_conversation_id)
		 values(@message,NULL,NULL,NULL, @userId,GETDATE(),NULL,0,0,@conversationId)
	end
else
begin
	if(@conversationId = 0)
		declare @convId bigint= (select id from TB_CONVERSATION where fk_conversationAbout_ItemEvaluationId = @conversationAbout_ItemEvaluationId or fk_conversationAbout_opinionPollId = @conversationAbout_ItemOppinionPollId)
	if(@convId is null or @convId = 0 )
	begin
			set @rMsg = dbo.func_getSysMsg('error_invalid_storeId',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه گفتگو یافت نشد'); 
			set @rCode = 0
			return 0
	end
	insert into TB_MESSAGE
	       ([message],fk_usr_destUserId,fk_store_destStoreId,fk_store_senderStoreId,fk_usr_senderUser,saveDateTime,fk_orderHdr_RelatedOrderId,displayAsTicket,messageAsStore,fk_conversation_id)
			values(@message,NULL,NULL,NULL, @userId,GETDATE(),NULL,0,0,case when @conversationId > 0 then @conversationId else @convId END)

end
 set @rCode = 1;
 set @rMsg = 'success'
end try
begin catch
set @rMsg = dbo.func_getSysMsg('Error_unExpected',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
set @rCode = 0
end catch
RETURN 0

