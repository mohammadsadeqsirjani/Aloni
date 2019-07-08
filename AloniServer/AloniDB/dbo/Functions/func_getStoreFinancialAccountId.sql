CREATE FUNCTION [dbo].[func_getStoreFinancialAccountId]
(
	@storeId as bigint,
	@fAccountType as smallint
)
RETURNS BIGINT
AS
BEGIN
	--declare @retVal as bigint;
	return (select top (1) id from TB_FINANCIAL_ACCOUNT with(nolock) where fk_store_id = @storeId and fk_typFinancialAccountType_id = @fAccountType)
END
