CREATE FUNCTION [dbo].[func_getMinOrderHdrIdOfOrder]
(
	@orderId as bigint
)
RETURNS bigint
AS
BEGIN
	RETURN (select min(id) from TB_ORDER_HDR where fk_order_orderId = @orderId and isVoid = 0)
END
