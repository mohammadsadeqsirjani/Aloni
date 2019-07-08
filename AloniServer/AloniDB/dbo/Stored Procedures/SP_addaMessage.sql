CREATE PROCEDURE [dbo].[SP_addaMessage]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@message as text,
	@storeId as bigint,
	@fk_usr_destUserId as bigint,
	@fk_store_destStoreId as bigint,
	@fk_orderHdr_RelatedOrderId as bigint,
	@displayAsTicket as bit,
	@conversationWithStore as bit,
	@conversationWithPortal as bit = 0,
	@conversationAbout_ItemId as bigint = 0,
	@conversationAbout_oppinionId as bigint = 0,
	@messageAsStore as bit,
	@conversationId as bigint = 0
AS

set nocount on
begin try

	declare @destId as bigint
	declare @id bigint=  case when @storeId is not null and @conversationWithPortal = 0 then @storeId else @userId end
	select @destId = case when fk_from = @id then fk_to when fk_to = @id then fk_from end from TB_CONVERSATION where @conversationId = id
	--validation
	if(@conversationId > 0)
	begin
		
	
		if(not exists(select id from TB_CONVERSATION where (fk_from = @id or fk_to = @id) and id = @conversationId ) and @appId <> 3 and @conversationWithPortal = 0)
		begin
			set @rMsg = dbo.func_getSysMsg('invalidConversationId',OBJECT_NAME(@@PROCID),@clientLanguage,'اين گفتگو مربوط به شما نيست'); 
			set @rCode = 0
			return 0
		end
	end
	if(@message is null)
	begin
		set @rMsg = dbo.func_getSysMsg('message_requierd',OBJECT_NAME(@@PROCID),@clientLanguage,'ورود متن پيام الزامي مي باشد.'); 
		set @rCode = 0
		return 0
	end
	if(@conversationId = 0 and @storeId is not null and not exists(select id from TB_STORE where id= @storeId))
		begin
			set @rMsg = dbo.func_getSysMsg('error_invalid_storeId',OBJECT_NAME(@@PROCID),@clientLanguage,'کد فروشگاه وارد شده معتبر نمي باشد.'); 
			set @rCode = 0
			return 0
		end
	if( (@conversationId = 0 and @fk_usr_destUserId is not null and  not exists(select id from TB_USR U where u.id = @fk_usr_destUserId )))
		begin
			set @rMsg = dbo.func_getSysMsg('error_invalid_destUserId',OBJECT_NAME(@@PROCID),@clientLanguage,'کد کاربر مقصد معتبر نمي باشد.'); 
			set @rCode = 0
			return 0
		end
	if(@conversationAbout_ItemId  is not null and @conversationAbout_ItemId > 0 and not exists(select top 1 1 from TB_ITEM where id = @conversationAbout_ItemId))
	begin
		set @rMsg = dbo.func_getSysMsg('invalidItem',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه آيتم وارد شده معتبر نمي باشد'); 
		set @rCode = 0
		return 0
	end
	if(@conversationAbout_oppinionId  is not null and @conversationAbout_oppinionId > 0 and not exists(select top 1 1 from TB_STORE_ITEM_OPINIONPOLL where id = @conversationAbout_oppinionId))
	begin
		set @rMsg = dbo.func_getSysMsg('invalidItem',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه نظرسنجی وارد شده معتبر نمي باشد'); 
		set @rCode = 0
		return 0
	end

declare @date as datetime = GETDATE()

if((@conversationId = 0 or @conversationId is null) and not exists(select id from TB_CONVERSATION where fk_from  = case when @messageAsStore = 0 then @userId  when @messageAsStore = 1 then @storeId end and fk_to =case when @conversationWithStore = 1 then @fk_store_destStoreId else @fk_usr_destUserId end and (fk_conversationAbout_ItemId = @conversationAbout_ItemId or @conversationAbout_ItemId is null or @conversationAbout_ItemId = 0) and (fk_conversationAbout_opinionPollId = @conversationAbout_oppinionId or @conversationAbout_oppinionId is null or @conversationAbout_oppinionId = 0)))
begin
	insert into TB_CONVERSATION(fk_from,fk_to,conversationWithStore,conversationWithPortal,fk_conversationAbout_ItemId,fk_conversationAbout_opinionPollId) values(case when @messageAsStore = 1 then @storeId else @userId end,case when @fk_store_destStoreId is not null then @fk_store_destStoreId else @fk_usr_destUserId end , @conversationWithStore,@conversationWithPortal,case when @conversationAbout_ItemId = 0 or @conversationAbout_ItemId is null then NULL else @conversationAbout_ItemId END,case when @conversationAbout_oppinionId = 0 then NULL else @conversationAbout_oppinionId END )
	set @conversationId = SCOPE_IDENTITY()
	set @rMsg =cast(@conversationId as varchar(10))
	insert into TB_MESSAGE
	([message],fk_usr_destUserId,fk_store_destStoreId,fk_store_senderStoreId,fk_usr_senderUser,saveDateTime,fk_orderHdr_RelatedOrderId,displayAsTicket,messageAsStore,fk_conversation_id)
	values(@message,@fk_usr_destUserId,@fk_store_destStoreId,case when @messageAsStore = 1 then  @storeId else NULL end,case when @messageAsStore = 1 then NULL else @userId end,@date,@fk_orderHdr_RelatedOrderId,@displayAsTicket,@messageAsStore,@conversationId)
end
else
begin
	if(@conversationId = 0 or @conversationId is null)
		set @conversationId = (select id from TB_CONVERSATION where fk_from  = case when @messageAsStore = 0 then @userId  when @messageAsStore = 1 then @storeId end and fk_to =case when conversationWithStore = 1 then @fk_store_destStoreId else @fk_usr_destUserId end and (fk_conversationAbout_ItemId = @conversationAbout_ItemId or @conversationAbout_ItemId is null or @conversationAbout_ItemId = 0) and (fk_conversationAbout_opinionPollId = @conversationAbout_oppinionId or @conversationAbout_oppinionId is null or @conversationAbout_oppinionId = 0))
	insert into TB_MESSAGE
	       ([message],fk_usr_destUserId,fk_store_destStoreId,fk_store_senderStoreId,fk_usr_senderUser,saveDateTime,fk_orderHdr_RelatedOrderId,displayAsTicket,messageAsStore,fk_conversation_id)
	 values(@message,case when @fk_usr_destUserId is not null then @fk_usr_destUserId else NULL end,case when @fk_usr_destUserId is null then @destId else NULL end,case when @storeId is not null then @storeId else NULL end,case When @messageAsStore = 0 then @userId else NULL end,@date,@fk_orderHdr_RelatedOrderId,@displayAsTicket,@messageAsStore,@conversationId)

end
 set @rCode = 1;
 
end try
begin catch
set @rMsg = dbo.func_getSysMsg('Error_unExpected',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
set @rCode = 0
end catch
RETURN 0
