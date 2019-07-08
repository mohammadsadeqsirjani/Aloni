CREATE TYPE [dbo].[UDT_func_getOrderDtlsTableType] AS TABLE
(
	--c1 int,
	--c2 as c1+2
	orderId bigint,
	rowId int,
	sum_qty money,
	sum_sent money,--مجموع مقداری ارسال شده
	sendRemaining money,--مانده قابل ارسال
	sum_delivered money,
	deliveryRemaining money, --as sum_qty - sum_delivered,
	sentRemainingToDelivery money,
	sumPaid money,--باید کوچکتر یا مساوی صفر باشد
	discount_minCnt money,
	cost_oneUnit_withoutDiscount money,
	discount_percent money,
	cost_oneUnit_withDiscount money,--  as (case when sum_qty >= discount_minCnt then cost_oneUnit_withoutDiscount - (cost_oneUnit_withoutDiscount * discount_percent) else @cost_oneUnit_withoutDiscount end),
	cost_warranty money,
	cost_payable_withoutTax money,-- as sum_qty * (cost_oneUnit_withDiscount + cost_warranty),
	store_taxIncludedInPrices bit,
	store_calculateTax bit,
	item_includedTax bit,
	taxRate money,
	cost_totalTax_included  money,-- as case when store_taxIncludedInPrices <> 1 and store_calculateTax = 1 and item_includedTax = 1 then cost_payable_withoutTax * taxRate else 0 end,
	cost_payable_withTax_withDiscount money, -- as  cost_totalTax_included + cost_payable_withoutTax,
	cost_payable_withTax_withDiscount_remaining money, --as cost_payable_withTax_withDiscount + sumPaid,
	cost_totalTax_info money ,-- as case when store_calculateTax =1 and item_includedTax = 1 then cost_payable_withoutTax * taxRate else cost_totalTax_info end,
	cost_payable_withoutTax_withoutDiscount money, -- as sum_qty * (cost_oneUnit_withoutDiscount + cost_warranty),
	cost_totalTax_included_withoutDiscount money,-- as case when @store_taxIncludedInPrices <> 1	AND @store_calculateTax = 1	AND @item_includedTax = 1 then cost_payable_withoutTax_withoutDiscount * @taxRate else 0 end,
	cost_payable_withTax_withoutDiscount money ,-- as cost_totalTax_included_withoutDiscount + cost_payable_withoutTax_withoutDiscount,
	cost_discount money, -- @cost_payable_withTax_withDiscount - @cost_payable_withTax_withoutDiscount,
	prepaymentPercent money,
	cost_prepayment money, -- as cost_payable_withTax_withDiscount * prepaymentPercent,
	cancellationPenaltyPercent money,
	cost_cancellationPenalty money ,-- as cancellationPenaltyPercent * cost_prepayment,
	cost_prepayment_remaining money ,-- as case when cost_prepayment + @cost_payable_withTax_withDiscount_totalPaid > 0 then cost_prepayment + @cost_payable_withTax_withDiscount_totalPaid else 0 end,
	itemId bigint,
	colorId varchar(20),
	sizeId nvarchar(500),
	warrantyId bigint
	--,lastOrderDtlId bigint
)
