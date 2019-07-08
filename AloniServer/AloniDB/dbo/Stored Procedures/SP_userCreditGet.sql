CREATE PROCEDURE [dbo].[SP_userCreditGet]
	@clientLanguage AS CHAR(2)
	,@clientIp AS VARCHAR(50)
	,@appId as tinyint
	,@userId as bigint
	,@creditDsc as varchar(100) OUT
	,@currencyTitle as varchar(50) OUT
	,@credit as money OUT
	,@rCode AS TINYINT OUT
	,@rMsg AS NVARCHAR(max) OUT
AS
	



	declare @userCreditAccountId as bigint,@currencyId as int,@currencySymbole as varchar(20);

 
 --select @currencyTitle = ISNULL(crt.title,cr.title),@currencyId = cr.id
 --from TB_USR as u
 --join TB_COUNTRY as cn
 --on u.fk_country_id = cn.id
 --join TB_CURRENCY as cr
 --on cn.fk_currency_id = cr.id
 --left join TB_CURRENCY_TRANSLATIONS crt
 --on cr.id = crt.id and crt.lan = @clientLanguage

 begin try

 select @userCreditAccountId = facnt.id, @currencyId = cr.id, @currencyTitle = ISNULL(crt.title,cr.title) , @currencySymbole = cr.Symbol
 from TB_USR as u
 join TB_FINANCIAL_ACCOUNT as facnt
 on u.id = facnt.fk_usr_userId and facnt.fk_typFinancialAccountType_id = 1
 join TB_CURRENCY as cr
 on facnt.fk_currency_id = cr.id
 left join TB_CURRENCY_TRANSLATIONS crt
 on cr.id = crt.id and crt.lan = @clientLanguage;




 --set @credit = dbo.func_getUserCredit(dbo.func_getUserFinansialAccountId(@userId,1));
  set @credit = dbo.func_getUserCredit(@userCreditAccountId);
  --if(dbo.func_languageIsRTL(@clientLanguage) = 1)
 set @creditDsc = @currencySymbole + ' ' + dbo.func_addThousandsSeperator(@credit);
 end try
 begin catch
 set @rMsg = ERROR_MESSAGE();
 goto fail;
 end catch









	success:

SET @rCode = 1;
SET @rMsg = 'success.';

RETURN 0;

fail:

--ROLLBACK TRAN t1;

SET @rCode = 0;

RETURN 0;
