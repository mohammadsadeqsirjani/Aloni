create PROCEDURE [dbo].[SP_order_cart_setDeliveryMethode]
	@clientLanguage AS CHAR(2)
	,@clientIp AS VARCHAR(50)
	,@appId as tinyint
	,@userId as bigint
	,@userSessionId AS BIGINT
	--,@orderId AS VARCHAR(36)
	,@orderId AS BIGINT
	,@deliveryTypeId AS BIGINT

	--,@orderDtls AS dbo.OrderItemType readonly
	,@rCode AS TINYINT OUT
	,@rMsg AS NVARCHAR(max) OUT
	,@fk_orderAddress_id as bigint = NULL
AS

if(@orderId is null)
	BEGIN
	SET @rMsg = dbo.func_getSysMsg('OrderHdrIdIsNull', OBJECT_NAME(@@PROCID), @clientLanguage, 'OrderHdrId is required.');
	GOTO fail;
    END


	





	declare @storeId as bigint,@orderHdrId as bigint
		,@deliveryLoc_lat AS float
		,@customerId as bigint
		,@deliveryLoc_lng AS float
		,@deliveryAddress AS NVARCHAR(500)
		,@fk_state_deliveryStateId AS INT
		,@fk_city_deliveryCityId AS INT
		,@delivery_postalCode AS VARCHAR(50)
		,@delivery_callNo AS VARCHAR(30)
		,@deliveryLoc as sys.geography




	select
	@storeId = o.fk_store_storeId
	,@orderHdrId = max(oh.id)
	,@customerId = o.fk_usr_customerId
	from
	TB_ORDER as o
	join TB_ORDER_HDR as oh on o.id = oh.fk_order_orderId
	where o.id = @orderId and o.fk_usr_customerId = @userId and [dbo].[func_getOrderStatus](o.id,o.fk_status_statusId,o.lastDeliveryDateTime) = 100
	group by o.fk_store_storeId,o.fk_usr_customerId




	if(@storeId is null)
	begin
	set @rMsg = dbo.func_getSysMsg('illegal', OBJECT_NAME(@@PROCID), @clientLanguage, 'invalid request.');
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
	--if(@securePaymentRequested is not null and @securePaymentRequested = 1 and @store_fk_securePayment_StatusId<> 13)
	--begin
	--   SET @rMsg = dbo.func_getSysMsg('securePaymentIsNotActivatedOnStore', OBJECT_NAME(@@PROCID), @clientLanguage, 'secure Payment Is Not Activated On Store');
	--		GOTO fail;
	--end


	select 
				@deliveryLoc = [location],
				@deliveryAddress = postalAddress,
				@fk_state_deliveryStateId = fk_state_id,
				@fk_city_deliveryCityId = fk_city_id,
				@delivery_postalCode = postalCode,
				@delivery_callNo = transfereeTell
			from
				TB_ORDER_ADDRESS
			where
				id = @fk_orderAddress_id and fk_usr_id = @customerId


	


	begin /*دریافت اطلاعات پایه فعلی روش ارسال مرسوله و اعتبار سنجی های مرتبط با روش ارسال مرسوله انتخابی*/
		declare @deliveryTypes_cost AS MONEY
		,@deliveryTypes_includeCostOnInvoice AS BIT
		,@deliveryTypes_storeLocation AS sys.GEOGRAPHY
		,@deliveryTypes_radius AS INT
		,@deliveryTypes_minOrderCost AS MONEY;
			IF (@deliveryTypeId IS NOT NULL)
	BEGIN
		SELECT @deliveryTypes_cost = cost
			,@deliveryTypes_includeCostOnInvoice = includeCostOnInvoice
			,@deliveryTypes_storeLocation = storeLocation
			,@deliveryTypes_radius = radius
			,@deliveryTypes_minOrderCost = minOrderCost
		FROM TB_STORE_DELIVERYTYPES
		WHERE id = @deliveryTypeId
			AND fk_store_id = @storeId;

		IF (@deliveryTypes_includeCostOnInvoice IS NULL)
		BEGIN
			SET @rMsg = dbo.func_getSysMsg('invalidDeliveryTypeId', OBJECT_NAME(@@PROCID), @clientLanguage, 'delivery type id is not valid');

			GOTO fail;
		END

		IF (
				@deliveryTypes_storeLocation IS NOT NULL
				AND @deliveryTypes_radius <> 0
				)
		BEGIN
			--IF (@deliveryLoc IS NULL)
			--BEGIN
			--	SET @rMsg = dbo.func_getSysMsg('deliveryLocIsNull', OBJECT_NAME(@@PROCID), @clientLanguage, 'delivery location cannot be null');

			--	GOTO fail;
			--END

			IF (@deliveryTypes_storeLocation.STDistance(@deliveryLoc) > @deliveryTypes_radius)
			BEGIN
				SET @rMsg = dbo.func_getSysMsg('deliveryLocIsFarThanSupportedLimit', OBJECT_NAME(@@PROCID), @clientLanguage, 'آدرس تعیین شده شما برای تحویل این سفارش، خارج از محدوده تحت پوشش شیوه ارسال انتخابی می باشد - شیوه ارسال را اصلاح نمایید.');

				GOTO fail;
			END
		END
	END
	end;


	if( (select sum_cost_payable_withTax_withDiscount_remaining from [dbo].[func_getOrderHdrs](@orderId)) < @deliveryTypes_minOrderCost )
	begin
	select 1;
	end



	

	begin try
	begin tran t1;
		UPDATE TB_ORDER_HDR
		SET-- fk_status_id = 24
		--	,--در انتظار بررسی - بررسی نشده
			fk_docType_id = 1
			,fk_usrSession_id = @userSessionId
			,saveIp = @clientIp
			,fk_deliveryTypes_id = @deliveryTypeId
			,fk_address_id = isnull(@fk_orderAddress_id,fk_address_id)
			--,vfk_deliveryTypes_cost = @deliveryTypes_cost
			--,vfk_deliveryTypes_includeCostOnInvoice = @deliveryTypes_includeCostOnInvoice
			--,vfk_deliveryTypes_storeLocation = @deliveryTypes_storeLocation
			--,vfk_deliveryTypes_radius = @deliveryTypes_radius
			--,vfk_deliveryTypes_minOrderCost = @deliveryTypes_minOrderCost
			--,securePaymentRequested = @store_securePaymentRequested
			--,deliveryLoc = @deliveryLoc
			--,deliveryAddress = @deliveryAddress
			--,fk_state_deliveryStateId = @fk_state_deliveryStateId
			--,fk_city_deliveryCityId = @fk_city_deliveryCityId
			--,delivery_postalCode = @delivery_postalCode
			--,delivery_callNo = @delivery_callNo
			--,fk_paymentType_id = @paymentType
		WHERE id = @orderHdrId
			--AND orderId = @hdr_orderId
			--AND docRow = 1
			--AND fk_docType_id = 1
			--AND fk_status_id = 23;

			
		--IF (@@ROWCOUNT <> 1)
		--BEGIN
		--	SET @rMsg = dbo.func_getSysMsg('invalidState', OBJECT_NAME(@@PROCID), @clientLanguage, 'the state of the order is not valid');
		--	GOTO fail;
		--END




			if(exists(select 1 from TB_ORDER_HDR_BASE where fk_orderHdr_id = @orderHdrId))
			begin--update TB_ORDER_HDR_BASE
			UPDATE [dbo].[TB_ORDER_HDR_BASE]
   SET [delivery_amount] = @deliveryTypes_cost
      ,[delivery_includeCostOnInvoice] = @deliveryTypes_includeCostOnInvoice
      ,[delivery_storeLocation] = @deliveryTypes_storeLocation
      ,[delivery_radius] = @deliveryTypes_radius
      ,[delivery_minOrderCost] = @deliveryTypes_minOrderCost
	  where fk_orderHdr_id = @orderHdrId;
			end
			else
			begin--insert into TB_ORDER_HDR_BASE
				INSERT INTO [dbo].[TB_ORDER_HDR_BASE]
           ([orderId]
           ,[fk_orderHdr_id]
           ,[delivery_amount]
           ,[delivery_includeCostOnInvoice]
           ,[delivery_storeLocation]
           ,[delivery_radius]
           ,[delivery_minOrderCost])
     VALUES
           (@orderId
           ,@orderHdrId
           ,@deliveryTypes_cost
           ,@deliveryTypes_includeCostOnInvoice
           ,@deliveryTypes_storeLocation
           ,@deliveryTypes_radius
           ,@deliveryTypes_minOrderCost)
			end






--		DECLARE	@return_value_SP_calcOrderValues int,
--		@rCode_SP_calcOrderValues tinyint,
--		@rMsg_SP_calcOrderValues nvarchar(max)

--EXEC	@return_value_SP_calcOrderValues = [dbo].[SP_calcOrderValues]
--		@orderHdrId = @orderHdrId,
--		@clientLanguage = @clientLanguage,
--		@rCode = @rCode_SP_calcOrderValues OUTPUT,
--		@rMsg = @rMsg_SP_calcOrderValues OUTPUT;

		commit tran t1;
		end try
		begin catch
		rollback tran t1;
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