CREATE FUNCTION [dbo].[func_order_calcPaymentStatus]
(
	@total_payment_payable money,
	@total_paid money

)
RETURNS smallint
AS
BEGIN
	

	declare @diff as money;
	set @diff = @total_payment_payable + @total_paid;



	return case when @diff = @total_payment_payable then 200 when @diff = 0 then 201 when @diff > 0 then 202 when @diff < 0 then 203  end ;

END