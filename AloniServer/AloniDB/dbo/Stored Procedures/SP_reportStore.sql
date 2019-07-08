CREATE PROCEDURE [dbo].[SP_reportStore]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@dsc as varchar(max) = NULL,
	@reportTypeId as bigint,
	@conversationId as bigint = 0,
	@orderId as bigint = 0,
	@fk_order_correspondence as bigint = 0
AS
if(not exists(select top 1 1 from TB_TYP_STORE_REPORT_TYPE where id = @reportTypeId))
begin
	set @reportTypeId = null
end
if((select reportingIsBlocked from TB_USR where id = @userId) = 1)
begin
set @rMsg = dbo.func_getSysMsg('reportBlockedUser',OBJECT_NAME(@@PROCID),@clientLanguage,'متاسفانه شما مجاز به ثبت گزارش نیستید');
goto fail;
end
if(@reportTypeId is null and( @dsc is null or @dsc = ''))
begin
set @rMsg = dbo.func_getSysMsg('reportDscIsRequired',OBJECT_NAME(@@PROCID),@clientLanguage,'لطفا توضیحات گزارش خود را وارد نمائید');
goto fail;
end
if(@conversationId > 0 and not exists(select top 1 1 from TB_CONVERSATION where id = @conversationId))
begin
set @rMsg = dbo.func_getSysMsg('reportDscIsRequired',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه گفتگو معتبر نیست');
goto fail;
end
if(@orderId > 0 and not exists(select top 1 1 from TB_ORDER where id = @orderId))
begin
set @rMsg = dbo.func_getSysMsg('reportDscIsRequired',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه سفارش معتبر نیست');
goto fail;
end
if(@storeId > 0 and not exists(select top 1 1 from TB_STORE where id = @storeId))
begin
set @rMsg = dbo.func_getSysMsg('reportDscIsRequired',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه پنل معتبر نیست');
goto fail;
end
if(@fk_order_correspondence > 0 and not exists(select top 1 1 from TB_ORDER_CORRESPONDENCE where fk_order_orderId = @fk_order_correspondence))
begin
set @rMsg = dbo.func_getSysMsg('reportDscIsRequired',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه سفارش معتبر نیست');
goto fail;
end
begin try
	insert into 
	TB_STORE_REPORT(fk_store_id,fk_usr_id,description,saveDateTime,fk_reportType_id,fk_conversation_id,fk_orderId,fk_order_correspondence) values(case when @storeId = 0 then NULL else @storeId END,@userId,@dsc,GETDATE(),case when @reportTypeId = 0 then NULL else @reportTypeId END,case when @conversationId = 0 then NULL else @conversationId END, case when @orderId = 0 then NULL else @orderId END ,case when @fk_order_correspondence = 0 THEN NULL else @fk_order_correspondence END)
	end try

begin catch
set @rMsg = ERROR_MESSAGE();
set @rMsg = dbo.func_getSysMsg('alreadyReported',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE());
goto fail;
end catch


  success:
	  set @rCode = 1;
	  set @rMsg = dbo.func_getSysMsg('success',OBJECT_NAME(@@PROCID),@clientLanguage,'با تشکر از همکاری شما ، گزارش شما در سامانه ثبت گردید و بزودی بررسی می گردد.');
	  return 0;
	  fail:
	  set @rCode = 0;
	  return 0;






RETURN 0




