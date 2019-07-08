CREATE PROCEDURE [dbo].[SP_order_correspondenceAdd]
	 @clientLanguage AS CHAR(2)
	,@appId AS TINYINT
	,@clientIp AS VARCHAR(50)
	,@userId AS BIGINT
	,@sessionId as bigint
	,@storeId AS BIGINT 
	,@isTicket as bit
	,@orderId AS bigint
	,@message as text
	--todo : staffId از ورودی و خروجی رویه آتنتیکیت یوزر باید تغذیه شود بجای آنکه داخل این رویه مجددا سلکت شود

	,@rCode AS TINYINT OUT
	,@rMsg AS NVARCHAR(max) OUT
AS






if(not exists(select 1 from TB_ORDER as o with(nolock) where o.id = @orderId and [dbo].[func_getOrderStatus](o.id,o.fk_status_statusId,o.lastDeliveryDateTime) <> 100 and 
((@appId = 1 and o.fk_store_storeId = @storeId) or (@appId = 3) or (@appId = 2 and o.fk_usr_customerId = @userId))))
begin
set @rMsg = dbo.func_getSysMsg('@invalidRequest',OBJECT_NAME(@@PROCID),@clientLanguage,'invalid request.');
goto fail;
end

declare @senderStaffId as smallint;
select 
@senderStaffId = us.fk_staff_id
from TB_USR_STAFF as us with(nolock)
where (@appId = 1 and us.fk_usr_id = @userId and us.fk_store_id = @storeId and us.fk_status_id = 8) or (@appId = 3 and us.fk_usr_id = @userId and us.fk_status_id = 37);

INSERT INTO [dbo].[TB_ORDER_CORRESPONDENCE]
           ([fk_order_orderId]
           ,[fk_usr_senderUserId]
           ,[fk_usr_Session_senderSessionId]
           ,[message]
           ,[saveDateTime]
           ,[saveIp]
           ,[isTicket]
           ,[isDeleted]
		   ,[fk_staff_senderStaffId])
     VALUES
           (@orderId
           ,@userId
           ,@sessionId
           ,@message
           ,getdate()
           ,@clientIp
           , case when @appId = 2 then 1 else @isTicket end 
           ,0
		   ,@senderStaffId);





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


		   if(@appId = 1 and @isTicket = 1)
		   begin--برای اپ خریدار اعلان ارسال شود


-- TODO: Set parameter values here.
set @section = 'order_correspondence';
set @action = 'get';
set @targetUserId = @cstmrId;
set @targetAppId = 2;
set @content = dbo.func_stringFormat_1( dbo.func_getSysMsg('order_cstmr_correspondence_newTicket', OBJECT_NAME(@@PROCID), 'fa', 'پیغام جدیدی از سوی فروشگاه {0} در ارتباط با سفارش شما دریافت شد.'),@storeTitle);
set @heading = 'آلونی';
set @targetId = @orderId;
set @par1 = SCOPE_IDENTITY();
set @par2 = @storeTitle;

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
		   if(@appId = 2)
		   begin-- برای اپ فروشنده اعلان ارسال شود


		
DECLARE @targetStoreId bigint
DECLARE @targetStoreIds [dbo].[LongType]
DECLARE @funcId varchar(100)
DECLARE @spntsu_rCode tinyint
DECLARE @spntsu_rMsg nvarchar(max)

-- TODO: Set parameter values here.
set @targetStoreId = @storeId;
set @funcId = 'MARKETER_ORDER_CORRESPONDENCE_GETLIST';
set @heading =  'تیکت جدید';
set @content = dbo.func_stringFormat_2( dbo.func_getSysMsg('order_store_correspondence_newTicket', OBJECT_NAME(@@PROCID), 'fa', 'تیکت جدید از سوی مشتری {0} برای فروشگاه {1} دریافت شده است.'),@customerName,@storeTitle);
set @section = 'order_correspondence';
set @action = 'get';
set @targetId = @orderId;
set @par1 = @storeTitle;--SCOPE_IDENTITY();
set @par2 = @customerName;
set @par3 = @storeId;
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

SET @rCode = 0;

RETURN 0;