CREATE PROCEDURE [dbo].[SP_order_update]
	 @clientLanguage AS CHAR(2)
	,@clientIp AS VARCHAR(50)
	,@appId as tinyint
	,@userId as bigint
	,@sessionId AS BIGINT
	,@orderId AS BIGINT
	,@storeId as BIGINT
	,@inputDtls as [dbo].[UDT_order_dtl] readonly
	,@rCode AS TINYINT OUT
	,@rMsg AS NVARCHAR(max) OUT
AS

declare @orderChanged as bit;
set @orderChanged = 0;

declare @orderStatus as int,@totalPaid as money;


select @orderStatus = [dbo].[func_getOrderStatus](o.id,o.fk_status_statusId,o.lastDeliveryDateTime),@totalPaid = ohs.total_paid
from TB_ORDER as o with(nolock)
join func_getOrderHdrs(@orderId) as ohs on o.id = ohs.orderId
where o.fk_store_storeId = @storeId;

if(@orderStatus is null)
begin
set @rMsg =  dbo.func_getSysMsg('error_invalidRequest',OBJECT_NAME(@@PROCID),@clientLanguage,'invalid request'); 
goto fail;
end

if(@orderStatus <> 101)
begin
set @rMsg =  dbo.func_getSysMsg('error_invalidOrderStatus',OBJECT_NAME(@@PROCID),@clientLanguage,'وضعیت سفارش مجاز به ویرایش نمی باشد.'); 
goto fail;
end

if(@totalPaid is not null and @totalPaid > 0)
begin
set @rMsg =  dbo.func_getSysMsg('error_orderPaid',OBJECT_NAME(@@PROCID),@clientLanguage,'امکان ویرایش اطلاعات سفارش پس از پرداخت وجود ندارد.'); 
goto fail;
end


if(not exists(select 1 from @inputDtls))
begin
set @rMsg =  dbo.func_getSysMsg('error_inputDtlsCannotBeEmpty',OBJECT_NAME(@@PROCID),@clientLanguage,'error: input dtl list cannot be empty'); 
goto fail;
end


if(exists(select 1 from @inputDtls where qty <= 0))
begin
set @rMsg =  dbo.func_getSysMsg('error_qtyCannotBeLessOrEqualZero ',OBJECT_NAME(@@PROCID),@clientLanguage,'qty must be a positive value.'); 
goto fail;
end



declare @existingDtls as [dbo].[UDT_func_getOrderDtlsTableType];

insert into  @existingDtls
select 
orderId ,
	rowId ,
	sum_qty ,
	sum_sent,
	sendRemaining,
	sum_delivered ,
	deliveryRemaining ,
	sentRemainingToDelivery,
	sumPaid ,
	discount_minCnt ,
	cost_oneUnit_withoutDiscount ,
	discount_percent ,
	cost_oneUnit_withDiscount ,
	cost_warranty ,
	cost_payable_withoutTax ,
	store_taxIncludedInPrices ,
	store_calculateTax ,
	item_includedTax ,
	taxRate ,
	cost_totalTax_included  ,
	cost_payable_withTax_withDiscount ,
	cost_payable_withTax_withDiscount_remaining , 
	cost_totalTax_info  ,
	cost_payable_withoutTax_withoutDiscount , 
	cost_totalTax_included_withoutDiscount ,
	cost_payable_withTax_withoutDiscount  ,
	cost_discount ,
	prepaymentPercent ,
	cost_prepayment ,
	cancellationPenaltyPercent ,
	cost_cancellationPenalty  ,
	cost_prepayment_remaining  ,
	itemId ,
	colorId ,
	sizeId ,
	warrantyId 
	--وlastOrderDtlId 
from dbo.func_getOrderDtls(@orderId,null);


if(not exists(select 1 from @existingDtls))
begin
set @rMsg =  dbo.func_getSysMsg('error_invalidOrderId',OBJECT_NAME(@@PROCID),@clientLanguage,'invalid order Id'); 
goto fail;
end



begin tran t;
begin try



declare @newOrderHdrId as bigint,@newOrderDtlRowId as int;

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
           ,15
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
set @newOrderHdrId = SCOPE_IDENTITY();
select @newOrderDtlRowId = max(rowId) from TB_ORDER_DTL where fk_order_id = @orderId;




	declare
	@itemId as bigint,
	@warrantyId as bigint,
	@colorId as varchar(20),
	@sizeId as varchar(500),
	@qty as money;


	declare
	@rowId as int,
	@sumQty as money;


	declare
	@itemTitle as varchar(150),
	@soh as money,
	@canBePurchasedWithoutWarranty as bit,
	@cost_warranty as money,
	@warrantyDays as int,
	@cost_oneUnit_withoutDiscount as money,
	@discount_minCnt as int,
	@discount_percent as money,
	@taxRate as money,
	@item_includedTax as bit,
	@store_calculateTax as bit,
	@prepaymentPercent as money,
	@cancellationPenaltyPercent as money,
	@validityTimeOfOrder as int,
	@isSecurePayment as bit,
	@store_taxIncludedInPrices as bit,

	@siq_isNotForSelling as bit,
	@siq_fk_status_id as int,
	@siw_isActive as bit,
	@sic_isActive as bit,
	@sis_isActive as bit,

	@sw_title as varchar(max),
	@sic_title as varchar(max),
	@sis_title as varchar(max);


	declare @store_promo_discount_percent as money,
	@store_promo_dsc as varchar(max);


	select top (1) @store_promo_discount_percent = sp.promotionPercent,
				@store_promo_dsc =  sp.promotionDsc
				from TB_STORE_PROMOTION as sp
				where sp.fk_store_id = @storeId and sp.isActive = 1
				order by id desc;



--newly added rows
declare c_added cursor
for
select
 inputDtls.itemId
,inputDtls.warrantyId
,inputDtls.colorId
,inputDtls.sizeId
,inputDtls.qty
,siq.qty as soh
,isnull(itm_trn.title,itm.title) as itemTitle
,siq.canBePurchasedWithoutWarranty
,isnull(siw.warrantyCost,0) as warrantyCost
,isnull(siw.warrantyDays,0) as warrantyDays
,siq.price
,siq.discount_minCnt
,siq.discount_percent
,s.taxRate
,siq.includedTax
,s.calculateTax
,siq.prepaymentPercent
,siq.cancellationPenaltyPercent
,siq.validityTimeOfOrder
,case when s.fk_securePayment_StatusId = 13 then 1 else 0 end
,s.taxIncludedInPrices
,siq.isNotForSelling
,siq.fk_status_id
,siw.isActive
,sic.isActive
,sis.isActive
,sw.title
,isnull(c_trn.title, c.title)
,sis.pk_sizeInfo
from @inputDtls as inputDtls
join TB_STORE_ITEM_QTY as siq on inputDtls.itemId = siq.pk_fk_item_id and siq.pk_fk_store_id = @storeId
join TB_STORE as s on s.id = @storeId
join TB_ITEM as itm on inputDtls.itemId = itm.id
left join TB_ITEM_TRANSLATIONS as itm_trn on inputDtls.itemId = itm_trn.id and itm_trn.lan = @clientLanguage
left join TB_STORE_ITEM_WARRANTY as siw on inputDtls.warrantyId = siw.pk_fk_storeWarranty_id and inputDtls.itemId = siw.pk_fk_item_id and siw.pk_fk_store_id = @storeId
left join TB_STORE_WARRANTY as sw with(nolock) on inputDtls.warrantyId = sw.id and sw.fk_store_id = @storeId
left join TB_STORE_ITEM_COLOR as sic on inputDtls.colorId = sic.fk_color_id and inputDtls.itemId = sic.pk_fk_item_id and sic.pk_fk_store_id = @storeId
left join TB_COLOR as c with(nolock)  on inputDtls.colorId = c.id
left join TB_COLOR_TRANSLATIONS as c_trn with(nolock) on inputDtls.colorId = c_trn.id and c_trn.lan = @clientLanguage
left join TB_STORE_ITEM_SIZE as sis on inputDtls.sizeId = sis.pk_sizeInfo and inputDtls.itemId = sis.pk_fk_item_id and sis.pk_fk_store_id = @storeId
left join @existingDtls as existingDtls
on inputDtls.itemId = existingDtls.itemId
and (inputDtls.warrantyId = existingDtls.warrantyId or (inputDtls.warrantyId is null and existingDtls.warrantyId is null))
and (inputDtls.colorId = existingDtls.colorId or (inputDtls.colorId is null and existingDtls.colorId is null))
and (inputDtls.sizeId = existingDtls.sizeId or (inputDtls.sizeId is null and existingDtls.sizeId is null))
where existingDtls.rowId is null;

open c_added;
fetch next from c_added into 
 @itemId
,@warrantyId
,@colorId
,@sizeId
,@qty
,@soh
,@itemTitle
,@canBePurchasedWithoutWarranty
,@cost_warranty
,@warrantyDays
,@cost_oneUnit_withoutDiscount
,@discount_minCnt
,@discount_percent
,@taxRate
,@item_includedTax
,@store_calculateTax
,@prepaymentPercent
,@cancellationPenaltyPercent
,@validityTimeOfOrder
,@isSecurePayment
,@store_taxIncludedInPrices
,@siq_isNotForSelling
,@siq_fk_status_id
,@siw_isActive
,@sic_isActive
,@sis_isActive
,@sw_title
,@sic_title
,@sis_title
while (@@FETCH_STATUS = 0)
begin
set @orderChanged = 1;
--بررسی موجودی فروشگاه
if([dbo].[func_controlInventory](@storeId,@itemId) = 1 and @soh < @qty)--TODO: ارور کد مربوطه در خروجی سرویس بیاید که اپ فرم تنظیمات موجودی را باز کند
begin
close c_added;
deallocate c_added;
rollback tran t;
set @rMsg =dbo.func_stringFormat_2(dbo.func_getSysMsg('error_sohIsNotEnough',OBJECT_NAME(@@PROCID),@clientLanguage,'با عرض پوزش ، موجودی کالای "{0}" کافی نمی باشد. موجودی فعلی : {1}'),@itemTitle,@soh); 
		goto fail;
end


--بررسی قابل فروش بودن کالا
if(@siq_isNotForSelling = 1)
begin
close c_added;
deallocate c_added;
rollback tran t;
set @rMsg =dbo.func_stringFormat_1(dbo.func_getSysMsg('error_itemIsNotForCell',OBJECT_NAME(@@PROCID),@clientLanguage,'کالای "{0}" قابل فروش نمی باشد.'),@itemTitle); 
		goto fail;
end

--بررسی وضعیت کالا در فروشگاه
if(@siq_fk_status_id <> 15)
begin
close c_added;
deallocate c_added;
rollback tran t;
set @rMsg =dbo.func_stringFormat_1(dbo.func_getSysMsg('error_selectedItemIsNotActive',OBJECT_NAME(@@PROCID),@clientLanguage,'کالای "{0}" فعال نمی باشد.'),@itemTitle); 
		goto fail;
end

--بررسی وضعیت گارانتی انتخابی
if(@siw_isActive <> 1)
begin
close c_added;
deallocate c_added;
rollback tran t;
set @rMsg =dbo.func_stringFormat_2(dbo.func_getSysMsg('error_selectedItemWarrantyIsNotActive',OBJECT_NAME(@@PROCID),@clientLanguage,'گارانتی انتخابی با عنوان "{0}" برای کالای "{1}" قابل درخواست (فعال) نمی باشد.'),@sw_title,@itemTitle); 
		goto fail;
end

--بررسی وضعیت رنگ انتخابی
if(@sic_isActive <> 1)
begin
close c_added;
deallocate c_added;
rollback tran t;
set @rMsg =dbo.func_stringFormat_2(dbo.func_getSysMsg('error_selectedItemColorIsNotActive',OBJECT_NAME(@@PROCID),@clientLanguage,'رنگ انتخابی با عنوان "{0}" برای کالای "{1}" قابل درخواست (فعال) نمی باشد.'),@sic_title,@itemTitle); 
		goto fail;
end

--بررسی وضعیت سایز انتخابی
if(@sis_isActive <> 1)
begin
close c_added;
deallocate c_added;
rollback tran t;
set @rMsg =dbo.func_stringFormat_2(dbo.func_getSysMsg('error_selectedItemSizeIsNotActive',OBJECT_NAME(@@PROCID),@clientLanguage,'سایز انتخابی با عنوان "{0}" برای کالای "{1}" قابل درخواست (فعال) نمی باشد.'),@sis_title,@itemTitle); 
		goto fail;
end



--کسر از موجودی فروشگاه
update TB_STORE_ITEM_QTY
		   set qty = qty - @qty
		   where pk_fk_store_id = @storeId and pk_fk_item_id = @itemId;

set @newOrderDtlRowId = @newOrderDtlRowId + 1;
INSERT INTO TB_ORDER_DTL (
			[fk_order_id]
			,[fk_orderHdr_id]
			,[rowId]
			,[fk_store_id]
			,[fk_item_id]
			,[vfk_store_item_color_id]
			,[vfk_store_item_size_id]
			,[vfk_store_item_warranty]
			,[isVoid]
			,[qty]
			,[delivered]	
			)
		values(
		     @orderId
		    ,@newOrderHdrId
		    ,@newOrderDtlRowId
			,@storeId
			,@itemId
			,@colorId
			,@sizeId
			,@warrantyId
			,0
			,@qty
			,0
		);
		INSERT INTO [dbo].TB_ORDER_DTL_BASE
           ([orderId]
           ,[rowId]
           ,[canBePurchasedWithoutWarranty]
           ,[cost_warranty]
           ,[warrantyDays]
           ,[cost_oneUnit_withoutDiscount]
           ,[discount_minCnt]
           ,[discount_percent]
           ,[taxRate]
           ,[item_includedTax]
           ,[store_calculateTax]
           ,[prepaymentPercent]
           ,[cancellationPenaltyPercent]
           ,[validityTimeOfOrder]
           ,[store_taxIncludedInPrices]
		   ,[store_promo_discount_percent]
		   ,[store_promo_dsc])
     VALUES
           (@orderId
           ,@newOrderDtlRowId
           ,@canBePurchasedWithoutWarranty
           ,@cost_warranty
           ,@warrantyDays
           ,@cost_oneUnit_withoutDiscount
           ,@discount_minCnt
           ,@discount_percent
           ,@taxRate
           ,@item_includedTax
           ,@store_calculateTax
           ,@prepaymentPercent
           ,@cancellationPenaltyPercent
           ,@validityTimeOfOrder
           ,@store_taxIncludedInPrices
		   ,@store_promo_discount_percent
		   ,@store_promo_dsc);




fetch next from c_added into 
 @itemId
,@warrantyId
,@colorId
,@sizeId
,@qty
,@soh
,@itemTitle
,@canBePurchasedWithoutWarranty
,@cost_warranty
,@warrantyDays
,@cost_oneUnit_withoutDiscount
,@discount_minCnt
,@discount_percent
,@taxRate
,@item_includedTax
,@store_calculateTax
,@prepaymentPercent
,@cancellationPenaltyPercent
,@validityTimeOfOrder
,@isSecurePayment
,@store_taxIncludedInPrices
,@siq_isNotForSelling
,@siq_fk_status_id
,@siw_isActive
,@sic_isActive
,@sis_isActive
,@sw_title
,@sic_title
,@sis_title;

end--of while
close c_added;
deallocate c_added;


--updated rows

--reset variables--!?
set @rowId = null;
set @itemId = null;
set @warrantyId = null;
set @colorId = null;
set @sizeId = null;
set @qty = null;
set @soh = null;
set @itemTitle = null;
set @sumQty = null;
--set @canBePurchasedWithoutWarranty = null;
--set @cost_warranty = null;
--set @warrantyDays = null
--set @cost_oneUnit_withoutDiscount = null;
--set @discount_minCnt = null;
--set @discount_percent = null;
--set @taxRate = null;
--set @item_includedTax = null;
--set @store_calculateTax = null;
--set @prepaymentPercent = null;
--set @cancellationPenaltyPercent = null;
--set @validityTimeOfOrder = null;
--set @isSecurePayment = null;
--set @store_taxIncludedInPrices = null;





declare c_updated cursor
for
select
 existingDtls.rowId
,inputDtls.itemId
,inputDtls.warrantyId
,inputDtls.colorId
,inputDtls.sizeId
,inputDtls.qty
,siq.qty as soh
,isnull(itm_trn.title,itm.title) as itemTitle
,existingDtls.sum_qty
--,siq.canBePurchasedWithoutWarranty
--,isnull(siw.warrantyCost,0)
--,isnull(siw.warrantyDays,0)
--,siq.price
--,siq.discount_minCnt
--,siq.discount_percent
--,s.taxRate
--,siq.includedTax
--,s.calculateTax
--,siq.prepaymentPercent
--,siq.cancellationPenaltyPercent
--,siq.validityTimeOfOrder
--,case when s.fk_securePayment_StatusId = 13 then 1 else 0 end
--,s.taxIncludedInPrices
from @inputDtls as inputDtls
join TB_STORE_ITEM_QTY as siq on inputDtls.itemId = siq.pk_fk_item_id and siq.fk_status_id = 15 and siq.pk_fk_store_id = @storeId and siq.isNotForSelling = 0
--join TB_STORE_ITEM_WARRANTY as siw on inputDtls.warrantyId = siw.pk_fk_storeWarranty_id and inputDtls.itemId = siw.pk_fk_item_id and siw.pk_fk_store_id = @storeId and siw.isActive = 1
--join TB_STORE_ITEM_COLOR as sic on inputDtls.colorId = sic.fk_color_id and inputDtls.itemId = sic.pk_fk_item_id and sic.pk_fk_store_id = @storeId and sic.isActive = 1
--join TB_STORE_ITEM_SIZE as sis on inputDtls.sizeId = sis.pk_sizeInfo and inputDtls.itemId = sis.pk_fk_item_id and sis.pk_fk_store_id = @storeId and sis.isActive = 1
--join TB_STORE as s on s.id = @storeId
join TB_ITEM as itm on inputDtls.itemId = itm.id
left join TB_ITEM_TRANSLATIONS as itm_trn on inputDtls.itemId = itm_trn.id and itm_trn.lan = @clientLanguage
join @existingDtls as existingDtls
	on inputDtls.itemId = existingDtls.itemId
	and (inputDtls.warrantyId = existingDtls.warrantyId or (inputDtls.warrantyId is null and existingDtls.warrantyId is null) )
	and (inputDtls.colorId = existingDtls.colorId or (inputDtls.colorId is null and existingDtls.colorId is null) )
	and (inputDtls.sizeId = existingDtls.sizeId or (inputDtls.sizeId is null and existingDtls.sizeId is null) )
where existingDtls.sum_qty <> inputDtls.qty;

open c_updated;
fetch next from c_updated into 
 @rowId
,@itemId
,@warrantyId
,@colorId
,@sizeId
,@qty
,@soh
,@itemTitle
,@sumQty;
--,@canBePurchasedWithoutWarranty
--,@cost_warranty
--,@warrantyDays
--,@cost_oneUnit_withoutDiscount
--,@discount_minCnt
--,@discount_percent
--,@taxRate
--,@item_includedTax
--,@store_calculateTax
--,@prepaymentPercent
--,@cancellationPenaltyPercent
--,@validityTimeOfOrder
--,@isSecurePayment
--,@store_taxIncludedInPrices;

while (@@FETCH_STATUS = 0)
begin
set @orderChanged = 1;
--بررسی موجودی فروشگاه برای ردیف هایی که مقدار آنها افزایش یافته است
if([dbo].[func_controlInventory](@storeId,@itemId) = 1 and @sumQty < @qty and (@qty - @sumQty) > @soh)
begin
close c_updated;
deallocate c_updated;
rollback tran t;
set @rMsg = dbo.func_stringFormat_2(dbo.func_getSysMsg('error_sohIsNotEnough',OBJECT_NAME(@@PROCID),@clientLanguage,'موجودی کالای "{0}" کافی نمی باشد. موجودی فعلی : {1}'),@itemTitle,@soh); 
goto fail;
end

--کسر از موجودی فروشگاه
if(@sumQty < @qty)
begin
           update TB_STORE_ITEM_QTY
		   set qty = qty - (@qty - @sumQty) --or abs(@sumQty - @qty)
		   where pk_fk_store_id = @storeId and pk_fk_item_id = @itemId;
end
--افزودن به موجودی فروشگاه
else --if(@sumQty > @qty)
begin
           update TB_STORE_ITEM_QTY
		   set qty = qty + (@sumQty - @qty) --or abs(@sumQty - @qty)
		   where pk_fk_store_id = @storeId and pk_fk_item_id = @itemId;
end


INSERT INTO TB_ORDER_DTL (
			[fk_order_id]
			,[fk_orderHdr_id]
			,[rowId]
			,[fk_store_id]
			,[fk_item_id]
			,[vfk_store_item_color_id]
			,[vfk_store_item_size_id]
			,[vfk_store_item_warranty]
			,[isVoid]
			,[qty]
			,[delivered]	
			)
		values(
		     @orderId
		    ,@newOrderHdrId
		    ,@rowId
			,@storeId
			,@itemId
			,@colorId
			,@sizeId
			,@warrantyId
			,0
			,@qty - @sumQty
			,0
		);

			--update [dbo].TB_ORDER_DTL_BASE --TODO آیا قیمت ها و تنظیمات پایه در زمان بروز رسانی فروشنده باید ویرایش شوند؟! اصولا نباید آپدیت شوند 
			--set 
   --         [canBePurchasedWithoutWarranty]   =@canBePurchasedWithoutWarranty
   --        ,[cost_warranty]					  =@cost_warranty
   --        ,[warrantyDays]					  =@warrantyDays
   --        ,[cost_oneUnit_withoutDiscount]	  =@cost_oneUnit_withoutDiscount
   --        ,[discount_minCnt]				  =@discount_minCnt
   --        ,[discount_percent]				  =@discount_percent
   --        ,[taxRate]						  =@taxRate
   --        ,[item_includedTax]				  =@item_includedTax
   --        ,[store_calculateTax]			  =@store_calculateTax
   --        ,[prepaymentPercent]				  =@prepaymentPercent
   --        ,[cancellationPenaltyPercent]	  =@cancellationPenaltyPercent
   --        ,[validityTimeOfOrder]			  =@validityTimeOfOrder
   --        ,[store_taxIncludedInPrices]		  =@store_taxIncludedInPrices
		 --  where orderId = @orderId and rowId = @rowId;

 fetch next from c_updated into 
 @rowId
,@itemId
,@warrantyId
,@colorId
,@sizeId
,@qty
,@soh
,@itemTitle
,@sumQty;
--,@canBePurchasedWithoutWarranty
--,@cost_warranty
--,@warrantyDays
--,@cost_oneUnit_withoutDiscount
--,@discount_minCnt
--,@discount_percent
--,@taxRate
--,@item_includedTax
--,@store_calculateTax
--,@prepaymentPercent
--,@cancellationPenaltyPercent
--,@validityTimeOfOrder
--,@isSecurePayment
--,@store_taxIncludedInPrices;

end--of while
close c_updated;
deallocate c_updated;









--removed rows
--reset variables--!?
set @rowId = null;
set @itemId = null;
set @warrantyId = null;
set @colorId = null;
set @sizeId = null;
set @qty = null;
set @soh = null;
set @itemTitle = null;
set @sumQty = null;
--set @canBePurchasedWithoutWarranty = null;
--set @cost_warranty = null;
--set @warrantyDays = null
--set @cost_oneUnit_withoutDiscount = null;
--set @discount_minCnt = null;
--set @discount_percent = null;
--set @taxRate = null;
--set @item_includedTax = null;
--set @store_calculateTax = null;
--set @prepaymentPercent = null;
--set @cancellationPenaltyPercent = null;
--set @validityTimeOfOrder = null;
--set @isSecurePayment = null;
--set @store_taxIncludedInPrices = null;




declare c_removed cursor
for
select
 existingDtls.rowId
,existingDtls.itemId
,existingDtls.warrantyId
,existingDtls.colorId
,existingDtls.sizeId
,existingDtls.sum_qty as qty
,siq.qty as soh
,isnull(itm_trn.title,itm.title) as itemTitle
,existingDtls.sum_qty
from @existingDtls as existingDtls
join TB_STORE_ITEM_QTY as siq on existingDtls.itemId = siq.pk_fk_item_id and siq.fk_status_id = 15 and siq.pk_fk_store_id = @storeId and siq.isNotForSelling = 0
join TB_ITEM as itm on existingDtls.itemId = itm.id
left join TB_ITEM_TRANSLATIONS as itm_trn on existingDtls.itemId = itm_trn.id and itm_trn.lan = @clientLanguage
left join @inputDtls as inputDtls
on  existingDtls.itemId = inputDtls.itemId
and (existingDtls.warrantyId = inputDtls.warrantyId or (existingDtls.warrantyId is null and inputDtls.warrantyId is null))
and (existingDtls.colorId = inputDtls.colorId or (existingDtls.colorId is null and inputDtls.colorId is null))
and (existingDtls.sizeId = inputDtls.sizeId or (existingDtls.sizeId is null and inputDtls.sizeId is null))
where inputDtls.itemId is null;--?

open c_removed;
fetch next from c_removed into 
 @rowId
,@itemId
,@warrantyId
,@colorId
,@sizeId
,@qty
,@soh
,@itemTitle
,@sumQty;
--,@canBePurchasedWithoutWarranty
--,@cost_warranty
--,@warrantyDays
--,@cost_oneUnit_withoutDiscount
--,@discount_minCnt
--,@discount_percent
--,@taxRate
--,@item_includedTax
--,@store_calculateTax
--,@prepaymentPercent
--,@cancellationPenaltyPercent
--,@validityTimeOfOrder
--,@isSecurePayment
--,@store_taxIncludedInPrices;

while (@@FETCH_STATUS = 0)
begin
if(@sumQty > 0)
begin
set @orderChanged = 1;
--افزودن به موجودی فروشگاه
    update TB_STORE_ITEM_QTY
    set qty = qty + @sumQty --or abs(@sumQty - @qty)
	where pk_fk_store_id = @storeId and pk_fk_item_id = @itemId;


INSERT INTO TB_ORDER_DTL (
			[fk_order_id]
			,[fk_orderHdr_id]
			,[rowId]
			,[fk_store_id]
			,[fk_item_id]
			,[vfk_store_item_color_id]
			,[vfk_store_item_size_id]
			,[vfk_store_item_warranty]
			,[isVoid]
			,[qty]
			,[delivered]	
			)
		values(
		     @orderId
		    ,@newOrderHdrId
		    ,@rowId
			,@storeId
			,@itemId
			,@colorId
			,@sizeId
			,@warrantyId
			,0
			,-1 * @sumQty
			,0
		);

end

--update TB_ORDER_DTL
--set isVoid = 1
--where fk_order_id = @orderId
--and rowId = @rowId;






fetch next from c_removed into 
 @rowId
,@itemId
,@warrantyId
,@colorId
,@sizeId
,@qty
,@soh
,@itemTitle
,@sumQty;


end--of while
close c_removed;
deallocate c_removed;





if(@orderChanged = 1)
commit tran t;
else
rollback tran t;
end try
begin catch
rollback tran t;
set @rMsg = ERROR_MESSAGE();
goto fail;
end catch

success:

SET @rCode = 1;
SET @rMsg = 'success.';

RETURN 0;

fail:

--ROLLBACK TRAN t1;

SET @rCode = 0;

RETURN 0;