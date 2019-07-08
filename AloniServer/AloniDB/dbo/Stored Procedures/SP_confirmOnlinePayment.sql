CREATE PROCEDURE [dbo].[SP_confirmOnlinePayment]
		@clientLanguage AS CHAR(2)
	,@clientIp AS VARCHAR(50)
	,@appId as tinyint
	,@localToken as varchar(36)
	--,@userId as bigint
	--,@userSessionId AS BIGINT
	--,@orderId AS VARCHAR(36)
	,@transactionId AS BIGINT
	,@cardNo as varchar(25)
	,@amount as money
	,@info as text
	,@scrBank as varchar(50)
	--,@State as varchar(50)
	--,@StateCode as varchar(50)
	--,@ResNum as varchar(50)
	--,@MID as varchar(50)
	--,@RefNum as varchar(50)
	--,@CID as varchar(50)
	--,@TRACENO as varchar(50)
	--,@RRN as varchar(50)
	--,@SecurePan as varchar(50) = null


	,@revertTransaction as bit out
	,@rCode AS TINYINT OUT
	,@rMsg AS NVARCHAR(max) OUT
AS


--اعتبار سنجی توکن محلی
if(@localToken is null or @localToken <> 'DE84F477-4982-4912-8846-2B2D971C271F')
begin
set @revertTransaction = 1;
SET @rMsg = dbo.func_getSysMsg('unAuthorized', OBJECT_NAME(@@PROCID), @clientLanguage, 'illegal request.');
GOTO fail;
end

--بررسی صحت مبلغ
if(@amount is null or @amount <= 0)
begin
set @revertTransaction = 1;
SET @rMsg = dbo.func_getSysMsg('ThePaiedAmountIsNotCorrect', OBJECT_NAME(@@PROCID), @clientLanguage, 'the paid amount is not Correct.');
GOTO fail;
end


begin tran t1

set @revertTransaction = 0;


declare
 @amount_org as money
 ,@currentStatus as int
 ,@fk_paymentPortalTransactionType_typeId as int
 ,@fk_usr_requesterUserId as bigint
 ,@fk_orderHdr_id as bigint
 ,@paymentPortal_fk_financialAccount_destFinancialAccountId as bigint;--حساب مقصد درگاه بانکی

select
  @amount_org = tl.amount_org
 ,@currentStatus = tl.fk_status_id
 ,@fk_paymentPortalTransactionType_typeId = tl.fk_paymentPortalTransactionType_typeId
 ,@fk_usr_requesterUserId = tl.fk_usr_requesterUserId
 ,@fk_orderHdr_id = tl.fk_orderHdr_id
 ,@paymentPortal_fk_financialAccount_destFinancialAccountId = pp.fk_financialAccount_destFinancialAccountId
from TB_PAYMENTPORTAL_TRANSACTION_LOG as tl
join TB_PAYMENTPORTAL as pp
on tl.fk_paymentPortal_id = pp.id
where tl.id = @transactionId;--TODO: Decrypt

if(@amount_org is null)
begin
set @revertTransaction = 1;
SET @rMsg = dbo.func_getSysMsg('invalidTransactionId', OBJECT_NAME(@@PROCID), @clientLanguage, 'the transaction id is not valid.');
GOTO fail;
end

if(@currentStatus <> 50)
begin
SET @rMsg = dbo.func_getSysMsg('invalidTransactionState', OBJECT_NAME(@@PROCID), @clientLanguage, 'the state of transaction is not valid , or transaction is already done before.');
GOTO fail;
end

if(@amount_org <> @amount)
begin
set @revertTransaction = 1;
SET @rMsg = dbo.func_getSysMsg('ThePaiedAmountIsNotValid', OBJECT_NAME(@@PROCID), @clientLanguage, 'the paid amount is not valid.');

update TB_PAYMENTPORTAL_TRANSACTION_LOG
set fk_status_id = 52,srcCardNo = @cardNo,info = @info,srcBank = @scrBank,amount_paid = @amount
where id = @transactionId and fk_status_id = 50;
GOTO fail;
end


update TB_PAYMENTPORTAL_TRANSACTION_LOG
set fk_status_id = 51,srcCardNo = @cardNo,info = @info,srcBank = @scrBank,amount_paid = @amount
where id = @transactionId and fk_status_id = 50;

if(@@ROWCOUNT <> 1)
begin
--todo: add log
SET @rMsg = dbo.func_getSysMsg('unexpected', OBJECT_NAME(@@PROCID), @clientLanguage, 'unexpected error occurred.');
GOTO fail;
end

declare @ac_regardTypeDsc as varchar(max);

if(@fk_paymentPortalTransactionType_typeId = 1)
begin--خرید اعتبار مشتری

select @ac_regardTypeDsc = title 
from TB_TYP_FINANCIAL_REGARD_TYPE with(nolock) 
where id = 14;

INSERT INTO [dbo].[TB_FINANCIAL_ACCOUNTING]
           ([fk_UsrFinancialAccount_id]
           ,[regardDsc]
           ,[debit]
           ,[credit]
           ,[fk_orderHdr_id]
           ,[fk_orderDtl_id]
           ,[saveDatetime]
           ,[fk_usr_saveUserId]
           ,[note]
           ,[fk_order_orderId]
           ,[fk_typFinancialRegardType_id])
     VALUES
           (@paymentPortal_fk_financialAccount_destFinancialAccountId
           ,@ac_regardTypeDsc + '-make bank debitor'
           ,@amount_org * -1
           ,0
           ,NULL
           ,NULL
           ,getdate()
           ,@fk_usr_requesterUserId
           ,NULL--note
           ,NULL
           ,14);

		   INSERT INTO [dbo].[TB_FINANCIAL_ACCOUNTING]
           ([fk_UsrFinancialAccount_id]
           ,[regardDsc]
           ,[debit]
           ,[credit]
           ,[fk_orderHdr_id]
           ,[fk_orderDtl_id]
           ,[saveDatetime]
           ,[fk_usr_saveUserId]
           ,[note]
           ,[fk_order_orderId]
           ,[fk_typFinancialRegardType_id])
     VALUES
           (dbo.func_getUserFinansialAccountId(@fk_usr_requesterUserId,1)
           ,@ac_regardTypeDsc + '-make customer creditor'
           ,0
           ,@amount_org
           ,NULL
           ,NULL
           ,getdate()
           ,@fk_usr_requesterUserId
           ,NULL--note
           ,NULL
           ,14);
end
else if(@fk_paymentPortalTransactionType_typeId = 2)
begin--پرداخت آنلاین سفارش
select 1;
end



success:
commit tran t1;
SET @rCode = 1;
SET @rMsg = 'success.';

RETURN 0;

fail:

ROLLBACK TRAN t1;

SET @rCode = 0;

RETURN 0;
