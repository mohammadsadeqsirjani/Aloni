CREATE PROCEDURE [dbo].[SP_order_cancel]
	 @clientLanguage AS CHAR(2)
	,@clientIp AS VARCHAR(50)
	,@appId as tinyint
	,@userId as bigint
	,@sessionId AS BIGINT
	,@orderId AS BIGINT
	,@storeId as BIGINT
	,@cancelStatus as int = 104


	,@rCode AS TINYINT OUT
	,@rMsg AS NVARCHAR(max) OUT
AS


if(@appId not in (1,3))
begin
set @rMsg =  dbo.func_getSysMsg('error_accessDenied',OBJECT_NAME(@@PROCID),@clientLanguage,'access denied.'); 
goto fail;
end


if(@cancelStatus is null)
set @cancelStatus = 104;

if(@cancelStatus not in (103,104))
begin
set @rMsg =  dbo.func_getSysMsg('error_invalidCancel_Status',OBJECT_NAME(@@PROCID),@clientLanguage,'invalid cancel status.Cancel status must be either 103 or 104.'); 
goto fail;
end

--declare @orderStatus as int;


--select 
--@orderStatus = o.fk_status_statusId
--from TB_ORDER as o
--where o.id = @orderId
--and ((@appId = 1 and o.fk_store_storeId = @storeId) or (@appId = 2 and o.fk_usr_customerId = @userId) or @appId = 3)


--if(@orderStatus is null)
--begin
--set @rMsg =  dbo.func_getSysMsg('error_invalidRequest',OBJECT_NAME(@@PROCID),@clientLanguage,'invalid request'); 
--goto fail;
--end


--if(@orderStatus <> 101)
--begin
--set @rMsg =  dbo.func_getSysMsg('error_invalidCrntStatus',OBJECT_NAME(@@PROCID),@clientLanguage,'وضعیت فعلی سفارش مجاز به لغو نمی باشد.'); 
--goto fail;
--end

begin tran t
begin try

update TB_ORDER
set fk_status_statusId = @cancelStatus --case when @appId = 1 then 104 when @appId = 2 then 103 else fk_status_statusId end
where
id = @orderId
and (fk_store_storeId = @storeId or @appId = 3 )-- (@appId = 2 and fk_usr_customerId = @userId))
and [dbo].[func_getOrderStatus](id,fk_status_statusId,lastDeliveryDateTime) = 101;

--TODO: اسناد حسابداری در صورت وجود بنا به دستور ورودی ریورت شوند و اگر پرداخت غیر نقدی است از حساب فروشنده کسر و به حساب خریدار برگشت شود
if(@@ROWCOUNT <> 1)
begin
rollback tran t;
set @rMsg =  dbo.func_getSysMsg('error_invalidCrntStatus',OBJECT_NAME(@@PROCID),@clientLanguage,'وضعیت فعلی سفارش مجاز به لغو نمی باشد.'); 
goto fail;
end


update TB_STORE_ITEM_QTY
set qty = qty + o.sum_qty
from dbo.func_getOrderDtls(@orderId,null) as o
join TB_STORE_ITEM_QTY as q on q.pk_fk_store_id = @storeId and o.itemId = q.pk_fk_item_id;



commit tran t;
end try
begin catch
rollback tran t;
set @rMsg = ERROR_MESSAGE();
goto fail;
end catch

success:



		   DECLARE @RC int
DECLARE @targetUserId bigint
DECLARE @targetAppId tinyint
DECLARE @targets [dbo].[UDT_pushNotiTargetType]
DECLARE @content varchar(max)
DECLARE @heading varchar(100)
DECLARE @section varchar(20)
DECLARE @action varchar(20)
DECLARE @targetId varchar(20)
DECLARE @par1 varchar(max)
DECLARE @par2 varchar(max)
DECLARE @par3 varchar(max)
DECLARE @par4 varchar(max)
DECLARE @sn_rCode tinyint
DECLARE @sn_rMsg nvarchar(max);





   declare @cstmrId as bigint, @storeTitle as varchar(100),@customerName as varchar(100);

		   select 
		   @cstmrId = cstmr.id,
		   @storeId = o.fk_store_storeId,
		   @storeTitle = s.title,
		   @customerName = isnull(cstmr.fname,'') + ' ' + isnull(cstmr.lname,'')		   
		    from TB_ORDER as o with(nolock) 
			join TB_USR as cstmr with(nolock) on o.fk_usr_customerId = cstmr.id 
			join TB_STORE as s with(nolock) on o.fk_store_storeId = s.id
			where o.id = @orderId


if(@appId = 1)
begin--ارسال نوتی برای اپ خریدار
-- TODO: Set parameter values here.
set @section = 'order';
set @action = 'get';
set @targetUserId = @cstmrId;
set @targetAppId = 2;
set @content = dbo.func_stringFormat_1( dbo.func_getSysMsg('order_cstmr_canceled', OBJECT_NAME(@@PROCID), 'fa', 'سفارش شما از فروشگاه {0} توسط ایشان لغو شد.'),@storeTitle);
set @heading = 'لغو سفارش';
set @targetId = @orderId;
set @par1 = @storeId;
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
end
else if(@appId = 2)
begin--ارسال نوتی برای اپ فروشنده

		
DECLARE @targetStoreId bigint
DECLARE @targetStoreIds [dbo].[LongType]
DECLARE @funcId varchar(100)
DECLARE @spntsu_rCode tinyint
DECLARE @spntsu_rMsg nvarchar(max)

-- TODO: Set parameter values here.
set @targetStoreId = @storeId;
set @funcId = 'MARKETER_ORDER_GETLIST';
set @heading =  'لغو سفارش';
set @content = dbo.func_stringFormat_2( dbo.func_getSysMsg('order_store_canceled', OBJECT_NAME(@@PROCID), 'fa', 'سفارش توسط مشتری {0} لغو شد.'),@customerName,@storeTitle);
set @section = 'order';
set @action = 'get';
set @targetId = @orderId;
set @par1 = @storeId;
EXECUTE @RC = [dbo].[SP_SYS_sendPushNotificationToStoreUsers] 
   @targetStoreId
  ,@targetStoreIds
  ,@funcId
  ,@content
  ,@heading
  ,@section
  ,@action
  ,@targetId
  ,@par1
  ,@par2
  ,@par3
  ,@par4
  ,@spntsu_rCode OUTPUT
  ,@spntsu_rMsg OUTPUT
end






SET @rCode = 1;
SET @rMsg = 'success.';

RETURN 0;

fail:

--ROLLBACK TRAN t1;

SET @rCode = 0;

RETURN 0;