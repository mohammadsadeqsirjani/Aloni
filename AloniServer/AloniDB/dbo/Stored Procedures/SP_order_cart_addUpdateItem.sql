CREATE PROCEDURE [dbo].[SP_order_cart_addUpdateItem]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	--@customerUserId as bigint = null,
	@storeId as bigint,
	@itemId as bigint,
	@colorId as varchar(20),
	@sizeId as nvarchar(500),
	@warrantyId as bigint,
	--@deliveryTypeId as int = null,
	@qty as money,
	@sessionId as bigint,
	@orderId as bigint out,
	@orderId_str as varchar(36) out, 
	@orderHdrId AS BIGINT out,
	@orderDtlRowId as int out,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out
AS
	--declare @order_hdr_Id as bigint 
	--select @order_hdr_Id = id from TB_ORDER_HDR where fk_store_id = @storeId and fk_usr_customer = @customerUserId and fk_status_id = 23


 --   if(@appId = 2)
	--begin
	--	set @customerUserId = @userId
	--end



	begin /*اعتبار سنجی های عمومی*/





	declare @isNotForSelling as bit,@dbqty as money,
	@store_onlyCustomersAreAbleToSetOrder as bit;-- TODO : عضو بودن مشتری در فروشگاه بررسی شود



	select @isNotForSelling = isNotForSelling ,@dbqty = qty
	from TB_STORE_ITEM_QTY 
	where pk_fk_store_id = @storeId and pk_fk_item_id = @itemId



	if(@appId <> 2)
	begin
		set @rMsg = dbo.func_getSysMsg('error_illegal',OBJECT_NAME(@@PROCID),@clientLanguage,'only customer can do this operation!'); 
		goto fail;
	end
	-- اصلاح شود
	--if(not exists(select pk_fk_usr_cstmrId from TB_STORE_CUSTOMER where pk_fk_store_id = @storeId and pk_fk_usr_cstmrId = @customerUserId and fk_status_id = 32))
	--begin
	--	set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,'customer not join to store!'); 
	--	set @rCode = 0
	--	return 0
	--end
	if(dbo.func_OnlyCustomersAreAbleToSetOrder(@storeId) = 1 and dbo.func_isUserJoinedToStoreCustomers(@storeId,@userId) = 0)
	begin
		set @rMsg = dbo.func_getSysMsg('userIsNotJoinedToStoreCustomers',OBJECT_NAME(@@PROCID),@clientLanguage,'به منظور خرید از این فروشگاه ابتدا باید عضو مشتریان آن باشید.'); 
		goto fail;
	end

	declare @shiftStatus as bit = (select case when 
										exists(select
												 1
											   from
												TB_STORE_SCHEDULE
											   where 
											   fk_store_id = @storeId and onDayOfWeek = case when DATEPART(dw,getdate()) = 7 then 0 else DATEPART(dw,getdate()) end
											   and 
											   cast(GETDATE() as time(0)) >= isActiveFrom and cast(GETDATE() as time(0)) < activeUntil ) then 1
									   when fk_status_shiftStatus = 17 then 1 
									   when fk_status_shiftStatus = 18 then 0  
									   else 0 end 
								   from
										TB_STORE 
								   where
										id = @storeId)
	if(@shiftStatus = 0)
	begin
		set @rMsg = dbo.func_getSysMsg('error_itemNotForSell',OBJECT_NAME(@@PROCID),@clientLanguage,'فروشگاه در حال حاضر بسته است و قادر به ارائه سرویس به شما نمی باشد'); 
		goto fail;
	end
	if(@isNotForSelling is null or @isNotForSelling = 1)
	begin
		set @rMsg = dbo.func_getSysMsg('error_itemNotForSell',OBJECT_NAME(@@PROCID),@clientLanguage,'item is not for sell!'); 
		goto fail;
	end


	if([dbo].[func_controlInventory](@storeId,@itemId) = 1 and @dbqty < @qty)
	begin
		set @rMsg = dbo.func_getSysMsg('error_sohIsNotEnough',OBJECT_NAME(@@PROCID),@clientLanguage,'با عرض پوزش، مقدار موجودی کالا به مقدار درخواستی شما کافی نمی باشد.'); 
		goto fail;
	end



	if(@warrantyId is not null and not exists(select 1 from TB_STORE_ITEM_WARRANTY where pk_fk_store_id = @storeId and pk_fk_item_id = @itemId and pk_fk_storeWarranty_id = @warrantyId and isActive = 1))
	begin
	set @rMsg = dbo.func_getSysMsg('error_invalidWarranty',OBJECT_NAME(@@PROCID),@clientLanguage,'با عرض پوزش، گارانتی انتخابی شما قابل درخواست نمی باشد.'); 
		goto fail;
	end


	if(@colorId is not null and not exists(select 1 from TB_STORE_ITEM_COLOR where pk_fk_store_id = @storeId and pk_fk_item_id = @itemId and fk_color_id = @colorId and isActive = 1))
	begin
	set @rMsg = dbo.func_getSysMsg('error_invalidColor',OBJECT_NAME(@@PROCID),@clientLanguage,'با عرض پوزش، رنگ انتخابی شما قابل درخواست نمی باشد.'); 
		goto fail;
	end

	if(@sizeId is not null and not exists(select 1 from TB_STORE_ITEM_SIZE where pk_fk_store_id = @storeId and pk_fk_item_id = @itemId and pk_sizeInfo = @sizeId and isActive = 1))
	begin
	set @rMsg = dbo.func_getSysMsg('error_invalidSize',OBJECT_NAME(@@PROCID),@clientLanguage,'با عرض پوزش، سایز انتخابی شما قابل درخواست نمی باشد.'); 
		goto fail;
	end



	end;--of اعتبار سنجی های عمومی





	declare 
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
	@store_taxIncludedInPrices as bit,
	@isSecurePayment as bit;

	declare @store_promo_discount_percent as money,
	@store_promo_dsc as varchar(max);


	select 
		 @canBePurchasedWithoutWarranty = siq.canBePurchasedWithoutWarranty
		,@cost_warranty = isnull(w.warrantyCost,0)
		,@warrantyDays = isnull(w.warrantyDays,0)
		,@cost_oneUnit_withoutDiscount = siq.price
		,@discount_minCnt = siq.discount_minCnt
		,@discount_percent = siq.discount_percent
		,@taxRate = s.taxRate
		,@item_includedTax = siq.includedTax
		,@store_calculateTax = s.calculateTax
		,@prepaymentPercent = siq.prepaymentPercent
		,@cancellationPenaltyPercent = siq.cancellationPenaltyPercent
		,@validityTimeOfOrder = siq.validityTimeOfOrder
		,@isSecurePayment = case when s.fk_securePayment_StatusId = 13 then 1 else 0 end
		,@store_taxIncludedInPrices = s.taxIncludedInPrices
	FROM 
	 TB_STORE_ITEM_QTY AS siq
	LEFT JOIN TB_STORE_ITEM_WARRANTY AS w ON @warrantyId = w.pk_fk_storeWarranty_id
		AND @itemId = w.pk_fk_item_id
		AND w.pk_fk_store_id = @storeId
	LEFT JOIN TB_STORE AS s ON s.id = @storeId
	where
	siq.pk_fk_item_id = @itemId
		AND siq.pk_fk_store_id = @storeId


		select top (1) @store_promo_discount_percent = sp.promotionPercent,
				@store_promo_dsc =  sp.promotionDsc
				from TB_STORE_PROMOTION as sp
				where sp.fk_store_id = @storeId and sp.isActive = 1
				order by id desc;







--begin try

--if(@orderId is null)
--begin
-- --افزودن / ویرایش ردیف در سبد خرید



 select @orderId = o.id,@orderHdrId = max(h.id),@orderId_str = o.id_str
 from TB_ORDER as o
 join TB_ORDER_HDR as h
 on o.id = h.fk_order_orderId
 where o.fk_store_storeId = @storeId and [dbo].[func_getOrderStatus](o.id,o.fk_status_statusId,o.lastDeliveryDateTime) = 100 and o.fk_usr_customerId = @userId
 group by o.id,o.id_str
 having count(h.id) = 1;--سفارشی که هنوز قطعی نشده (وضعیت 100) به هر حال نباید بیش از یک سند داشته باشه! ولی خب...




 	begin try
	begin tran t1;




if(@orderId is null)
begin--create new order
set @orderId_str = dbo.func_getOrderId_str(@userId);



--declare @deliveryAddress as varchar(500)
--		   ,@delivery_callNo as varchar(30)
--		   ,@delivery_postalCode as varchar(50)
--		   ,@deliveryLoc as sys.geography
--		   ,@fk_city_deliveryCityId as int
--		   ,@fk_state_deliveryStateId as int;
declare @deliveryAddressId as bigint;

		   select top(1) 
				  -- @deliveryAddress = oh.deliveryAddress
		    --      ,@delivery_callNo = oh.delivery_callNo
				  --,@delivery_postalCode = oh.delivery_postalCode
				  --,@deliveryLoc = oh.deliveryLoc
				  --,@fk_city_deliveryCityId  = oh.fk_city_deliveryCityId
				  --,@fk_state_deliveryStateId = oh.fk_state_deliveryStateId
				  @deliveryAddressId = oh.fk_address_id
				  from TB_ORDER as o 
				  join TB_ORDER_HDR as oh on o.id = oh.fk_order_orderId
				  where o.fk_usr_customerId = @userId
				  and [dbo].[func_getOrderStatus](o.id,o.fk_status_statusId,o.lastDeliveryDateTime) in (101,102,103,104,105)
				  and oh.fk_address_id is not null
				  order by oh.id desc



INSERT INTO [dbo].[TB_ORDER]
           ([id_str]
           ,[fk_usr_customerId]
           ,[fk_store_storeId]
           ,[fk_status_statusId]
           ,[saveDateTime]
           ,[fk_userSession_saveUserSessionId]
           ,[saveUserIpAddress]
           ,[isSecurePayment])
     VALUES
           (@orderId_str
           ,@userId
           ,@storeId
           ,100
           ,getdate()
           ,@sessionId
           ,@clientIp
           ,@isSecurePayment);


		   set @orderId = SCOPE_IDENTITY();


INSERT INTO [dbo].[TB_ORDER_HDR]
           ([fk_order_orderId]
           ,[fk_docType_id]
           ,[saveDateTime]
           ,[fk_usrSession_id]
           ,[saveIp]
		   ,[isVoid]
		   ,[fk_address_id]
		   --,[deliveryAddress]
		   --,[delivery_callNo]
		   --,[delivery_postalCode]
		   --,[deliveryLoc]
		   --,[fk_city_deliveryCityId]
		   --,[fk_state_deliveryStateId]
		   ,[fk_staff_operatorStaffId]
		   )
     VALUES
           (@orderId
           ,1
           ,GETDATE()
           ,@sessionId
           ,@clientIp
		   ,0
		   ,@deliveryAddressId
		   --,@deliveryAddress
		   --,@delivery_callNo
		   --,@delivery_postalCode
		   --,@deliveryLoc
		   --,@fk_city_deliveryCityId
		   --,@fk_state_deliveryStateId
		   ,[dbo].[func_GetUserStaff](@userId,@storeId,@appId)
        );
set @orderHdrId = SCOPE_IDENTITY();

end


declare @dbdtlId as bigint,@dbdtl_isVoid as int;
select @dbdtlId = id,@dbdtl_isVoid = isVoid ,@orderDtlRowId = rowId
from TB_ORDER_DTL with(nolock)
where fk_orderHdr_id = @orderHdrId and fk_item_id = @itemId and (vfk_store_item_warranty = @warrantyId or (vfk_store_item_warranty is null and @warrantyId is null)) and (vfk_store_item_color_id = @colorId or (vfk_store_item_color_id is null and @colorId is null)) and (vfk_store_item_size_id = @sizeId or (vfk_store_item_size_id is null and @sizeId is null));

if(@dbdtlId is not null )
begin--update existing dtl

--if(@dbdtl_fk_status not in (39))
--begin
--	set @rMsg = dbo.func_getSysMsg('illegalStauts_orderDtl', OBJECT_NAME(@@PROCID), @clientLanguage, 'illegal status on order dtl . the row cannot be updated.');
--	goto fail;
--end

if(@qty > 0)
begin

update 
			TB_ORDER_DTL
			set
			vfk_store_item_color_id=@colorId,
			vfk_store_item_size_id=@sizeId,
			vfk_store_item_warranty=@warrantyId,
			isVoid=0,
			qty=@qty,
			delivered = 0
			where id = @dbdtlId;

			update [dbo].TB_ORDER_DTL_BASE 
			set 
            [canBePurchasedWithoutWarranty]   =@canBePurchasedWithoutWarranty
           ,[cost_warranty]					  =@cost_warranty
           ,[warrantyDays]					  =@warrantyDays
           ,[cost_oneUnit_withoutDiscount]	  =@cost_oneUnit_withoutDiscount
           ,[discount_minCnt]				  =@discount_minCnt
           ,[discount_percent]				  =@discount_percent
           ,[taxRate]						  =@taxRate
           ,[item_includedTax]				  =@item_includedTax
           ,[store_calculateTax]			  =@store_calculateTax
           ,[prepaymentPercent]				  =@prepaymentPercent
           ,[cancellationPenaltyPercent]	  =@cancellationPenaltyPercent
           ,[validityTimeOfOrder]			  =@validityTimeOfOrder
           ,[store_taxIncludedInPrices]		  =@store_taxIncludedInPrices
		   ,[store_promo_discount_percent] = @store_promo_discount_percent
		   ,[store_promo_dsc] = @store_promo_dsc
		   where orderId = @orderId and rowId = @orderDtlRowId;

		   


		 --  if((select isnull(sum(qty),0) from TB_ORDER_DTL where fk_order_id = @orderId and isVoid = 0) <= 0)
			--begin -- cancel the cart
	   
	    
			--	exec [dbo].[SP_SYS_order_cart_delete]
			--	@orderId = @orderId
			--	,@rCode = @rCode output
			--	,@rMsg = @rMsg output
			--	--update TB_ORDER
			--	--set fk_status_statusId = 103 -- case when @appId = 2 then 103 else 104 end
			--	--where id = @orderId;
			--end
	end
	else--@qty is zero or negative
	begin
	   --delete
	   delete from TB_ORDER_DTL_BASE where orderId = @orderId and rowId = @orderDtlRowId;
	   delete from TB_ORDER_DTL where id = @dbdtlId;


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


	end


end
else
begin--add new dtl


if(@qty <= 0)
begin
rollback tran t1;
set @rMsg = dbo.func_getSysMsg('error_invalidQty',OBJECT_NAME(@@PROCID),@clientLanguage,'qty must be greater than or equal to zero.'); ;
goto fail;
end






set @orderDtlRowId = isnull( [dbo].[func_getMaxRowIdOfOrder](@orderHdrId),0) + 1;

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
		    ,@orderHdrId
		    ,@orderDtlRowId
			,@storeId
			,@itemId
			,@colorId
			,@sizeId
			,@warrantyId
			--,@canBePurchasedWithoutWarranty
			,0
			,--[fk_status_id]
			@qty
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
           ,@orderDtlRowId
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
		   ,@store_promo_dsc)
end



--DECLARE	@return_value_SP_calcOrderValues int,
--		@rCode_SP_calcOrderValues tinyint,
--		@rMsg_SP_calcOrderValues nvarchar(max)

--EXEC	@return_value_SP_calcOrderValues = [dbo].[SP_calcOrderValues]
--		@orderHdrId = @orderHdrId,
--		@clientLanguage = @clientLanguage,
--		@rCode = @rCode_SP_calcOrderValues OUTPUT,
--		@rMsg = @rMsg_SP_calcOrderValues OUTPUT;

--		if(@rCode_SP_calcOrderValues <> 1)
--		begin
--		set @rCode = @rCode_SP_calcOrderValues;
--		set @rMsg = @rMsg_SP_calcOrderValues;
--		goto fail;
--		end



--end
--else-- @orderId is not null
--begin--افزودن / ویرایش یک ردیف در یک سفارش خاص


--if(@appId <> 1)
--begin
--	SET @rMsg = dbo.func_getSysMsg('illegal_invalidAppId', OBJECT_NAME(@@PROCID), @clientLanguage, 'illegal request. only marketer can do this operation.');

--	GOTO fail;
--end


--if(@orderHdrId is null or @orderHdrId = 0)
--begin
--	SET @rMsg = dbo.func_getSysMsg('orderHdrIdIsRequired', OBJECT_NAME(@@PROCID), @clientLanguage, 'orderHdrId Is Required');

--	GOTO fail;
--end






--declare @orderStatus as int,@lastHdrId as bigint;



--select @orderStatus = fk_status_statusId ,@lastHdrId = max(oh.id)
--from TB_ORDER as o
--left join TB_ORDER_HDR as oh on o.id = oh.fk_order_orderId
--where o.id = @orderId and o.fk_usr_customerId = @customerUserId and o.fk_store_storeId = @storeId
--group by fk_status_statusId;


--if(@orderStatus is null or @lastHdrId is null )
--begin
--SET @rMsg = dbo.func_getSysMsg('illegal_validationError', OBJECT_NAME(@@PROCID), @clientLanguage, 'illegal request. only marketer can do this operation.');
--	GOTO fail;
--end


--if(@lastHdrId <> @orderHdrId)
--begin
--SET @rMsg = dbo.func_getSysMsg('informationChanged', OBJECT_NAME(@@PROCID), @clientLanguage, 'اطلاعات سفارش توسط کاربر دیگری تغییر کرده است. لطفا پس از بارگزاری مجدد اطلاعات ، مجددا اقدام نمائید.');
--	GOTO fail;
--end



--if(@orderStatus not in (101))--فقط برای سفارش در جریان امکان ایجاد / ویرایش ردیف توسط فروشنده ممکن می باشد.
--begin
--SET @rMsg = dbo.func_getSysMsg('illegal_validationError', OBJECT_NAME(@@PROCID), @clientLanguage, 'illegal request. only marketer can do this operation.');
--	GOTO fail;
--end


--end

commit tran t1;

end try
begin catch
ROLLBACK TRAN t1;
set @rMsg = ERROR_MESSAGE();
goto fail;
end catch

success:

SET @rCode = 1;
SET @rMsg = 'success.';
RETURN 0;
fail:
SET @rCode = 0;
RETURN 0;