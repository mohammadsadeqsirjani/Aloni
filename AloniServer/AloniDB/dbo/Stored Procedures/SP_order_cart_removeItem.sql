CREATE PROCEDURE [dbo].[SP_order_cart_removeItem]
@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@orderId as bigint,
	@rowId as int,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out
AS




	if(@orderId is null)
	BEGIN
	SET @rMsg = dbo.func_getSysMsg('OrderHdrIdIsRequired', OBJECT_NAME(@@PROCID), @clientLanguage, 'OrderHdrId is required.');
	GOTO fail;
    END


	if(@rowId is null)
	BEGIN
	SET @rMsg = dbo.func_getSysMsg('rowIdIsRequired', OBJECT_NAME(@@PROCID), @clientLanguage, 'rowId is required.');
	GOTO fail;
    END


	if(@appId <> 2)
	begin
		set @rMsg = dbo.func_getSysMsg('error_illegal',OBJECT_NAME(@@PROCID),@clientLanguage,'only customer can do this operation!'); 
		goto fail;
	end

--	declare @cstmrId as bigint,@orderStatusId as int,@orderId as bigint,@dtl_isVoid as int;

--		select @cstmrId = o.fk_usr_customerId,
--		@orderStatusId = o.fk_status_statusId
--		,@orderId = o.id
--		,@dtl_isVoid = d.isVoid
--		from 
--		TB_ORDER_HDR as h
--		join TB_ORDER as o on h.fk_order_orderId = o.id
--		join TB_ORDER_DTL as d on h.id = d.fk_orderHdr_id
--		where h.id = @orderHdrId;



--begin /*بررسی آخرین بودن شماره سند*/
--IF (
--		EXISTS (
--			SELECT 1
--			FROM TB_ORDER_HDR
--			WHERE id > @orderHdrId
--				AND fk_order_orderId = @orderId
--			)
--		)
--BEGIN
--	SET @rMsg = dbo.func_getSysMsg('docUsedAsReference', OBJECT_NAME(@@PROCID), @clientLanguage, 'the target document is used as Reference to another doc.');

--	GOTO fail;
--END
--end;




	--if(@appId = 2 and @cstmrId <> @userId)-- TODO: دسترسی کاربر فروشگاه نیز باید بررسی شود
	--begin
	--	set @rMsg = dbo.func_getSysMsg('illegal',OBJECT_NAME(@@PROCID),@clientLanguage,'you dont have permission!');
	--	goto fail;
	--end




	



	--if((@appId = 2 and @orderStatusId not in (100)) or (@appId = 1 and @orderStatusId not in (100,101) and 1=2))--TODO:  وضعیت های مجاز سفارش برای حذف شدن | برای اپ فروشنده تابع وجود پرداخت برای ردیف نیز باید بررسی شود
	--begin
	--	set @rCode = 0
	--	set @rMsg = dbo.func_getSysMsg('illegalCurrentStatusOfOrder',OBJECT_NAME(@@PROCID),@clientLanguage,'Your order status for the intended operation is not valid.!');
	--	return 0
	--end
	declare @orderStatus as int;

	select @orderStatus = [dbo].[func_getOrderStatus](o.id,o.fk_status_statusId,o.lastDeliveryDateTime)
	from TB_ORDER as o
	join TB_ORDER_DTL as od on o.id = od.fk_order_id
	where o.id = @orderId and od.rowId = @rowId and o.fk_usr_customerId = @userId;

	if(@orderStatus is null or @orderStatus <> 100)
	begin
     	set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('illegalCurrentStatusOfOrder',OBJECT_NAME(@@PROCID),@clientLanguage,'امکان حذف ردیف از سفارش پس از ثبت نهایی صرفا از طریق فروشگاه ممکن می باشد.');
		goto fail;
	end



		begin try
	begin tran t1;


		update TB_ORDER_DTL
	    set isVoid = 1 --fk_status_id = 41,qty = case when sum_qty >= 0 then  -1 * sum_qty else sum_qty end
	    where fk_order_id = @orderId and rowId = @rowId;



	--if((select COUNT(id) from TB_ORDER_DTL where fk_order_id = @orderId and isVoid = 0) < 1) --and (select fk_item_id from TB_ORDER_DTL where fk_orderHdr_id = @orderHdrId) = @itemId)
	--begin -- cancel the cart
	--	update TB_ORDER
	--	set fk_status_statusId = 103 -- case when @appId = 2 then 103 else 104 end
	--	where id = @orderId;
	--end





	if((select isnull(sum(qty),0) from TB_ORDER_DTL where fk_order_id = @orderId and isVoid = 0) <= 0)
	begin -- cancel the cart
	   
	    
		exec [dbo].[SP_SYS_order_cart_delete]
		@orderId = @orderId
		,@rCode = @rCode output
		,@rMsg = @rMsg output
		--update TB_ORDER
		--set fk_status_statusId = 103 -- case when @appId = 2 then 103 else 104 end
		--where id = @orderId;
	end



	--if(@@ROWCOUNT <> 1)
	--begin
	--	set @rCode = 0
	--	set @rMsg = dbo.func_getSysMsg('Errore',OBJECT_NAME(@@PROCID),@clientLanguage,'order not exists or item in order not exists!');
	--	return 0
	--end

	--DECLARE	@return_value_SP_calcOrderValues int,
	--	@rCode_SP_calcOrderValues tinyint,
	--	@rMsg_SP_calcOrderValues nvarchar(max);
	--EXEC	@return_value_SP_calcOrderValues = [dbo].[SP_calcOrderValues]
	--	@orderHdrId = @orderHdrId,
	--	@clientLanguage = @clientLanguage,
	--	@rCode = @rCode_SP_calcOrderValues OUTPUT,
	--	@rMsg = @rMsg_SP_calcOrderValues OUTPUT;

commit tran t1;
end try
begin catch
rollback tran t1;
set @rMsg = ERROR_MESSAGE();
end catch


success:

SET @rCode = 1;
SET @rMsg = 'success.';

RETURN 0;

fail:

--ROLLBACK TRAN t1;

SET @rCode = 0;

RETURN 0;