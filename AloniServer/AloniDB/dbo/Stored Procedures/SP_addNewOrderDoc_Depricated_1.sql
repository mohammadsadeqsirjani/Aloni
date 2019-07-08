CREATE PROCEDURE [dbo].[SP_addNewOrderDoc_Depricated_1] @clientLanguage AS CHAR(2)
	,@clientIp AS VARCHAR(50)
	,
	--@appId as tinyint,
	--@userId as bigint,
	@userSessionId AS BIGINT
	,@orderId AS VARCHAR(36)
	,@lastOrderHdrId AS BIGINT
	,@docType AS SMALLINT
	,@deliveryTypeId AS BIGINT
	,@securePaymentRequested AS BIT
	,@deliveryLoc AS sys.GEOGRAPHY
	,@deliveryAddress AS NVARCHAR(500)
	,@fk_state_deliveryStateId AS INT
	,@fk_city_deliveryCityId AS INT
	,@delivery_postalCode AS VARCHAR(50)
	,@delivery_callNo AS VARCHAR(30)
	,@orderDtls AS dbo.OrderItemType readonly
	,@rCode AS TINYINT OUT
	,@rMsg AS NVARCHAR(max) OUT AS

--common validations
IF (
		EXISTS (
			SELECT 1
			FROM TB_ORDER_HDR
			WHERE id > @lastOrderHdrId
				AND orderId = @lastOrderHdrId
			)
		) --بررسی آخرین بودن شماره سند
BEGIN
	SET @rMsg = dbo.func_getSysMsg('docUsedAsReference', OBJECT_NAME(@@PROCID), @ClientLanguage, 'the target document is used as Reference to another doc.');

	GOTO fail;
END

BEGIN TRAN t1;

BEGIN TRY
	DECLARE @deliveryTypes_cost AS MONEY
		,@deliveryTypes_includeCostOnInvoice AS BIT
		,@deliveryTypes_storeLocation AS sys.GEOGRAPHY
		,@deliveryTypes_radius AS INT
		,@deliveryTypes_minOrderCost AS MONEY
		,@storeId AS BIGINT
		,@dtl_id AS BIGINT
		,@dtl_fk_item_id AS BIGINT
		,@dtl_vfk_store_item_color_id AS VARCHAR(20)
		,@dtl_vfk_store_item_size_id AS NVARCHAR(500)
		,@dtl_vfk_store_item_warranty AS BIGINT
		,@dtl_qty AS MONEY
		,@dtl_delivered AS MONEY;

	SELECT @storeId = fk_store_id
	FROM TB_ORDER_HDR
	WHERE id = @lastOrderHdrId;

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
			SET @rMsg = dbo.func_getSysMsg('invalidDeliveryTypeId', OBJECT_NAME(@@PROCID), @ClientLanguage, 'delivery type id is not valid');

			GOTO fail;
		END

		IF (
				@deliveryTypes_storeLocation IS NOT NULL
				AND @deliveryTypes_radius <> 0
				)
		BEGIN
			IF (@deliveryLoc IS NULL)
			BEGIN
				SET @rMsg = dbo.func_getSysMsg('@deliveryLocIsNull', OBJECT_NAME(@@PROCID), @ClientLanguage, 'delivery location cannot be null');

				GOTO fail;
			END

			IF (@deliveryTypes_storeLocation.STDistance(@deliveryLoc) > @deliveryTypes_radius)
			BEGIN
				SET @rMsg = dbo.func_getSysMsg('@deliveryLocIsFarThanSupportedLimit', OBJECT_NAME(@@PROCID), @ClientLanguage, 'the delivery location is much far away than limited radius.');

				GOTO fail;
			END
		END
	END

	IF (
			EXISTS (
				SELECT count(fk_item_id) AS cnt
				FROM @orderDtls
				GROUP BY fk_item_id
				HAVING count(fk_item_id) > 1
				)
			)
	BEGIN
		SET @rMsg = dbo.func_getSysMsg('@duplicateItemInOrderDtls', OBJECT_NAME(@@PROCID), @ClientLanguage, 'duplicate item id found in order list.');

		GOTO fail;
	END

	DECLARE @crntDtls AS dbo.OrderItemType
		,@removedDtls AS dbo.OrderItemType
		,@newlyAddedDtls AS dbo.OrderItemType
		,@existingUpdatedDtls as dbo.OrderItemType;

	INSERT INTO @crntDtls (
		[id]
		,[fk_orderHdr_id]
		,[fk_store_id]
		,[fk_item_id]
		,[vfk_store_item_color_id]
		,[vfk_store_item_size_id]
		,[vfk_store_item_warranty]
		,[canBePurchasedWithoutWarranty]
		,[fk_status_id]
		,[qty]
		,[sum_qty]
		,[delivered]
		,[sum_delivered]
		,[sum_remainingToDelivery]
		,[cost_warranty]
		,[warrantyDays]
		,[cost_oneUnit_withoutDiscount]
		,[cost_oneUnit_withDiscount]
		,[discount_minCnt]
		,[discount_percent]
		,[cost_discount]
		,[taxRate]
		,[item_includedTax]
		,[store_calculateTax]
		,[prepaymentPercent]
		,[cost_prepayment]
		,[cost_prepayment_remaining]
		,[cancellationPenaltyPercent]
		,[cost_cancellationPenalty]
		,[validityTimeOfOrder]
		,[store_taxIncludedInPrices]
		,[cost_totalTax_included]
		,[cost_totalTax_info]
		,[cost_payable_withoutTax]
		,[cost_payable_withTax_withDiscount]
		,[cost_payable_withTax_withDiscount_totalPaid]
		,[cost_payable_withTax_withDiscount_remaining]
		,[cost_payable_withTax_withoutDiscount]
		,[cost_totalTax_included_withoutDiscount]
		,[cost_payable_withoutTax_withoutDiscount]
		)
	SELECT [id]
		,[fk_orderHdr_id]
		,[fk_store_id]
		,[fk_item_id]
		,[vfk_store_item_color_id]
		,[vfk_store_item_size_id]
		,[vfk_store_item_warranty]
		,[canBePurchasedWithoutWarranty]
		,[fk_status_id]
		,[qty]
		,[sum_qty]
		,[delivered]
		,[sum_delivered]
		,[sum_remainingToDelivery]
		,[cost_warranty]
		,[warrantyDays]
		,[cost_oneUnit_withoutDiscount]
		,[cost_oneUnit_withDiscount]
		,[discount_minCnt]
		,[discount_percent]
		,[cost_discount]
		,[taxRate]
		,[item_includedTax]
		,[store_calculateTax]
		,[prepaymentPercent]
		,[cost_prepayment]
		,[cost_prepayment_remaining]
		,[cancellationPenaltyPercent]
		,[cost_cancellationPenalty]
		,[validityTimeOfOrder]
		,[store_taxIncludedInPrices]
		,[cost_totalTax_included]
		,[cost_totalTax_info]
		,[cost_payable_withoutTax]
		,[cost_payable_withTax_withDiscount]
		,[cost_payable_withTax_withDiscount_totalPaid]
		,[cost_payable_withTax_withDiscount_remaining]
		,[cost_payable_withTax_withoutDiscount]
		,[cost_totalTax_included_withoutDiscount]
		,[cost_payable_withoutTax_withoutDiscount]
	FROM TB_ORDER_DTL
	WHERE fk_orderHdr_id = @lastOrderHdrId;


	insert into @existingUpdatedDtls---کامل شود
	select
	 cd.id

	from @crntDtls as cd join @orderDtls as ods on cd.fk_item_id = ods.fk_item_id;


	--getting @removedDtls
	INSERT INTO @removedDtls
	SELECT c.*
	FROM @crntDtls AS c
	LEFT JOIN @orderDtls AS i ON c.fk_item_id = i.fk_item_id
	WHERE i.fk_item_id IS NULL;

	--getting @newlyAddedDtls 
	INSERT INTO @newlyAddedDtls
	SELECT i.*
	FROM @orderDtls AS i
	LEFT JOIN @crntDtls AS c ON i.fk_item_id = c.fk_item_id
	WHERE c.fk_item_id IS NULL;

	--update base data of @newlyAddedDtls
	UPDATE @newlyAddedDtls
	SET fk_orderHdr_id = @lastOrderHdrId
		,fk_store_id = @storeId
		,canBePurchasedWithoutWarranty = siq.canBePurchasedWithoutWarranty
		,cost_warranty = w.warrantyCost
		,warrantyDays = w.warrantyDays
		,cost_oneUnit_withoutDiscount = siq.price
		,discount_minCnt = siq.discount_minCnt
		,discount_percent = siq.discount_percent
		,taxRate = s.taxRate
		,item_includedTax = siq.includedTax
		,store_calculateTax = s.calculateTax
		,prepaymentPercent = siq.prepaymentPercent
		,cancellationPenaltyPercent = siq.cancellationPenaltyPercent
		,validityTimeOfOrder = siq.validityTimeOfOrder
		,store_taxIncludedInPrices = s.taxIncludedInPrices
	FROM @newlyAddedDtls AS nad
	LEFT JOIN TB_STORE_ITEM_QTY AS siq ON nad.fk_item_id = siq.pk_fk_item_id
		AND siq.pk_fk_store_id = @storeId
	LEFT JOIN TB_STORE_ITEM_WARRANTY AS w ON nad.vfk_store_item_warranty = w.pk_fk_storeWarranty_id
		AND nad.fk_item_id = w.pk_fk_item_id
		AND w.pk_fk_store_id = @storeId
	LEFT JOIN TB_STORE AS s ON s.id = @storeId;

	IF (@docType = 1) --ثبت نهایی سفارش
	BEGIN
		--special validations
		UPDATE TB_ORDER_HDR
		SET fk_status_id = 24
			,--در انتظار بررسی - بررسی نشده
			fk_usrSession_id = @userSessionId
			,saveIp = @clientIp
			,fk_deliveryTypes_id = @deliveryTypeId
			,vfk_deliveryTypes_cost = @deliveryTypes_cost
			,vfk_deliveryTypes_includeCostOnInvoice = @deliveryTypes_includeCostOnInvoice
			,vfk_deliveryTypes_storeLocation = @deliveryTypes_storeLocation
			,vfk_deliveryTypes_radius = @deliveryTypes_radius
			,vfk_deliveryTypes_minOrderCost = @deliveryTypes_minOrderCost
			,securePaymentRequested = @securePaymentRequested
			,deliveryLoc = @deliveryLoc
			,deliveryAddress = @deliveryAddress
			,fk_state_deliveryStateId = @fk_state_deliveryStateId
			,fk_city_deliveryCityId = @fk_city_deliveryCityId
			,delivery_postalCode = @delivery_postalCode
			,delivery_callNo = @delivery_callNo
		WHERE id = @lastOrderHdrId
			AND orderId = @lastOrderHdrId
			AND docRow = 1
			AND fk_docType_id = 1
			AND fk_status_id = 23;

		IF (@@ROWCOUNT <> 1)
		BEGIN
			SET @rMsg = dbo.func_getSysMsg('invalidState', OBJECT_NAME(@@PROCID), @ClientLanguage, 'the state of the order is not valid');

			GOTO fail;
		END

		-- update exsisting dtls
			update 
			TB_ORDER_DTL
			set
			fk_orderHdr_id=od.fk_orderHdr_id,
			fk_store_id=od.fk_store_id,
			fk_item_id=od.fk_item_id,
			vfk_store_item_color_id=od.vfk_store_item_color_id,
			vfk_store_item_size_id=od.vfk_store_item_size_id,
			vfk_store_item_warranty=od.vfk_store_item_warranty,
			canBePurchasedWithoutWarranty=od.canBePurchasedWithoutWarranty,
			fk_status_id=od.fk_status_id,
			qty=od.qty,
			sum_qty=od.sum_qty,
			delivered=od.delivered,
			sum_delivered=od.sum_delivered,
			sum_remainingToDelivery=od.sum_remainingToDelivery,
			cost_warranty=od.cost_warranty,
			warrantyDays=od.warrantyDays,
			cost_oneUnit_withoutDiscount=od.cost_oneUnit_withoutDiscount,
			cost_oneUnit_withDiscount=od.cost_oneUnit_withDiscount,
			discount_minCnt=od.discount_minCnt,
			discount_percent=od.discount_percent,
			cost_discount=od.cost_discount,
			taxRate=od.taxRate,
			item_includedTax=od.item_includedTax,
			store_calculateTax=od.store_calculateTax,
			prepaymentPercent=od.prepaymentPercent,
			cost_prepayment=od.cost_prepayment,
			cost_prepayment_remaining=od.cost_prepayment_remaining,
			cancellationPenaltyPercent=od.cancellationPenaltyPercent,
			cost_cancellationPenalty=od.cost_cancellationPenalty,
			validityTimeOfOrder=od.validityTimeOfOrder,
			store_taxIncludedInPrices=od.store_taxIncludedInPrices,
			cost_totalTax_included=od.cost_totalTax_included,
			cost_totalTax_info=od.cost_totalTax_info,
			cost_payable_withoutTax=od.cost_payable_withoutTax,
			cost_payable_withTax_withDiscount=od.cost_payable_withTax_withDiscount,
			cost_payable_withTax_withDiscount_totalPaid=od.cost_payable_withTax_withDiscount_totalPaid,
			cost_payable_withTax_withDiscount_remaining=od.cost_payable_withTax_withDiscount_remaining,
			cost_payable_withTax_withoutDiscount=od.cost_payable_withTax_withoutDiscount,
			cost_totalTax_included_withoutDiscount=od.cost_totalTax_included_withoutDiscount,
			cost_payable_withoutTax_withoutDiscount=od.cost_payable_withoutTax_withoutDiscount
			from 
			TB_ORDER_DTL as tod
			join
			@existingUpdatedDtls as od on od.id = tod.id;







		--insert newley added order dtls
		INSERT INTO TB_ORDER_DTL (
			[fk_orderHdr_id]
			,[fk_store_id]
			,[fk_item_id]
			,[vfk_store_item_color_id]
			,[vfk_store_item_size_id]
			,[vfk_store_item_warranty]
			,[canBePurchasedWithoutWarranty]
			,[fk_status_id]
			,[qty]
			,[sum_qty]
			,[delivered]
			,[sum_delivered]
			,[sum_remainingToDelivery]
			,[cost_warranty]
			,[warrantyDays]
			,[cost_oneUnit_withoutDiscount]
			,[cost_oneUnit_withDiscount]
			,[discount_minCnt]
			,[discount_percent]
			,[cost_discount]
			,[taxRate]
			,[item_includedTax]
			,[store_calculateTax]
			,[prepaymentPercent]
			,[cost_prepayment]
			,[cost_prepayment_remaining]
			,[cancellationPenaltyPercent]
			,[cost_cancellationPenalty]
			,[validityTimeOfOrder]
			,[store_taxIncludedInPrices]
			,[cost_totalTax_included]
			,[cost_totalTax_info]
			,[cost_payable_withoutTax]
			,[cost_payable_withTax_withDiscount]
			,[cost_payable_withTax_withDiscount_totalPaid]
			,[cost_payable_withTax_withDiscount_remaining]
			,[cost_payable_withTax_withoutDiscount]
			,[cost_totalTax_included_withoutDiscount]
			,[cost_payable_withoutTax_withoutDiscount]
			)
		SELECT @lastOrderHdrId
			,@storeId
			,nd.fk_item_id
			,nd.vfk_store_item_color_id
			,nd.vfk_store_item_size_id
			,nd.vfk_store_item_warranty
			,nd.canBePurchasedWithoutWarranty
			,39
			,--[fk_status_id]
			nd.qty
			,0
			,--sum_qty
			0
			,--delivered
			0
			,--sum_delivered
			nd.qty
			,--sum_remainingToDelivery
			nd.cost_warranty
			,nd.warrantyDays
			,nd.cost_oneUnit_withoutDiscount
			,NULL
			,--cost_oneUnit_withDiscount
			nd.discount_minCnt
			,nd.discount_percent
			,NULL
			,--cost_discount
			nd.taxRate
			,nd.item_includedTax
			,nd.store_calculateTax
			,nd.prepaymentPercent
			,NULL
			,--cost_prepayment
			NULL
			,--cost_prepayment_remaining
			nd.cancellationPenaltyPercent
			,NULL
			,--cost_cancellationPenalty
			nd.validityTimeOfOrder
			,nd.store_taxIncludedInPrices
			,NULL
			,--cost_totalTax_included
			NULL
			,--cost_totalTax_info
			NULL
			,--cost_payable_withoutTax
			NULL
			,--cost_payable_withTax_withDiscount
			NULL
			,--cost_payable_withTax_withDiscount_totalPaid
			NULL
			,--cost_payable_withTax_withDiscount_remaining
			NULL
			,--cost_payable_withTax_withoutDiscount
			NULL
			,--cost_totalTax_included_withoutDiscount
			NULL --cost_payable_withoutTax_withoutDiscount
		FROM @newlyAddedDtls AS nd;
			--	DECLARE c_dtls CURSOR LOCAL
			--	FOR
			--	SELECT *
			--	FROM @OrderItemType;
			--  fetch next from c_dtls
			--  into
			--  @dtl_id ,
			--@dtl_fk_item_id ,
			--@dtl_vfk_store_item_color_id ,
			--@dtl_vfk_store_item_size_id ,
			--@dtl_vfk_store_item_warranty ,
			--@dtl_qty ,
			--@dtl_delivered ;
			--IF (@@FETCH_STATUS <> 0)
			--BEGIN
			--	CLOSE c_dtls;
			--	DEALLOCATE c_dtls;
			--	SET @rMsg = dbo.func_getSysMsg('invalidOrderHdrId', OBJECT_NAME(@@PROCID), @ClientLanguage, 'invalid order Hdr ID');
			--	GOTO fail;
			--END
			--WHILE (@@FETCH_STATUS = 0)
			--BEGIN
			--if(@dtl_id is not null)
			--begin
			--	update TB_ORDER_DTL
			--	set
			--	fk_item_id=@dtl_fk_item_id,
			--	fk_item_id = @dtl_fk_item_id,
			--	vfk_store_item_color_id=@dtl_vfk_store_item_color_id,
			--	vfk_store_item_size_id=@dtl_vfk_store_item_size_id,
			--	vfk_store_item_warranty=@dtl_vfk_store_item_warranty,
			--	qty=@dtl_qty,
			--	delivered=@dtl_delivered
			--	where
			--	id = @dtl_id ;
			--end
			--ENd

		



	END --of ثبت نهایی سفارش

	COMMIT TRAN t1;
END TRY

BEGIN CATCH
	SET @rMsg = ERROR_MESSAGE();

	GOTO fail;
END CATCH;

success:

SET @rCode = 1;
SET @rMsg = 'success.';

RETURN 0;

fail:

ROLLBACK TRAN t1;

SET @rCode = 0;

RETURN 0;
