CREATE FUNCTION [dbo].[func_getMaxOrderHdrIdOfOrder]
(
	@orderId as bigint
)
RETURNS bigint
AS
BEGIN
	RETURN (select max(id) from TB_ORDER_HDR where fk_order_orderId = @orderId and isVoid = 0)
END
