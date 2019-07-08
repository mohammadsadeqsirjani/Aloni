CREATE PROCEDURE [dbo].[SP_order_cart_remove]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@orderId as bigint,
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out
AS
	


	if(@orderId is null)
	begin
	 SET @rMsg = dbo.func_getSysMsg('invalidRequest_orderIdIsRequired', OBJECT_NAME(@@PROCID), @clientLanguage, 'invalid request: orderId is required.');
 	 GOTO fail;
	end
	if(@appId <> 2)
	begin
	set @rMsg = dbo.func_getSysMsg('error_illegal',OBJECT_NAME(@@PROCID),@clientLanguage,'only customer can do this operation!'); 
		goto fail;
	end

	--declare @orderStatus as int;


	--select @orderStatus = o.fk_status_statusId 
	--from TB_ORDER as o
	--where id = @orderId and o.fk_usr_customerId = @userId;

	--if(@orderStatus is null)
	--begin
	--end

	update TB_ORDER set
	fk_status_statusId = 110
	where id = @orderId and fk_usr_customerId = @userId and [dbo].[func_getOrderStatus](id,fk_status_statusId,lastDeliveryDateTime) in (100,110)

	if(@@ROWCOUNT <> 1)
	begin
	set @rMsg = dbo.func_getSysMsg('cannotRemoveCart',OBJECT_NAME(@@PROCID), @clientLanguage, 'امکان حذف این سبد خرید وجود ندارد.');
	 GOTO fail;
	end










success:

SET @rCode = 1;
SET @rMsg = 'success.';
RETURN 0;
fail:
SET @rCode = 0;
RETURN 0;