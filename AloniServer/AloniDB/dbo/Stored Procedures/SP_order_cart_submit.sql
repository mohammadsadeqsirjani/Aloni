CREATE PROCEDURE [dbo].[SP_order_cart_submit]
	@clientLanguage AS CHAR(2)
	,@clientIp AS VARCHAR(50)
	,@appId as tinyint
	,@userId as bigint
	,@userSessionId AS BIGINT
	,@orderId AS BIGINT	
	,@paymentMethode as tinyint--روش پرداخت انتخاب شده توسط کاربر
	,@paymentType as tinyint--نوع پرداخت از لحاظ کامل / پیش پرداخت انتخاب شده توسط کاربر
	,@paymentUrl as varchar(255) OUT
	,@rCode AS TINYINT OUT
	,@rMsg AS NVARCHAR(max) OUT
AS
	SET NOCOUNT ON;



	if(@paymentMethode is null or @paymentMethode not in (select id from TB_TYP_PAYMENT_METHODE with(nolock)))
	begin
	SET @rMsg = dbo.func_getSysMsg('invalidInput_paymentMethode', OBJECT_NAME(@@PROCID), @clientLanguage, 'the input parameter paymentMethode is not valid.');
	GOTO fail;
	end




declare 
 @cstmrId as bigint
,@storeId as bigint
,@storeTitle as varchar(100)
,@storeLan as char(2)
,@orderStatusId as int
,@o_total_remaining_payment_payable as money
,@o_total_remaining_prepayment_payable as money
--,@o_lastOrderHdrId as bigint
,@store_countryId as int
,@isSecurePayment as bit
,@o_sum_cost_delivery_remaining as money
,@store_country_currencyId as int
,@orderHdrId as bigint

select 
@cstmrId = o.fk_usr_customerId
,@storeId = o.fk_store_storeId
,@storeTitle = store.title
,@storeLan = storecountry.fk_language_officialLan
,@orderStatusId = [dbo].[func_getOrderStatus](o.id,o.fk_status_statusId,o.lastDeliveryDateTime)
,@orderHdrId = oh.id
--,@o_total_remaining_payment_payable = c_hdr.total_remaining_payment_payable
--,@o_total_remaining_prepayment_payable = c_hdr.total_remaining_prepayment_payable
,@store_countryId = store.fk_country_id
,@isSecurePayment = case when fk_securePayment_StatusId = 13 then 1 else 0 end
--,@o_sum_cost_delivery_remaining = c_hdr.sum_cost_delivery_remaining
,@store_country_currencyId = storecountry.fk_currency_id
 from
 TB_ORDER as o
 join
 TB_ORDER_HDR as oh on o.id = oh.fk_order_orderId
 join
 TB_STORE as store
 on o.fk_store_storeId = store.id
  join TB_COUNTRY as storecountry with(nolock)
 on store.fk_country_id = storecountry.id
 where o.id = @orderId and o.fk_usr_customerId = @userId;


 if(@orderStatusId is null)
 begin
 	SET @rMsg = dbo.func_getSysMsg('illegalRequest', OBJECT_NAME(@@PROCID), @clientLanguage, 'invalid request.');
	GOTO fail;
 end


 select @o_total_remaining_payment_payable = total_remaining_payment_payable,
 @o_total_remaining_prepayment_payable = total_remaining_prepayment_payable,
 @o_sum_cost_delivery_remaining = sum_cost_delivery_remaining
 --,@o_lastOrderHdrId = lastOrderHdrId
 from dbo.[func_getOrderHdrs](@orderId)



----بررسی آخرین بودن سربرگ سفارش
--IF (
--		--EXISTS (
--		--	SELECT 1
--		--	FROM TB_ORDER_HDR
--		--	WHERE id > @OrderHdrId
--		--		AND orderId = @hdr_orderId
--		--	)
--		   @o_lastOrderHdrId is null or @OrderHdrId is null or @o_lastOrderHdrId  <> @OrderHdrId
--		)
--BEGIN
--	SET @rMsg = dbo.func_getSysMsg('orderInfoChanged', OBJECT_NAME(@@PROCID), @clientLanguage, 'اطلاعات سفارش تغییر کرده است. لطفا پس از بارگذاری مجدد اطلاعات اقدام به ثبت درخواست خود بنمائید.');
--	GOTO fail;
--END




----بررسی دسترسی کاربر به انجام این فعل بر روی سفارش مورد نظر
----TODO: شناسه سفارش باید به تابع اهراز هویت داده شود و دسترسی کاربر متناسب با استور مرتبط با آن بررسی شود
----TODO: انجام شد. حذف شود
--if(@appId = 2 and @cstmrId <> @userId or (@appId = 1 and not exists(select 1 from TB_USR_STAFF where fk_usr_id = @userId and fk_store_id = @storeId and fk_status_id in (37) )) )
--begin
--	SET @rMsg = dbo.func_getSysMsg('accessDenied', OBJECT_NAME(@@PROCID), @clientLanguage, 'Access denied!');
--	GOTO fail;
--end



--اعتبار سنجی وضعیت فعلی سفارش
if(@orderStatusId <> 100)-- or exists(select 1 from TB_ORDER_DTL where fk_orderHdr_id = @OrderHdrId and isVoid = 0 and fk_status_id not in (39,41)) )
begin
	SET @rMsg = dbo.func_getSysMsg('illegal_crntStatus', OBJECT_NAME(@@PROCID), @clientLanguage, 'illegal operation: the current status of order / order Dtls are not alowed to perform this action.');
	GOTO fail;
end




--اعتبار سنجی روش پرداخت
--اعتبار سنجی نوع پرداخت
--اعتبار سنجی نوع پرداخت و روش پرداخت
--DECLARE	@return_value_SP_order_getPaymentTypes int;
CREATE TABLE #payTypes
(
   hasPrePayment bit,
   cash tinyint,
   credit tinyint,
   online tinyint
)


insert into #payTypes 
EXEC	 [dbo].[SP_order_cart_getPaymentTypes]
		@clientLanguage = @clientLanguage,
		@clientIp = @clientIp,
		@appId = @appId,
		@userId = @userId,
		@orderId = @orderId,
		@pageNo = NULL,
		@search = NULL,
		@parent = NULL

		if(exists(select 1 from [#payTypes] where (@paymentMethode = 1 and cash = 0) or (@paymentMethode = 2 and credit = 0) or (@paymentMethode = 3 and [online] = 0) or (hasPrePayment = 1 and @paymentType is null) or (hasPrePayment = 0 and @paymentType = 2) or (@paymentType = 2 and @paymentMethode not in(2,3))))
		begin
		SET @rMsg = dbo.func_getSysMsg('illegal_paymentTypeOrPaymentMethodeIsNotValid', OBJECT_NAME(@@PROCID), @clientLanguage, 'illegal operation: the payment Type Or Payment Methode Is Not Valid');
	GOTO fail;
		end



		declare @sumVal as money,@customerCreditAccountId as bigint;
		set @sumVal = case when @paymentType = 2 then @o_total_remaining_prepayment_payable else @o_total_remaining_payment_payable end;
		set @customerCreditAccountId = dbo.func_getUserFinansialAccountId(@cstmrId,1);




--پرداخت آنلاین است - تولید آدرس پرداخت و ریترن
if(@paymentMethode = 3)
begin
declare @paymentPortalId as int, @baseAddress as varchar(255);
select @paymentPortalId = id, @baseAddress = [url] from TB_PAYMENTPORTAL where fk_country_id = @store_countryId and isDefault = 1
if(@baseAddress is null or @baseAddress = '')
begin
SET @rMsg = dbo.func_getSysMsg('error_invalidPaymentPortalBaseAddress', OBJECT_NAME(@@PROCID), @clientLanguage, 'error: invalid Payment Portal Base Address');
	GOTO fail;
end

set @paymentUrl = @baseAddress + '/' + CAST(@OrderHdrId as varchar(20));

update TB_ORDER_HDR
set fk_paymentPortal_id = @paymentPortalId
where id = @OrderHdrId;


goto success;

end
else if (@paymentMethode = 2)
begin
--پرداخت اعتباری است - اعتبار سنجی موجودی کیف پول
if(dbo.func_getUserCredit(@customerCreditAccountId) <  @sumVal)
begin
SET @rMsg = dbo.func_getSysMsg('illegal_cstmrCreditIsNotEnough', OBJECT_NAME(@@PROCID), @clientLanguage, 'illegal operation: customers Credit Is Not Enough');
	GOTO fail;
end

if(@store_country_currencyId <> (select userCountry.fk_currency_id from TB_USR as u with(nolock) join TB_COUNTRY as userCountry with(nolock) on u.fk_country_id = userCountry.id where u.id = @cstmrId) )
begin
SET @rMsg = dbo.func_getSysMsg('illegal_currencyOfStoreAndUserAreDifferent', OBJECT_NAME(@@PROCID), @clientLanguage, 'illegal operation: the currency of store is different from customers currency');
	GOTO fail;
end




begin tran tran_credit
begin try

declare--متغیر های مربوط به ردیف های سفارش برای ثبت اسناد حسابداری
@cdtl_rowId as bigint,
@cdtl_itemId as bigint,
@cdtl_cost_payable_withTax_withDiscount_remaining as money,
@cdtl_cost_prepayment_remaining as money,
@cdtl_sum_qty as money,
@dtl_val as money,
@ac_regardTypeId as int,
@ac_regardTypeDsc as varchar(50),
@storeFacnt_dynamic as bigint,
@storeFacnt_static as bigint,
@nhdr_docType as smallint,
@nhdr_id as bigint;



set @ac_regardTypeId = case when @paymentType = 1 and @isSecurePayment = 1  then 12 when @paymentType = 1 and @isSecurePayment = 0 then 3 when @paymentType = 2 and @isSecurePayment = 1  then 13  when @paymentType = 2 and @isSecurePayment = 0  then 9 end;
set @ac_regardTypeDsc = [dbo].[func_getRegardTypeDsc](@ac_regardTypeId); --case when @paymentType = 2 then 'payment-order-credit' else 'prepayment-order-credit' end + '-';
--set @ac_regardTypeDsc = @ac_regardTypeDsc + case when @isSecurePayment =1 then 'safe' else 'unsafe' end + '-';
set @storeFacnt_dynamic = [dbo].[func_getStoreFinancialAccountId](@storeId,1);
set @storeFacnt_static =  [dbo].[func_getStoreFinancialAccountId](@storeId,2);
set @nhdr_docType = case when @paymentType = 1 and @isSecurePayment = 1  then 10 when @paymentType = 1 and @isSecurePayment = 0 then 4 when @paymentType = 2 and @isSecurePayment = 1  then 12  when @paymentType = 2 and @isSecurePayment = 0  then 6 end;

--ثبت سند پرداخت اعتباری
INSERT INTO [dbo].[TB_ORDER_HDR]
           ([fk_order_orderId]
           ,[fk_docType_id]
           ,[saveDateTime]
           ,[fk_usrSession_id]
           ,[saveIp]
           ,[fk_deliveryTypes_id]
           --,[deliveryLoc]
           --,[deliveryAddress]
           --,[fk_state_deliveryStateId]
           --,[fk_city_deliveryCityId]
           --,[delivery_postalCode]
           --,[delivery_callNo]
		   ,[fk_address_id]
           ,[onlinePaymentId]
           ,[fk_paymentPortal_id]
		   ,[isVoid]
		   ,[fk_staff_operatorStaffId]
		   )
     select
           @orderId
           ,@nhdr_docType
           ,getDate()
           ,@userSessionId
           ,@clientIp
           ,fk_deliveryTypes_id
           --,deliveryLoc
           --,deliveryAddress
           --,fk_state_deliveryStateId
           --,fk_city_deliveryCityId
           --,delivery_postalCode
           --,delivery_callNo
		   ,fk_address_id
           ,NULL--[onlinePaymentId]
           ,NULL--[fk_paymentPortal_id]
		   ,0
		   ,[dbo].[func_GetUserStaff](@userId,@storeId,@appId)
		   from TB_ORDER_HDR
		   where id = @OrderHdrId;
		   set @nhdr_id = SCOPE_IDENTITY();

		   INSERT INTO [dbo].[TB_ORDER_DTL]
           ([fk_orderHdr_id]
           ,[fk_store_id]
           ,[fk_item_id]
           ,[vfk_store_item_color_id]
           ,[vfk_store_item_size_id]
           ,[vfk_store_item_warranty]
           ,[qty]          
		   )
     select
           @nhdr_id
           ,[fk_store_id]
           ,[fk_item_id]
           ,[vfk_store_item_color_id]
           ,[vfk_store_item_size_id]
           ,[vfk_store_item_warranty]
           ,0--qty
		   from TB_ORDER_DTL where fk_orderHdr_id = @OrderHdrId;


--صدور اسناد حسابداری متناسب با مبلغ قابل پرداخت یا مبلغ پیشپرداخت  و متناسب با پرداخت امن بودن یا نبودن
declare  crsr_dtls cursor

-- for select id,fk_item_id,cost_payable_withTax_withDiscount_remaining,cost_prepayment_remaining,sum_qty
--from TB_ORDER_DTL where fk_orderHdr_id = @nhdr_id and sum_qty > 0--?WARNING : case when on payable or prepyable > 0

for select rowId,cost_payable_withTax_withDiscount_remaining,cost_prepayment_remaining,sum_qty,itemId
from dbo.func_getOrderDtls(@orderId,null)

open crsr_dtls;

fetch next from crsr_dtls
into
@cdtl_rowId ,
--@cdtl_itemId ,
@cdtl_cost_payable_withTax_withDiscount_remaining,
@cdtl_cost_prepayment_remaining,
@cdtl_sum_qty,
@cdtl_itemId;

while @@FETCH_STATUS = 0
begin

--بررسی موجودی -- TODO: بهینه سازی شود
if([dbo].[func_controlInventory](@storeId,@cdtl_itemId) = 1 and exists(select 1 from TB_STORE_ITEM_QTY where pk_fk_store_id = @storeId and pk_fk_item_id = @cdtl_itemId and qty < @cdtl_cost_prepayment_remaining) )
begin
   close crsr_dtls;
		   deallocate crsr_dtls;
		   set @rMsg = dbo.func_getSysMsg('error_InventoryDeficit', OBJECT_NAME(@@PROCID), @clientLanguage, 'با عرض پوزش ، به دلیل کسری موجودی کالا امکان ثبت خرید ممکن نمی باشد.');
		   goto fail;
end




set @dtl_val = case when @paymentType = 2 then @cdtl_cost_prepayment_remaining else @cdtl_cost_payable_withTax_withDiscount_remaining end;

INSERT INTO [dbo].[TB_FINANCIAL_ACCOUNTING]
           ([fk_UsrFinancialAccount_id]
           ,[regardDsc]
           ,[debit]
           ,[credit]
           ,[fk_orderHdr_id]
           ,[orderDtlRowId]
           ,[saveDatetime]
           ,[fk_usr_saveUserId]
           ,[note]
           ,[fk_order_orderId]
           ,[fk_typFinancialRegardType_id])
     VALUES
           (@customerCreditAccountId
           ,@ac_regardTypeDsc + '-make customer debitor'
           ,@dtl_val * -1
           ,0
           ,@nhdr_id
           ,@cdtl_rowId
           ,getdate()
           ,@userId
           ,NULL--note
           ,@orderId
           ,@ac_regardTypeId);

		   INSERT INTO [dbo].[TB_FINANCIAL_ACCOUNTING]
           ([fk_UsrFinancialAccount_id]
           ,[regardDsc]
           ,[debit]
           ,[credit]
           ,[fk_orderHdr_id]
           ,[orderDtlRowId]
           ,[saveDatetime]
           ,[fk_usr_saveUserId]
           ,[note]
           ,[fk_order_orderId]
           ,[fk_typFinancialRegardType_id])
     VALUES
           ((case when @isSecurePayment = 1 then  @storeFacnt_static else @storeFacnt_dynamic end)
           ,@ac_regardTypeDsc + '-make marketer creditor'
           ,0
           ,@dtl_val
           ,@nhdr_id
           ,@cdtl_rowId
           ,getdate()
           ,@userId
           ,NULL--note
           ,@orderId
           ,@ac_regardTypeId);


		   fetch next from crsr_dtls
			into
			@cdtl_rowId ,
			@cdtl_cost_payable_withTax_withDiscount_remaining ,
			@cdtl_cost_prepayment_remaining,
			@cdtl_sum_qty,
			@cdtl_itemId;


		   end;
		   close crsr_dtls;
		   deallocate crsr_dtls;

		   --add delivery cost accounting if exist
		   if(@o_sum_cost_delivery_remaining > 0)
		   begin
		   INSERT INTO [dbo].[TB_FINANCIAL_ACCOUNTING]
           ([fk_UsrFinancialAccount_id]
           ,[regardDsc]
           ,[debit]
           ,[credit]
           ,[fk_orderHdr_id]
           ,[orderDtlRowId]
           ,[saveDatetime]
           ,[fk_usr_saveUserId]
           ,[note]
           ,[fk_order_orderId]
           ,[fk_typFinancialRegardType_id])
     VALUES
           (@customerCreditAccountId
           ,@ac_regardTypeDsc + '-make customer debitor'
           ,@o_sum_cost_delivery_remaining * -1
           ,0
           ,@nhdr_id
           ,NULL--@cdtl_rowId
           ,getdate()
           ,@userId
           ,NULL--note
           ,@orderId
           ,6);
		   INSERT INTO [dbo].[TB_FINANCIAL_ACCOUNTING]
           ([fk_UsrFinancialAccount_id]
           ,[regardDsc]
           ,[debit]
           ,[credit]
           ,[fk_orderHdr_id]
           ,[orderDtlRowId]
           ,[saveDatetime]
           ,[fk_usr_saveUserId]
           ,[note]
           ,[fk_order_orderId]
           ,[fk_typFinancialRegardType_id])
     VALUES
           ((case when @isSecurePayment = 1 then  @storeFacnt_static else @storeFacnt_dynamic end)
           ,@ac_regardTypeDsc + '-make marketer creditor'
           ,0
           ,@o_sum_cost_delivery_remaining
           ,@nhdr_id
           ,NULL--@cdtl_rowId
           ,getdate()
           ,@userId
           ,NULL--note
           ,@orderId
           ,6);
		   end

--		   --اجرای تابع محاسبات - در دل تابع محاسبات پولی که به حساب شرکت بابت پرداخت امن رفته است هم در نظر گرفته شود
--		--   DECLARE	@return_value_SP_calcOrderValues_ int,
--		--@rCode_SP_calcOrderValues tinyint,
--		--@rMsg_SP_calcOrderValues nvarchar(max)

--EXEC	@return_value_SP_calcOrderValues = [dbo].[SP_calcOrderValues]
--		@orderHdrId = @nhdr_id,
--		@clientLanguage = @clientLanguage,
--		@rCode = @rCode_SP_calcOrderValues OUTPUT,
--		@rMsg = @rMsg_SP_calcOrderValues OUTPUT;




commit tran tran_credit;
end try
begin catch
rollback tran tran_credit;
set @rMsg = ERROR_MESSAGE();
goto fail;
end catch

end
else if (@paymentMethode = 1)
begin
--پرداخت نقدی است

--پرداخت نمی تواند امن باشد

--بروزرسانی وضعیت سفارش،وضعیت پرداخت ، نوع پرداخت، روش پرداخت، امن بودن پرداخت
begin try
begin tran t_cash
--INSERT INTO [dbo].[TB_ORDER_HDR]
--           ([fk_order_orderId]
--           ,[fk_docType_id]
--           ,[saveDateTime]
--           ,[fk_usrSession_id]
--           ,[saveIp]
--           ,[fk_deliveryTypes_id]
--           ,[deliveryLoc]
--           ,[deliveryAddress]
--           ,[fk_state_deliveryStateId]
--           ,[fk_city_deliveryCityId]
--           ,[delivery_postalCode]
--           ,[delivery_callNo]
--           ,[onlinePaymentId]
--           ,[fk_paymentPortal_id]
--		   )
--     select
--           fk_order_orderId
--           ,2
--           ,getDate()
--           ,@userSessionId
--           ,@clientIp
--           ,fk_deliveryTypes_id
--           ,deliveryLoc
--           ,deliveryAddress
--           ,fk_state_deliveryStateId
--           ,fk_city_deliveryCityId
--           ,delivery_postalCode
--           ,delivery_callNo
--           ,NULL--[onlinePaymentId]
--           ,NULL--[fk_paymentPortal_id]
--		   from TB_ORDER_HDR
--		   where id = @OrderHdrId;
--		   set @nhdr_id = SCOPE_IDENTITY();

--		   INSERT INTO [dbo].[TB_ORDER_DTL]
--           ([fk_order_id]
--		   ,[fk_orderHdr_id]
--		   ,[rowId]
--           ,[fk_store_id]
--           ,[fk_item_id]
--           ,[vfk_store_item_color_id]
--           ,[vfk_store_item_size_id]
--           ,[vfk_store_item_warranty]
--           ,[qty]
--           ,[delivered])
--     select
--			[fk_order_id]
--           ,@nhdr_id
--		   ,[rowId]
--           ,[fk_store_id]
--           ,[fk_item_id]
--           ,[vfk_store_item_color_id]
--           ,[vfk_store_item_size_id]
--           ,[vfk_store_item_warranty]
--           ,0
--           ,0
--		   from TB_ORDER_DTL where fk_orderHdr_id = @OrderHdrId;



		   update TB_ORDER
		   set fk_status_statusId = 101
		   ,isTwoStepPayment = case when @paymentType = 2 then 1 else 0 end
		   ,fk_paymentMethode_id = @paymentMethode
		   ,submitDateTime = GETDATE()
		   where id = @orderId;


		   update TB_STORE_ITEM_QTY
		   set qty = qty - d.sum_qty
		   from func_getOrderDtls(@orderId,null) as d
		   join TB_ORDER as o on d.orderId = o.id
		   join TB_STORE_ITEM_QTY as q on d.itemId = q.pk_fk_item_id and q.pk_fk_store_id = o.fk_store_storeId;


		   DECLARE @RC int
DECLARE @targetStoreId bigint
DECLARE @targetStoreIds [dbo].[LongType]
DECLARE @funcId varchar(100)
DECLARE @heading varchar(100)
DECLARE @content varchar(max)
DECLARE @section varchar(20)
DECLARE @action varchar(20)
DECLARE @targetId varchar(20)
DECLARE @par1 varchar(max)
DECLARE @par2 varchar(max)
DECLARE @par3 varchar(max)
DECLARE @par4 varchar(max)
DECLARE @spntsu_rCode tinyint
DECLARE @spntsu_rMsg nvarchar(max)

-- TODO: Set parameter values here.
set @targetStoreId = @storeId;
set @funcId = 'MARKETER_NOTI_ORDER_NEW';
set @heading =  dbo.func_getSysMsg('noti_newOrder_heading', OBJECT_NAME(@@PROCID), @storeLan, 'سفارش جدید');
set @content = dbo.func_stringFormat_1( dbo.func_getSysMsg('noti_newOrder_content', OBJECT_NAME(@@PROCID), @storeLan, 'سفارش جدیدی در فروشگاه "{0}" ثبت شده است.'),@storeTitle);
set @section = 'order';
set @action = 'get';
set @targetId = @orderId;
set @par1 = @storeId;
EXECUTE @RC = [dbo].[SP_SYS_sendPushNotificationToStoreUsers] 
   @targetStoreId
  ,@targetStoreIds
  ,@funcId
  ,@content
  ,@heading
  ,@section
  ,@action
  ,@targetId
  ,@par1
  ,@par2
  ,@par3
  ,@par4
  ,@spntsu_rCode OUTPUT
  ,@spntsu_rMsg OUTPUT







		   commit tran t_cash
		   end try
		   begin catch
		   rollback tran t_cash;
		   set @rMsg = ERROR_MESSAGE();
		   goto fail;
		   end catch
end


success:

SET @rCode = 1;
SET @rMsg = 'success.';

RETURN 0;

fail:

--ROLLBACK TRAN t1;

SET @rCode = 0;

RETURN 0;