CREATE PROCEDURE [dbo].[SP_SYS_order_cart_delete]
    

    @orderId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out
AS


--begin tran t
--begin try
delete from TB_ORDER_DTL_BASE where orderId = @orderId;
delete from TB_ORDER_DTL where fk_order_id = @orderId;
delete from TB_ORDER_HDR_BASE where orderId = @orderId;
delete from TB_ORDER_HDR where fk_order_orderId = @orderId;
delete from TB_ORDER where id = @orderId;-- and fk_status_statusId = 100;

--commit tran t
--end try

--begin catch
----rollback tran t;
--set @rMsg = ERROR_MESSAGE();
--goto fail;
--end catch


success:

SET @rCode = 1;
SET @rMsg = 'success.';

RETURN 0;

fail:

--ROLLBACK TRAN t1;

SET @rCode = 0;

RETURN 0;
