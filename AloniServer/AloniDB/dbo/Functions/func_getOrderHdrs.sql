CREATE FUNCTION [dbo].[func_getOrderHdrs]
(
	@orderId as bigint
)
RETURNS @returntable TABLE
(
	orderId bigint,
	orderId_str varchar(36),
	sum_sum_qty money,--#مجموع_مقدار ردیف ها_sum(A)
	sum_cost_delivery money,--#مجموع هزینه ارسال تا کنون_E
	sum_cost_delivery_Paid money,--#مجموع هزینه ارسال تا کنون پرداخت شده_F
	sum_cost_delivery_remaining as sum_cost_delivery + sum_cost_delivery_Paid,--#باقی مانده قابل پرداخت از مجموع هزینه ارسال پرداخت شده تا کنون_C
	sum_cost_payable_withTax_withDiscount_remaining money,--#مجموع هزینه مانده قابل پرداخت برای کلیه ردیفها_J 
	sum_cost_prepayment_remaining money,--#مجموع مانده مبلغ پیش پرداخت قابل پرداخت برای کلیه ردیفها
	total_remaining_payment_payable as isnull( sum_cost_payable_withTax_withDiscount_remaining,0) + (isnull( sum_cost_delivery,0) + isnull(sum_cost_delivery_Paid,0)) ,--#مانده قابل پرداخت کل( مجموع هزینه مانده قابل پرداخت برای کلیه ردیفها + sum_cost_delivery_remaining)
	total_remaining_prepayment_payable as isnull(sum_cost_prepayment_remaining,0) + isnull( sum_cost_delivery - sum_cost_delivery_Paid,0),--#مانده پیش پرداخت قابل پرداخت کل با احتساب هزینه ارسال
	sum_sent money,--#مجموع ارسال شده ردیف ها
	sum_delivery money,--#مجموع تحویل شده ردیف ها
	sum_deliveryRemaining money,--مجموع مانده تحویل نشده ردیف ها
	sum_cost_payable_withTax_withoutDiscount money,--# مجموع هزینه قابل پرداخت ردیف با احتساب ارزش افزوده بر اساس قیمت کالا بدون تخفیف_مجموع کلیه ردیف ها
	countOfActiveDtls int,--#تعداد ردیف های فعال سفارش
	sum_cost_discount money,--#مجموع تخفیف برای ردیف های فعال
	sum_cost_totalTax_info money,--#مجموع مبالغ ارزش افزوده کلیه ردیف های فعال به منظور نمایش در فاکتور
	sum_cost_payable_withoutTax_withoutDiscount money,--#مجموع هزینه قابل پرداخت ردیف بدون ارزش افزوده بر اساس قیمت کالا بدون تخفیف برای کلیه ردیف های فعال
	--lastOrderHdrId bigint,
	storeId bigint,
	sum_cost_payable_withTax_withDiscount money,
	total_payment_payable as isnull(sum_cost_payable_withTax_withDiscount,0) + isnull(sum_cost_delivery,0),--مجموع هزینه قابل پرداخت کل (شامل هزینه سفارش و ارسال با احتساب تخفیفات و ارزش افزوده)
	sum_paid money, 
	total_paid as sum_paid + sum_cost_delivery_Paid,
	sum_sendRemaining money,--مجموع مانده ارسال نشده ردیف ها
	sum_receive money,--مجموع دریافت شده ردیف ها
	sum_deliveredRemainingToReceive money -- مجموع قابل دریافت از مجموع تحویل شده ردیف ها

)
AS
BEGIN
	--INSERT @returntable
	----SELECT @param1, @param2



	with baseData as
	(
		select 
		 d.orderId,
		 o.id_str as orderId_str,
		 o.fk_store_storeId,
			   sum(d.sum_qty) as sum_sum_qty,
			   sum(d.cost_payable_withTax_withDiscount_remaining) as sum_cost_payable_withTax_withDiscount_remaining,
			   sum(d.cost_prepayment_remaining) as sum_cost_prepayment_remaining,
			   sum(d.sum_sent) as sum_sent,
			   sum(d.sum_delivered) as sum_delivery,
			   sum(d.deliveryRemaining) as sum_deliveryRemaining,
			   sum(d.cost_payable_withTax_withoutDiscount) as sum_cost_payable_withTax_withoutDiscount,
			   --(select count(1) from [dbo].[func_getOrderDtls](@orderId,null) as dd where dd.sum_qty > 0) as countOfActiveDtls,
			   --count(1) as countOfActiveDtls,
			   sum (d.cost_discount) as sum_cost_discount,
			   sum (d.cost_totalTax_info) as sum_cost_totalTax_info,
			   sum(d.cost_payable_withoutTax_withoutDiscount) as sum_cost_payable_withoutTax_withoutDiscount,
			   sum(d.cost_payable_withTax_withDiscount) as sum_cost_payable_withTax_withDiscount,
			   sum(d.sumPaid) as sum_paid,
			   sum(d.sendRemaining) as sum_sendRemaining,
			   sum(d.sum_received) as sum_receive,
			   sum(d.deliveredRemainingToReceive) as sum_deliveredRemainingToReceive
	
		from  [dbo].[func_getOrderDtls](@orderId,null) as d
		join TB_ORDER as o on d.orderId = o.id
		group by d.orderId,o.id_str,o.fk_store_storeId
	),
	----deliveryData as
	----(
	----    select
	----	o.id as orderId,
	----	max(o.fk_store_storeId) as storeId,
	----	sum(isnull((case when hbase.delivery_includeCostOnInvoice is not null and hbase.delivery_includeCostOnInvoice = 1 then hbase.delivery_amount else 0 end),0)) as sum_cost_delivery,
	----	sum(isnull(ac.debit,0)) as sum_cost_delivery_Paid,
	----	max(hdr.id) as lastOrderHdrId
	----	from TB_ORDER_HDR as hdr
	----	join TB_ORDER as o on hdr.fk_order_orderId = o. id
	----	left join TB_ORDER_HDR_BASE as hbase on hdr.id = hbase.fk_orderHdr_id
	----	left join TB_FINANCIAL_ACCOUNTING as ac on hdr.id = ac.fk_orderHdr_id and ac.fk_typFinancialRegardType_id in (10011,10081,10131)
	----	where (@orderId is null or o.id = @orderId) and hdr.isVoid = 0
	----	group by o.id
	----)
	--baseDeliveryData as
	--(
	--    select
	--	o.id as orderId,
	--	o.fk_store_storeId as storeId,
	--	case when hbase.delivery_includeCostOnInvoice is not null and hbase.delivery_includeCostOnInvoice = 1 then hbase.delivery_amount else 0 end as cost_delivery,
	--	ac.debit as cost_delivery_Paid,
	--	hdr.id as lastOrderHdrId
	--	from TB_ORDER_HDR as hdr
	--	join TB_ORDER as o on hdr.fk_order_orderId = o. id
	--	left join TB_ORDER_HDR_BASE as hbase on hdr.id = hbase.fk_orderHdr_id
	--	left join TB_FINANCIAL_ACCOUNTING as ac on hdr.id = ac.fk_orderHdr_id and ac.fk_typFinancialRegardType_id in (10011,10081,10131)
	--	where (@orderId is null or o.id = @orderId) and hdr.isVoid = 0
	--),
	--deliveryData as
	--(
	--    select
	--	bda.orderId,
	--	max(bda.storeId) as storeId,
	--	isnull(sum(bda.cost_delivery),0) as sum_cost_delivery,
	--	isnull(sum(bda.cost_delivery_Paid),0) as sum_cost_delivery_Paid,
	--	max(bda.lastOrderHdrId) as lastOrderHdrId
	--	from baseDeliveryData as bda
	--	group by bda.orderId
	--)
	deliveryData as
	(
	    select dpayable.fk_order_orderId as orderId, dpayable.sum_cost_delivery,dpaid.sum_cost_delivery_Paid
		from
			(select oh.fk_order_orderId, sum(case when ohbase.delivery_includeCostOnInvoice is not null and ohbase.delivery_includeCostOnInvoice = 1 then ohbase.delivery_amount else 0 end) as sum_cost_delivery
			from TB_ORDER_HDR as oh
			join TB_ORDER_HDR_BASE as ohbase on oh.id = ohbase.fk_orderHdr_id
			where (@orderId is null or oh.fk_order_orderId = @orderId)
			group by oh.fk_order_orderId)
		as dpayable
		left join
			(select ac.fk_order_orderId, sum(ac.debit) as sum_cost_delivery_Paid 
			 from TB_FINANCIAL_ACCOUNTING as ac 
			 where ac.fk_order_orderId is not null and (@orderId is null or fk_order_orderId = @orderId) and ac.fk_typFinancialRegardType_id in (10011,10081,10131) 
			 group by ac.fk_order_orderId)
		 as dpaid		 
		 on dpayable.fk_order_orderId = dpaid.fk_order_orderId
	)

	INSERT @returntable
	select
	  b.orderId
	  ,b.orderId_str
	  ,b.sum_sum_qty
	  ,isnull(d.sum_cost_delivery,0)
	  ,isnull(d.sum_cost_delivery_Paid,0)
	  ,b.sum_cost_payable_withTax_withDiscount_remaining
	  ,b.sum_cost_prepayment_remaining
	  ,b.sum_sent
	  ,b.sum_delivery
	  ,b.sum_deliveryRemaining
	  ,b.sum_cost_payable_withTax_withoutDiscount
	  ,(select count(1) from [dbo].[func_getOrderDtls](b.orderId,null) as dd where dd.sum_qty > 0) as countOfActiveDtls--b.countOfActiveDtls
	  ,b.sum_cost_discount
	  ,b.sum_cost_totalTax_info
	  ,b.sum_cost_payable_withoutTax_withoutDiscount	
	  --,d.lastOrderHdrId
	  ,b.fk_store_storeId
	  ,b.sum_cost_payable_withTax_withDiscount
	  ,isnull(b.sum_paid,0)
	  ,b.sum_sendRemaining
	  ,b.sum_receive
	  ,b.sum_deliveredRemainingToReceive
	 from
	 baseData as b
	 left join deliveryData as d on b.orderId = d.orderId

	RETURN
END