CREATE PROCEDURE [dbo].[SP_order_package_receive]
(
	 @clientLanguage AS CHAR(2)
	,@appId as tinyint
	,@clientIp AS VARCHAR(50)
	,@userId as bigint

	,@orderId as bigint
	,@sessionId as bigint
	--,@storeId as bigint
	--,@setAllDelivered as bit--تمامی اقلام سفارش تحویل شده اند
	,@setAllDeliveredPackagesReceived as bit--تمامی بسته های تحویلی دریافت شده اند
	,@packageIds as [dbo].[UDT_order_package_receiveType] readonly

	,@rCode AS TINYINT OUT
	,@rMsg AS NVARCHAR(max) OUT
)
AS


--if(@setAllSentPackagesDelivered is null)
--begin
--set @rMsg = dbo.func_getSysMsg('@setAllDeliveredIsNull',OBJECT_NAME(@@PROCID),@clientLanguage,'setAllDelivered cannot be null.');
--goto fail;
--end

if(isnull(@setAllDeliveredPackagesReceived,0) = 0 and not exists (select 1 from @packageIds))
begin
set @rMsg = dbo.func_getSysMsg('packageShouldHaveOneRowAtLeast',OBJECT_NAME(@@PROCID),@clientLanguage,'packageIds Should Have One Id At Least');
goto fail;
end

declare-- @remainingPayable as money
--,@sum_sendRemaining as money
@orderStatusId as int
,@customerId as bigint
,@storeTitle as varchar(100)
,@storeId as bigint

select @orderStatusId = dbo.func_getOrderStatus(o.id,o.fk_status_statusId,o.lastDeliveryDateTime)
,@customerId = o.fk_usr_customerId
,@storeTitle = s.title
,@storeId = o.fk_store_storeId
from TB_ORDER as o
join TB_STORE as s with(nolock)  on o.fk_store_storeId = s.id
where o.id = @orderId;

if(@orderStatusId is null)
begin
set @rMsg = dbo.func_getSysMsg('error_invalidOrderId',OBJECT_NAME(@@PROCID),@clientLanguage,'error : orderId is not valid');
goto fail;
end


if(@orderStatusId not in (101,102))
begin
set @rMsg = dbo.func_getSysMsg('error_illegalOrderStatus',OBJECT_NAME(@@PROCID),@clientLanguage,'خطا: وضعیت فعلی سفارش مجاز به انجام این عملیات نمی باشد.');
goto fail;
end

--select @remainingPayable = isnull(total_remaining_payment_payable,0),
--@sum_sendRemaining = sum_sendRemaining
--from dbo.func_getOrderHdrs(@orderId);

--if(@setAllDeliveredPackagesReceived = 1 and @sum_sendRemaining <=0 and @remainingPayable > 0)
--begin
--set @rMsg = dbo.func_getSysMsg('orderIsNorPaidCompletely',OBJECT_NAME(@@PROCID),@clientLanguage,'خطا: امکان تکمیل سفارش قبل از پرداخت کامل هزینه آن ممکن نمی باشد.');
--goto fail;
--end







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
           ,16--دریافت بسته از فروشگاه
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

		   declare @rowId as int,@itemId as bigint,@colorId as varchar(20),@sizeId as varchar(500),@warrantyId as bigint,@received as money;


if(isnull(@setAllDeliveredPackagesReceived,0) = 1)--تمامی بسته های تحویلی دریافت شوند
begin

declare c_dtls cursor for
select 
d.rowId
,d.itemId
,d.colorId
,d.sizeId
,d.warrantyId
,isnull(d.deliveredRemainingToReceive,0)
from dbo.func_getOrderDtls(@orderId,null) as d
where isnull(d.deliveredRemainingToReceive,0) > 0
open c_dtls;

fetch next from c_dtls into
@rowId,@itemId,@colorId,@sizeId,@warrantyId,@received;

if(@@FETCH_STATUS <> 0)
begin
close c_dtls;
deallocate c_dtls;
rollback tran t;
set @rMsg = dbo.func_getSysMsg('error_noRemainingToReceive',OBJECT_NAME(@@PROCID),@clientLanguage,'خطا: تمامی اقلام تحویل شده قبلا دریافت شده اند.');
goto fail;
end

while (@@FETCH_STATUS = 0)
begin
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
		   ,[received]
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
           ,0
		   ,0
		   ,@received
           ,0);


		   fetch next from c_dtls into
@rowId,@itemId,@colorId,@sizeId,@warrantyId,@received;
end
close c_dtls;
deallocate c_dtls;


end
else--بسته های ورودی تحویل شوند
begin



select 1
from TB_ORDER_HDR as oh
left join @packageIds as pis on oh.id = pis.packageId
where oh.id = @orderId and oh.fk_docType_id = 14 and isVoid = 0

end

declare @sum_receiveRemaining as money;

select --@remainingPayable = isnull(total_remaining_payment_payable,0),
@sum_receiveRemaining = sum_deliveredRemainingToReceive--TODO: در زمان سفارشات چند بخشی اصلاح شود.
from dbo.func_getOrderHdrs(@orderId);

--if(@sum_deliveryRemaining <=0)
--begin
--	if(@remainingPayable > 0)
--	begin
--		rollback tran t;
--		set @rMsg = dbo.func_getSysMsg('orderIsNorPaidCompletely',OBJECT_NAME(@@PROCID),@clientLanguage,'خطا: امکان تکمیل سفارش قبل از پرداخت کامل هزینه آن ممکن نمی باشد.');
--		goto fail;
--	end

----update TB_ORDER
----set fk_status_statusId = 102
------lastDeliveryDateTime = GETDATE()
----where id = @orderId;
--set @orderStatusId = 102;

--end





--update TB_ORDER
--set fk_status_statusId = case when @orderStatusId = 102 then 102 else fk_status_statusId end,
--lastDeliveryDateTime = GETDATE()
--where id = @orderId;

commit tran t;
end try
begin catch
rollback tran t;
set @rMsg = ERROR_MESSAGE();
goto fail;
end catch









--DECLARE @RC int
--DECLARE @targetUserId bigint
--DECLARE @targetAppId tinyint
--DECLARE @targets [dbo].[UDT_pushNotiTargetType]
--DECLARE @content varchar(max)
--DECLARE @heading varchar(100)
--DECLARE @section varchar(20)
--DECLARE @action varchar(20)
--DECLARE @targetId varchar(20)
--DECLARE @par1 varchar(max)
--DECLARE @par2 varchar(max)
--DECLARE @sn_rCode tinyint
--DECLARE @sn_rMsg nvarchar(max)

---- TODO: Set parameter values here.
--set @section = 'order_package';
--set @action = 'get';
--set @targetUserId = @customerId;
--set @targetAppId = 2;
--set @content = dbo.func_stringFormat_1( dbo.func_getSysMsg('noti_newOrder_content', OBJECT_NAME(@@PROCID), 'fa', 'بسته سفارش شما از فروشگاه {0} تحویل شد. سفارش شما ظرف 72 ساعت آینده خاتمه می یابد.'),@storeTitle);
--set @heading = 'آلونی';
--set @targetId = @orderId;
--set @par1 = @orderHdrId;

--EXECUTE @RC = [dbo].[SP_SYS_sendPushNotification] 
--   @targetUserId
--  ,@targetAppId
--  ,@targets
--  ,@content
--  ,@heading
--  ,@section
--  ,@action
--  ,@targetId
--  ,@par1
--  ,@par2
--  ,@sn_rCode OUTPUT
--  ,@sn_rMsg OUTPUT














SET @rCode = 1;
SET @rMsg = 'success.';

RETURN 0;

fail:

SET @rCode = 0;

RETURN 0;