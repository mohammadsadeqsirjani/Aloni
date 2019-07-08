CREATE FUNCTION [dbo].[func_getMaxRowIdOfOrder]
(
	@orderHdrId as bigint
)
RETURNS INT
AS
BEGIN
declare @o as int;
	 select @o = max(rowId) from TB_ORDER_DTL where fk_orderHdr_id = @orderHdrId;
	 return @o;
END
