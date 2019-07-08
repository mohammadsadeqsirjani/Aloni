CREATE PROCEDURE [dbo].[SP_order_correspondence_ticket_setAsControlled]
	@clientLanguage AS CHAR(2)
	,@clientIp AS VARCHAR(50)
	,@appId as tinyint
	,@userId as bigint
	,@sessionId AS BIGINT
	,@storeId AS BIGINT 
	,@orderId as bigint
	,@ticketId as bigint

	,@rCode AS TINYINT OUT
	,@rMsg AS NVARCHAR(max) OUT

AS
	
	if(@appId = 1)
	begin

	update TB_ORDER_CORRESPONDENCE
	set controlDateTime = GETDATE()
	where id in
	(select oc.id from TB_ORDER_CORRESPONDENCE as oc with(nolock)
	  join TB_ORDER as o with(nolock) on oc.fk_order_orderId = o.id
      where o.id = @orderId and o.fk_store_storeId = @storeId and oc.id <= @ticketId and oc.controlDateTime is null and oc.fk_usr_senderUserId = o.fk_usr_customerId )

	  end

success:
SET @rCode = 1;
SET @rMsg = 'success.';
RETURN 0;
fail:
SET @rCode = 0;
RETURN 0;
