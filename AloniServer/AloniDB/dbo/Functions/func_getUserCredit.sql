CREATE FUNCTION [dbo].[func_getUserCredit]
(
	--@userId as bigint,
	--@fk_accountType as tinyint
	@accountId as bigint
)
RETURNS money
AS
BEGIN
	declare @credit as money;	

	select @credit = sum(credit) + sum (debit)
	from TB_FINANCIAL_ACCOUNTING
	where fk_UsrFinancialAccount_id = @accountId
	group by fk_UsrFinancialAccount_id;
	
	return isnull(@credit,0);
END
