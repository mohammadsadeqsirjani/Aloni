CREATE PROCEDURE [dbo].[SP_order_package_send]
(
	 @clientLanguage AS CHAR(2)
	,@appId as tinyint
	,@clientIp AS VARCHAR(50)
	,@userId as bigint

	,@orderId as bigint
	,@sessionId as bigint
	,@storeId as bigint
	,@setAllSent as bit
	,@package as [dbo].[UDT_order_packageSendType] readonly
	,@ignoreIfOrderIsNotPaid as bit


	,@rCode AS TINYINT OUT
	,@rMsg AS NVARCHAR(max) OUT
)
AS


if(@setAllSent is null)
begin
set @rMsg = dbo.func_getSysMsg('@setAllsetAllSentIsNull',OBJECT_NAME(@@PROCID),@clientLanguage,'setAllsetAllSent cannot be null.');
goto fail;
end

if(@setAllSent = 0 and not exists (select 1 from @package))
begin
set @rMsg = dbo.func_getSysMsg('packageShouldHaveOneRowAtLeast',OBJECT_NAME(@@PROCID),@clientLanguage,'package Should Have One Row At Least');
goto fail;
end


declare @total_remaining_payment_payable as money;

select @total_remaining_payment_payable = total_remaining_payment_payable 
from dbo.func_getOrderHdrs(@orderId)


if(isnull(@ignoreIfOrderIsNotPaid,0) = 0 and @setAllSent = 1 and @total_remaining_payment_payable>0)
begin
set @rMsg = dbo.func_getSysMsg('orderIsNotPaid',OBJECT_NAME(@@PROCID),@clientLanguage,'هزینه سفارش پرداخت نشده است.');
goto fail;
end




declare
 @rowId as int
,@sendRemaining as money
,@sendQty as money
,@itemId as bigint
,@colorId as varchar(20)
,@sizeId as varchar(500)
,@warrantyId as bigint

,@customerId as bigint
,@storeTitle as varchar(100);
select @customerId = fk_usr_customerId,@storeTitle = s.title
 from TB_ORDER as o with(nolock) join TB_STORE as s with(nolock) on o.fk_store_storeId = s.id
 where o.id = @orderId  and o.fk_store_storeId = @storeId;


declare c_rows cursor
for
select
 dtl.rowId
 ,dtl.sendRemaining
 ,case when @setAllSent = 1 then dtl.sendRemaining else isnull(pck.sendQty,0) end as sendQty
 ,dtl.itemId
 ,dtl.colorId
 ,dtl.sizeId
 ,dtl.warrantyId
from dbo.func_getOrderDtls(@orderId,null) as dtl
join TB_ORDER as o on dtl.orderId = o.id
left join @package as pck on dtl.rowId = pck.rowId
where [dbo].[func_getOrderStatus](o.id,o.fk_status_statusId,o.lastDeliveryDateTime) = 101 and o.fk_store_storeId = @storeId;

open c_rows;
fetch next from c_rows into @rowId,@sendRemaining,@sendQty,@itemId,@colorId,@sizeId,@warrantyId;

if(@@FETCH_STATUS <> 0)
begin
close c_rows;
deallocate c_rows;
--rollback tran t;
set @rMsg = dbo.func_getSysMsg('invalidRequest',OBJECT_NAME(@@PROCID),@clientLanguage,'اطلاعات ورودی صحیح نمی باشد.');
goto fail;
end



begin try
begin tran t;

declare @orderHdrId as bigint,@noRow as bit;
set @noRow = 1;

INSERT INTO [dbo].[TB_ORDER_HDR]
           ([fk_order_orderId]
           ,[fk_docType_id]
           ,[saveDateTime]
           ,[fk_usrSession_id]
           ,[saveIp]
           --,[fk_deliveryTypes_id]
           --,[deliveryLoc]
           --,[deliveryAddress]
           --,[fk_state_deliveryStateId]
           --,[fk_city_deliveryCityId]
           --,[delivery_postalCode]
           --,[delivery_callNo]
           --,[onlinePaymentId]
           --,[fk_paymentPortal_id]
           ,[isVoid]
		   ,[fk_staff_operatorStaffId])
     VALUES
           (@orderId
           ,7--ارسال بسته به مشتری
           ,getdate()
           ,@sessionId
           ,@clientIp
           --,null
           --,null
           --,null
           --,null
           --,null
           --,null
           --,null
           --,null
           --,null
           ,0
		   ,[dbo].[func_GetUserStaff](@userId,@storeId,@appId));


		   set @orderHdrId = SCOPE_IDENTITY();





while @@FETCH_STATUS = 0
begin

if(@sendQty > @sendRemaining)
begin
close c_rows;
deallocate c_rows;
rollback tran t;
set @rMsg = dbo.func_stringFormat_1(dbo.func_getSysMsg('invalidSendQty',OBJECT_NAME(@@PROCID),@clientLanguage,'مقدار تحویل ردیف {0} از حداکثر مانده قابل تحویل این ردیف بیشتر است.'),@rowId);
goto fail;
end

if(@sendQty > 0)
begin
set @noRow = 0;
INSERT INTO [dbo].[TB_ORDER_DTL]
           ([fk_order_id]
           ,[fk_orderHdr_id]
           ,[rowId]
           ,[fk_store_id]
           ,[fk_item_id]
           ,[vfk_store_item_color_id]
           ,[vfk_store_item_size_id]
           ,[vfk_store_item_warranty]
           ,[qty]
		   ,[sent]
           ,[delivered]
           ,[isVoid])
     VALUES
           (@orderId
           ,@orderHdrId
           ,@rowId
           ,@storeId
           ,@itemId
           ,@colorId
           ,@sizeId
           ,@warrantyId
           ,0
           ,@sendQty
		   ,0
           ,0);

end



fetch next from c_rows into @rowId,@sendRemaining,@sendQty,@itemId,@colorId,@sizeId,@warrantyId;
end--of while

close c_rows;
deallocate c_rows;



if(@noRow <> 0)
begin
rollback tran t;
set @rMsg = dbo.func_getSysMsg('@allDeliveredAlready',OBJECT_NAME(@@PROCID),@clientLanguage,'تمامی اقلام سفارش قبلا تحویل شده اند.');;
goto fail;
end

declare @sum_sendRemaining as money;
select @sum_sendRemaining = sum_sendRemaining from dbo.func_getOrderHdrs(@orderId);

if(isnull(@ignoreIfOrderIsNotPaid,0) = 0 and @sum_sendRemaining <= 0 and @total_remaining_payment_payable > 0)
begin
rollback tran t;
set @rMsg = dbo.func_getSysMsg('orderIsNotPaid',OBJECT_NAME(@@PROCID),@clientLanguage,'هزینه سفارش پرداخت نشده است.');
goto fail;
end




commit tran t;
end try
begin catch
rollback tran t;
set @rMsg = ERROR_MESSAGE();
goto fail;
end catch



DECLARE @RC int
DECLARE @targetUserId bigint
DECLARE @targetAppId tinyint
DECLARE @targets [dbo].[UDT_pushNotiTargetType]
DECLARE @content varchar(max)
DECLARE @heading varchar(100)
DECLARE @section varchar(50)
DECLARE @action varchar(20)
DECLARE @targetId varchar(20)
DECLARE @par1 varchar(max)
DECLARE @par2 varchar(max)
DECLARE @par3 varchar(max)
DECLARE @par4 varchar(max)
DECLARE @sn_rCode tinyint
DECLARE @sn_rMsg nvarchar(max)

-- TODO: Set parameter values here.
set @section = 'order_package_send';
set @action = 'get';
set @targetUserId = @customerId;
set @targetAppId = 2;
set @content = dbo.func_stringFormat_1( dbo.func_getSysMsg('noti_order_package_sent', OBJECT_NAME(@@PROCID), 'fa', 'بسته سفارش شما از فروشگاه {0} ارسال شد.'),@storeTitle);
set @heading = 'آلونی';
set @targetId = @orderId;
set @par1 = @orderHdrId;

EXECUTE @RC = [dbo].[SP_SYS_sendPushNotification] 
   @targetUserId
  ,@targetAppId
  ,@targets
  ,@content
  ,@heading
  ,@section
  ,@action
  ,@targetId
  ,@par1
  ,@par2
  ,@par3
  ,@par4
  ,@sn_rCode OUTPUT
  ,@sn_rMsg OUTPUT







SET @rCode = 1;
SET @rMsg = 'success.';

RETURN 0;

fail:

SET @rCode = 0;

RETURN 0;