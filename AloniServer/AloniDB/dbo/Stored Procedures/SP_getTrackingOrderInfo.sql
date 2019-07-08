-- =============================================
-- Author:		Faramarz Bayatzadeh
-- Create date: 1397 03 02
-- Description:	return 3 table of order data
-- =============================================
CREATE PROCEDURE [dbo].[SP_getTrackingOrderInfo]
	@clientLanguage as char(2) = null,
	@appId as tinyint = null,
	@clientIp as varchar(50) = null,
	@orderId as bigint
AS
BEGIN
	SET NOCOUNT ON;
	declare @storeId AS bigint = (select storeId from dbo.func_getOrderHdrs(@orderId));
	select 
	  (select title from TB_STORE where id = storeId) AS storeTitle,
      null AS LastDocType,--(select docType.title from TB_ORDER_HDR AS ordHdr inner join TB_TYP_ORDER_DOC_TYPE AS docType on ordHdr.fk_docType_id = docType.id Where ordHdr.id = lastOrderHdrId)
      ISNULL(CAST(countOfActiveDtls AS varchar(50)), '') AS   countOfActiveDtls,      
      null as lastOrderHdrId,
	  orderId,
	  orderId_str,     
	  storeId,
	  ISNULL(dbo.func_getPriceAsDisplayValue(sum_cost_delivery,'fa',storeId), '') AS sum_cost_delivery,
	  ISNULL(dbo.func_getPriceAsDisplayValue(sum_cost_delivery_Paid,'fa',storeId), '') AS sum_cost_delivery_Paid,
	  ISNULL(dbo.func_getPriceAsDisplayValue(sum_cost_delivery_remaining,'fa',storeId), '') AS sum_cost_delivery_remaining,
      ISNULL(dbo.func_getPriceAsDisplayValue(sum_cost_discount,'fa',storeId), '') AS sum_cost_discount,              
      ISNULL(dbo.func_getPriceAsDisplayValue(sum_cost_payable_withoutTax_withoutDiscount,'fa',storeId), '') AS sum_cost_payable_withoutTax_withoutDiscount,              
      ISNULL(dbo.func_getPriceAsDisplayValue(sum_cost_payable_withTax_withDiscount,'fa',storeId), '') AS sum_cost_payable_withTax_withDiscount,             
      ISNULL(dbo.func_getPriceAsDisplayValue(sum_cost_payable_withTax_withDiscount_remaining,'fa',storeId), '') AS sum_cost_payable_withTax_withDiscount_remaining,            
      ISNULL(dbo.func_getPriceAsDisplayValue(sum_cost_payable_withTax_withoutDiscount,'fa',storeId), '') AS sum_cost_payable_withTax_withoutDiscount,             
      ISNULL(dbo.func_getPriceAsDisplayValue(sum_cost_prepayment_remaining,'fa',storeId), '') AS sum_cost_prepayment_remaining,             
      ISNULL(dbo.func_getPriceAsDisplayValue(sum_cost_totalTax_info,'fa',storeId), '') AS sum_cost_totalTax_info,           
      ISNULL(dbo.func_getPriceAsDisplayValue(sum_delivery,'fa',storeId), '') AS sum_delivery,             
	  ISNULL(dbo.func_getPriceAsDisplayValue(sum_paid,'fa',storeId), '') AS sum_paid,
	  ISNULL(dbo.func_addThousandsSeperator(sum_sum_qty), '') AS sum_sum_qty,
	  ISNULL(dbo.func_getPriceAsDisplayValue(total_paid,'fa',storeId), '') AS total_paid,
	  ISNULL(dbo.func_getPriceAsDisplayValue(total_payment_payable,'fa',storeId), '') AS total_payment_payable,
      ISNULL(dbo.func_getPriceAsDisplayValue(total_remaining_payment_payable,'fa',storeId), '') AS total_remaining_payment_payable,              
      ISNULL(dbo.func_getPriceAsDisplayValue(total_remaining_prepayment_payable,'fa',storeId), '') AS total_remaining_prepayment_payable           
	 from dbo.func_getOrderHdrs(@orderId)


	 select 
      ISNULL(dbo.func_addThousandsSeperator(cancellationPenaltyPercent), '') AS  cancellationPenaltyPercent,
      ISNULL(colorId, '') AS colorId,
      ISNULL(dbo.func_getPriceAsDisplayValue(cost_cancellationPenalty, 'fa', @storeId), '') AS cost_cancellationPenalty,
      ISNULL(dbo.func_getPriceAsDisplayValue(cost_discount, 'fa', @storeId), '') AS cost_discount,
      ISNULL(dbo.func_getPriceAsDisplayValue(cost_oneUnit_withDiscount, 'fa', @storeId), '') AS cost_oneUnit_withDiscount,
      ISNULL(dbo.func_getPriceAsDisplayValue(cost_oneUnit_withoutDiscount, 'fa', @storeId), '') AS cost_oneUnit_withoutDiscount,
      ISNULL(dbo.func_getPriceAsDisplayValue(cost_payable_withoutTax, 'fa', @storeId), '') AS cost_payable_withoutTax,
      ISNULL(dbo.func_getPriceAsDisplayValue(cost_payable_withoutTax_withoutDiscount, 'fa', @storeId), '') AS cost_payable_withoutTax_withoutDiscount,
      ISNULL(dbo.func_getPriceAsDisplayValue(cost_payable_withTax_withDiscount, 'fa', @storeId), '') AS cost_payable_withTax_withDiscount,
      ISNULL(dbo.func_getPriceAsDisplayValue(cost_payable_withTax_withDiscount_remaining, 'fa', @storeId), '') AS cost_payable_withTax_withDiscount_remaining,
      ISNULL(dbo.func_getPriceAsDisplayValue(cost_payable_withTax_withoutDiscount, 'fa', @storeId), '') AS cost_payable_withTax_withoutDiscount,
      ISNULL(dbo.func_getPriceAsDisplayValue(cost_prepayment, 'fa', @storeId), '') AS cost_prepayment,
      ISNULL(dbo.func_getPriceAsDisplayValue(cost_prepayment_remaining, 'fa', @storeId), '') AS cost_prepayment_remaining,
      ISNULL(dbo.func_getPriceAsDisplayValue(cost_totalTax_included, 'fa', @storeId), '') AS cost_totalTax_included,
      ISNULL(dbo.func_getPriceAsDisplayValue(cost_totalTax_included_withoutDiscount, 'fa', @storeId), '') AS cost_totalTax_included_withoutDiscount,
      ISNULL(dbo.func_getPriceAsDisplayValue(cost_totalTax_info, 'fa', @storeId), '') AS cost_totalTax_info,
      ISNULL(dbo.func_getPriceAsDisplayValue(cost_warranty, 'fa', @storeId), '') AS cost_warranty,
      ISNULL(dbo.func_addThousandsSeperator(deliveryRemaining), '') AS  deliveryRemaining,
      ISNULL(dbo.func_getPriceAsDisplayValue(discount_minCnt, 'fa', @storeId), '') AS discount_minCnt,
      ISNULL(dbo.func_addThousandsSeperator(discount_percent), '') AS  discount_percent,
      itemId,
      null as lastOrderDtlId,
      orderId,
      ISNULL(dbo.func_addThousandsSeperator(prepaymentPercent), '') AS  prepaymentPercent,
      rowId,
      ISNULL(sizeId, '') AS sizeId,
      item_includedTax,
      CASE WHEN item_includedTax IS NOT NULL AND item_includedTax = 1 THEN 'شامل ارزش افزوده مي شود' ELSE 'شامل ارزش افزوده نمي شود' END AS item_includedTax_title,
      store_calculateTax,
      CASE WHEN store_calculateTax IS NOT NULL AND store_calculateTax = 1 THEN 'ارزش افزوده فروشگاه حساب شده است' ELSE 'ارزش افزوده فروشگاه حساب نشده است' END AS store_calculateTax_title,
      store_taxIncludedInPrices,
      CASE WHEN store_taxIncludedInPrices IS NOT NULL AND store_taxIncludedInPrices = 1 THEN 'ارزش افزوده در مبلغ حساب شده است' ELSE 'ارزش افزوده در مبلغ حساب نشده است' END AS store_taxIncludedInPrices,
      ISNULL(dbo.func_getPriceAsDisplayValue(sumPaid, 'fa', @storeId), '') AS sumPaid,
      ISNULL(dbo.func_addThousandsSeperator(sum_delivered), '') AS  sum_delivered,
      ISNULL(dbo.func_addThousandsSeperator(sum_qty), '') AS  sum_qty,
      ISNULL(dbo.func_addThousandsSeperator(taxRate), '') AS  taxRate,
      warrantyId,
      ISNULL((select title from TB_ITEM WHERE id = itemId), '') AS itemTitle,
      ISNULL(dbo.func_getPriceAsDisplayValue((select warrantyCost from TB_STORE_ITEM_WARRANTY where pk_fk_storeWarranty_id = warrantyId), 'fa', @storeId), '') AS warrantyCost,
      ISNULL((select warrantyDays from TB_STORE_ITEM_WARRANTY where pk_fk_storeWarranty_id = warrantyId) , '') AS warrantyDays
     from dbo.func_getOrderDtls(@orderId,null)


	 CREATE TABLE #historyOrder
     (
       fk_docType_id  smallint,
       userName  nvarchar(50),
       userStaff  nvarchar(50),
       actionType_dsc  nvarchar(50),
       changeDateTime_dsc  nvarchar(50),
       changeDateTime  dateTime,
       changeDtls  nvarchar(50),
     );

     Insert into #historyOrder
     Exec dbo.SP_order_getChangeHistory 'fa' , 3, null, null, null, null, @orderId, null, null
     select 
     fk_docType_id,
     ISNULL(userName, '') AS userName,
     ISNULL(userStaff, '') AS userStaff,
     ISNULL(actionType_dsc, '') AS actionType_dsc,
     ISNULL(dbo.func_udf_Gregorian_To_Persian_withTime(changeDateTime), '') AS changeDateTime_dsc,
     changeDateTime,
     ISNULL(changeDtls, '') AS changeDtls,
     ISNULL(dbo.func_udf_Gregorian_To_PersianLetters(changeDateTime), '') AS changeDateTimeWithoutTime_dsc,
     CAST(REPLACE((select dbo.func_udf_Gregorian_To_Persian(changeDateTime)),'/','') AS bigint) AS date
     from #historyOrder

END