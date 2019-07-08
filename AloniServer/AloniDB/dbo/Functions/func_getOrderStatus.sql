CREATE FUNCTION [dbo].[func_getOrderStatus]
(
	@orderId as bigint,
	@status as int,
	@lastDeliveryDateTime as datetime
)
RETURNS INT
AS
BEGIN
if(@status is null)
begin
	select @status = fk_status_statusId from TB_ORDER where id =  @orderId;
end

	if(@status is null or @status <> 102)
	  return @status;

	  if(@lastDeliveryDateTime is null)
	  begin
			  --declare @lastDeliveryDateTime as datetime;--,@sum_deliveryRemaining as money;
			  select top(1) 
			  @lastDeliveryDateTime = saveDateTime
			  from TB_ORDER_HDR as h with(nolock) where fk_order_orderId = @orderId and fk_docType_id = 14 and isVoid = 0
			  order by id desc
	  end

	  --select @sum_deliveryRemaining = h.sum_deliveryRemaining
	  --from dbo.func_getOrderHdrs(@orderId) as h;


	  --TODO: زمان باید به ازای فروشگاه / حوزه فعالیت مشخص شود
	  if(DATEDIFF(hour,@lastDeliveryDateTime,GETDATE()) > 72)--@sum_deliveryRemaining <= 0 and)   
	     return 105; 

	 return @status;

END
