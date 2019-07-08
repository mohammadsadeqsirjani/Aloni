CREATE PROCEDURE [dbo].[SP_userCreditSetIncReq]
	@clientLanguage AS CHAR(2)
	,@clientIp AS VARCHAR(50)
	,@appId as tinyint
	,@userId as bigint
	,@sessionId AS BIGINT
	,@amount as money
	,@paymentUrl as varchar(255) out
	,@rCode AS TINYINT OUT
	,@rMsg AS NVARCHAR(max) OUT
AS
	





declare @paymentPortalId as int, @baseAddress as varchar(255),@userCountryId as bigint,@paymentPortalMinimumAmount as money;

select @userCountryId = userCountry.fk_currency_id
 from TB_USR as u with(nolock) 
 join TB_COUNTRY as userCountry with(nolock)
 on u.fk_country_id = userCountry.id
 where u.id = @userId;

select @paymentPortalId = id, @baseAddress = [url],@paymentPortalMinimumAmount = minimumAmount
from TB_PAYMENTPORTAL with(nolock)
where fk_country_id = @userCountryId and isDefault = 1
if(@baseAddress is null or @baseAddress = '')
begin
SET @rMsg = dbo.func_getSysMsg('error_invalidPaymentPortalBaseAddress', OBJECT_NAME(@@PROCID), @clientLanguage, 'error: invalid Payment Portal Base Address');
	GOTO fail;
end


if(@amount is null)
begin
SET @rMsg = dbo.func_getSysMsg('error_amountIsNull', OBJECT_NAME(@@PROCID), @clientLanguage, 'error: please fill the amount part.');
	GOTO fail;
end



if(@amount < @paymentPortalMinimumAmount)
begin
SET @rMsg = dbo.func_getSysMsg('error_amountIsLessThanMinimumAmountOfPAymentPortal', OBJECT_NAME(@@PROCID), @clientLanguage, 'error: the requested amount is less than minimum payable amount of payment portal.');
	GOTO fail;
end




insert into TB_PAYMENTPORTAL_TRANSACTION_LOG
(fk_paymentPortal_id,amount_org,fk_usr_requesterUserId,fk_paymentPortalTransactionType_typeId,fk_status_id)
values (@paymentPortalId,@amount,@userId,1,50);

set @paymentUrl = @baseAddress + '/' + CAST(SCOPE_IDENTITY() as varchar(20));










success:

SET @rCode = 1;
SET @rMsg = 'success.';

RETURN 0;

fail:

--ROLLBACK TRAN t1;

SET @rCode = 0;

RETURN 0;