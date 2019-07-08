CREATE FUNCTION [dbo].[func_getUserFinansialAccountId]
(
	@userId as bigint,
	@fk_accountType as tinyint
)
RETURNS bigint
AS
BEGIN
declare @accountId as bigint;
	set @accountId = (select top (1) id from TB_FINANCIAL_ACCOUNT with(nolock) where fk_usr_userId = @userId and fk_typFinancialAccountType_id = @fk_accountType);
	return @accountId;
END
