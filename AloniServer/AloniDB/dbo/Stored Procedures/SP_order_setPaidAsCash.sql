CREATE PROCEDURE [dbo].[SP_order_setPaidAsCash]
	 @clientLanguage AS CHAR(2)
	,@appId as tinyint
	,@clientIp AS VARCHAR(50)
	,@userId as bigint

	,@orderId as bigint
	,@sessionId as bigint
	,@storeId as bigint




	,@rCode AS TINYINT OUT
	,@rMsg AS NVARCHAR(max) OUT
AS






declare @orderStatusId as int,@order_paymentMethode_id as tinyint,@sum_cost_payable_withTax_withDiscount_remaining as money,@storeFacnt_dynamic as bigint,@sum_cost_delivery_remaining as money,
@total_remaining_payment_payable as money;


select
  @total_remaining_payment_payable = oh.total_remaining_payment_payable
  ,@orderStatusId = [dbo].[func_getOrderStatus](o.id,o.fk_status_statusId,o.lastDeliveryDateTime)
 ,@order_paymentMethode_id = o.fk_paymentMethode_id
 ,@sum_cost_payable_withTax_withDiscount_remaining = oh.sum_cost_payable_withTax_withDiscount_remaining
 ,@storeFacnt_dynamic = fa.id
 ,@sum_cost_delivery_remaining = oh.sum_cost_delivery_remaining
from TB_ORDER as o
join TB_FINANCIAL_ACCOUNT as fa on o.fk_store_storeId = fa.fk_store_id and fa.fk_typFinancialAccountType_id = 1--یونیک ایندکس برای حساب ها ایجاد شود
join func_getOrderHdrs(@orderId) as oh on o.id = oh.orderId
where o.id = @orderId and o.fk_store_storeId = @storeId and [dbo].[func_getOrderStatus](o.id,o.fk_status_statusId,o.lastDeliveryDateTime) = 101


if(@orderStatusId is null)
begin
set @rMsg = dbo.func_getSysMsg('@invalidRequest',OBJECT_NAME(@@PROCID),@clientLanguage,'invalid request!');
goto fail;
end


if(@orderStatusId <> 101)
begin
set @rMsg = dbo.func_getSysMsg('@illegalStatusOfOrder',OBJECT_NAME(@@PROCID),@clientLanguage,'خطا: وضعیت سفارش توسط کاربر دیگری تغییر کرده است.');
goto fail;
end

if(@total_remaining_payment_payable <= 0)
begin
set @rMsg = dbo.func_getSysMsg('@alreadyPaid',OBJECT_NAME(@@PROCID),@clientLanguage,'هزینه سفارش قبلا به صورت کامل پرداخت شده است.');
goto fail;
end


declare @rowId as int,@cost_payable_withTax_withDiscount_remaining as money;
declare @newOrderHdrId as bigint;



declare c cursor
for select d.rowId,d.cost_payable_withTax_withDiscount_remaining
from func_getOrderDtls(@orderId,null) as d
where d.cost_payable_withTax_withDiscount_remaining > 0;

open c;
fetch next from c into @rowId,@cost_payable_withTax_withDiscount_remaining;

if(@@FETCH_STATUS <> 0)
begin
set @rMsg = dbo.func_getSysMsg('@alreadyPaid',OBJECT_NAME(@@PROCID),@clientLanguage,'هزینه سفارش قبلا به صورت کامل پرداخت شده است.');
goto fail;
end

begin tran t;
begin try

INSERT INTO [dbo].[TB_ORDER_HDR]
           ([fk_order_orderId]
           ,[fk_docType_id]
           ,[saveDateTime]
           ,[fk_usrSession_id]
           ,[saveIp]
           ,[isVoid]
		   ,[fk_staff_operatorStaffId])
     VALUES
           (@orderId
           ,2
           ,getdate()
           ,@sessionId
           ,@clientIp
           ,0
		   ,[dbo].[func_GetUserStaff](@userId,@storeId,@appId));
set @newOrderHdrId = SCOPE_IDENTITY();
		  




while(@@FETCH_STATUS = 0)
begin

INSERT INTO [dbo].[TB_FINANCIAL_ACCOUNTING]
           ([fk_UsrFinancialAccount_id]
           ,[regardDsc]
           ,[debit]
           ,[credit]
           ,[fk_order_orderId]
           ,[orderDtlRowId]
           ,[fk_orderHdr_id]
           ,[fk_orderDtl_id]
           ,[saveDatetime]
           ,[fk_usr_saveUserId]
           ,[note]
           ,[fk_typFinancialRegardType_id]
           ,[fk_paymentPortalTransactionLog_tranId])
     VALUES
           (@storeFacnt_dynamic
           ,dbo.func_financial_getRegardTypDsc(10001,@clientLanguage)
           ,@cost_payable_withTax_withDiscount_remaining * -1
           ,0
           ,@orderId
           ,@rowId
           ,@newOrderHdrId
           ,null
           ,getdate()
           ,@userId
           ,null
           ,10001
           ,null);

		   INSERT INTO [dbo].[TB_FINANCIAL_ACCOUNTING]
           ([fk_UsrFinancialAccount_id]
           ,[regardDsc]
           ,[debit]
           ,[credit]
           ,[fk_order_orderId]
           ,[orderDtlRowId]
           ,[fk_orderHdr_id]
           ,[fk_orderDtl_id]
           ,[saveDatetime]
           ,[fk_usr_saveUserId]
           ,[note]
           ,[fk_typFinancialRegardType_id]
           ,[fk_paymentPortalTransactionLog_tranId])
     VALUES
           (@storeFacnt_dynamic
           ,dbo.func_financial_getRegardTypDsc(10002,@clientLanguage)
           ,0
           ,@cost_payable_withTax_withDiscount_remaining
           ,@orderId
           ,@rowId
           ,@newOrderHdrId
           ,null
           ,getdate()
           ,@userId
           ,null
           ,10002
           ,null);

		   fetch next from c into @rowId,@cost_payable_withTax_withDiscount_remaining;

end--of while


if(@sum_cost_delivery_remaining > 0)
begin

INSERT INTO [dbo].[TB_FINANCIAL_ACCOUNTING]
           ([fk_UsrFinancialAccount_id]
           ,[regardDsc]
           ,[debit]
           ,[credit]
           ,[fk_order_orderId]
           ,[orderDtlRowId]
           ,[fk_orderHdr_id]
           ,[fk_orderDtl_id]
           ,[saveDatetime]
           ,[fk_usr_saveUserId]
           ,[note]
           ,[fk_typFinancialRegardType_id]
           ,[fk_paymentPortalTransactionLog_tranId])
     VALUES
           (@storeFacnt_dynamic
           ,dbo.func_financial_getRegardTypDsc(10011,@clientLanguage)
           ,@sum_cost_delivery_remaining * -1
           ,0
           ,@orderId
           ,@rowId
           ,@newOrderHdrId
           ,null
           ,getdate()
           ,@userId
           ,null
           ,10011
           ,null);

		   INSERT INTO [dbo].[TB_FINANCIAL_ACCOUNTING]
           ([fk_UsrFinancialAccount_id]
           ,[regardDsc]
           ,[debit]
           ,[credit]
           ,[fk_order_orderId]
           ,[orderDtlRowId]
           ,[fk_orderHdr_id]
           ,[fk_orderDtl_id]
           ,[saveDatetime]
           ,[fk_usr_saveUserId]
           ,[note]
           ,[fk_typFinancialRegardType_id]
           ,[fk_paymentPortalTransactionLog_tranId])
     VALUES
           (@storeFacnt_dynamic
           ,dbo.func_financial_getRegardTypDsc(10012,@clientLanguage)
           ,0
           ,@sum_cost_delivery_remaining
           ,@orderId
           ,@rowId
           ,@newOrderHdrId
           ,null
           ,getdate()
           ,@userId
           ,null
           ,10012
           ,null);

end





commit tran t;
end try

begin catch
set @rMsg = ERROR_MESSAGE();
rollback tran t;
close c;--?
deallocate c;--?
goto fail;
end catch


close c;
deallocate c;





SET @rCode = 1;
SET @rMsg = 'success.';

RETURN 0;

fail:

SET @rCode = 0;

RETURN 0;