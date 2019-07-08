CREATE FUNCTION [dbo].[func_getOrderDtls]
(
	@orderId as bigint,
	@rowId as int
)
RETURNS @returntable TABLE
(
	--c1 int,
	--c2 as c1+2
	orderId bigint,
	rowId int,
	sum_qty money,--مجموع مقداری مقادیر ردیف
	sum_sent money,--مجموع مقداری ارسال شده
	sendRemaining money,--مانده قابل ارسال
	sum_delivered money,--مجموع مقداری تحویل شده
	deliveryRemaining money, --as sum_qty - sum_delivered, --مانده قابل تحویل

	sentRemainingToDelivery as sum_sent - sum_delivered, -- مانده قابل تحویل از مجموع ارسال شده

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
	colorId varchar(50),
	sizeId nvarchar(500),
	warrantyId bigint,
	sum_received money,--مجموع دریافت شده
	deliveredRemainingToReceive as sum_delivered - sum_received, -- مانده قابل دریافت از مجموع تحویل شده
	--,lastOrderDtlId bigint
	store_promo_discount_percent money,--درصد تخفیف کلی فروشگاه بر روی تمامی کالا ها (پروموشن)
	cost_color money,
	cost_size money
)
AS
BEGIN
	--INSERT @returntable
	--SELECT @param1, @param2
	--RETURN

	with baseData
as

(
select
dts.fk_order_id
,dts.rowId
,dts.sum_qty-- #مقدار ردیف _ تجمیع شده_A
,dts.sum_sent
,dts.sum_delivered--#مجموع مقدار تحویل شده تا کنون_M
,dts.fk_item_id as itemId
,dts.vfk_store_item_color_id as colorId
,dts.vfk_store_item_size_id as sizeId
,dts.vfk_store_item_warranty as warrantyId
,paidInfo.sumPaid
,dts.discount_minCnt
,dts.cost_oneUnit_withoutDiscount
,dts.discount_percent
,dts.cost_warranty
,dts.store_taxIncludedInPrices
,dts.store_calculateTax
,dts.item_includedTax
,dts.taxRate
,dts.prepaymentPercent
,dts.cancellationPenaltyPercent
,dts.sum_recived
--,max(dts.lastOrderDtlId ) lastOrderDtlId
,dts.store_promo_discount_percent
,dts.cost_color
,dts.cost_size
from
	(select 
	 d.fk_order_id 
	,d.rowId 
	,d.fk_item_id 
	,d.vfk_store_item_color_id 
	,d.vfk_store_item_size_id 
	,d.vfk_store_item_warranty 
	,sum(d.qty) as sum_qty 
	,sum(d.[sent]) as sum_sent 
	,sum(d.delivered) as sum_delivered
	,p.discount_minCnt
	,p.cost_oneUnit_withoutDiscount
	,p.discount_percent
	,isnull(p.cost_warranty,0) as cost_warranty
	,p.store_taxIncludedInPrices
	,p.store_calculateTax
	,p.item_includedTax
	,p.taxRate
	,p.prepaymentPercent
	,p.cancellationPenaltyPercent
	--,max(d.id) as lastOrderDtlId 
	,sum(d.received) as sum_recived
	,p.store_promo_discount_percent
	,p.cost_color
	,p.cost_size
	from TB_ORDER_DTL as d
	join TB_ORDER_DTL_BASE as p 
	on d.fk_order_id = p.orderId and d.rowId = p.rowId
	where (@orderId is null or (d.fk_order_id = @orderId and (@rowId is null or d.rowId = @rowId))) and d.isVoid = 0 
    group by 
	 d.fk_order_id 
	,d.rowId 
	,d.fk_item_id 
	,d.vfk_store_item_color_id 
	,d.vfk_store_item_size_id
    ,d.vfk_store_item_warranty
	,p.discount_minCnt
	,p.cost_oneUnit_withoutDiscount
	,p.discount_percent
	,p.cost_warranty
	,p.store_taxIncludedInPrices
	,p.store_calculateTax
	,p.item_includedTax
	,p.taxRate
	,p.prepaymentPercent
	,p.cancellationPenaltyPercent
	,p.store_promo_discount_percent
	,p.cost_color
	,p.cost_size)
as dts
 left join
	(select ac.fk_order_orderId,ac.orderDtlRowId, sum(isnull(ac.debit,0)) as sumPaid --کوچکتر یا مساوی صفر باید باشد
	from TB_FINANCIAL_ACCOUNTING as ac-- on dts.fk_order_id = ac.fk_order_orderId and dts.rowId = ac.orderDtlRowId
	where ac.fk_order_orderId is not null and (@orderId is null or (ac.fk_order_orderId = @orderId and (@rowId is null or ac.orderDtlRowId = @rowId))) and ac.fk_typFinancialRegardType_id in (10001,10041,10051,10061,10071,10091,10101,10111,10121)
	group by ac.fk_order_orderId,ac.orderDtlRowId
	)
 as paidInfo
 on dts.fk_order_id = paidInfo.fk_order_orderId and dts.rowId = paidInfo.orderDtlRowId
)


INSERT @returntable
(orderId,
rowId,
sum_qty,
sum_sent,
sum_delivered,
sumPaid,
discount_minCnt,
cost_oneUnit_withoutDiscount,
discount_percent,
cost_warranty,
store_taxIncludedInPrices,
store_calculateTax,
item_includedTax,
taxRate,
prepaymentPercent,
cancellationPenaltyPercent,
itemId,
colorId,
sizeId,
warrantyId,
--lastOrderDtlId
sum_received,
store_promo_discount_percent,
cost_color,
cost_size
)
(select
	  b.fk_order_id
	 ,b.rowId
	 ,b.sum_qty
	 ,b.sum_sent
	 ,b.sum_delivered
	 ,b.sumPaid
	,b.discount_minCnt
	,b.cost_oneUnit_withoutDiscount
	,b.discount_percent
	,b.cost_warranty
	,b.store_taxIncludedInPrices
	,b.store_calculateTax
	,b.item_includedTax
	,b.taxRate
	,b.prepaymentPercent
	,b.cancellationPenaltyPercent
	,b.itemId
    ,b.colorId
	,b.sizeId
	,b.warrantyId
	--,b.lastOrderDtlId
	,b.sum_recived
	,b.store_promo_discount_percent
	,b.cost_color
	,b.cost_size
 from 
 baseData as b);



 declare--متغیر های اطلاعاتی
    @c_orderId as bigint,
	@c_rowId as int,
	@c_sum_qty as money,
	@c_sum_sent as money,
	@c_sum_delivered as money,
    @c_sumPaid as money,--باید کوچکتر یا مساوی صفر باشد
	@c_discount_minCnt as money,
	@c_cost_oneUnit_withoutDiscount as money,
	@c_discount_percent as money,
	@c_cost_warranty as money,
    @c_store_taxIncludedInPrices as bit,
	@c_store_calculateTax as bit,
	@c_item_includedTax as bit,
	@c_taxRate as money,
	@c_prepaymentPercent as money,
	@c_cancellationPenaltyPercent as money,
	@c_itemId as bigint,
	@c_store_promo_discount_percent as money,

	@c_cost_color as money,
	@c_cost_size as money;






	declare--متغیر های محاسباتی
	@sendRemaining as money,
	@deliveryRemaining money, --as sum_qty - sum_delivered,
    @cost_oneUnit_withDiscount money,--  as (case when sum_qty >= discount_minCnt then cost_oneUnit_withoutDiscount - (cost_oneUnit_withoutDiscount * discount_percent) else @cost_oneUnit_withoutDiscount end),
    @cost_payable_withoutTax money,-- as sum_qty * (cost_oneUnit_withDiscount + cost_warranty),
	@cost_totalTax_included  money,-- as case when store_taxIncludedInPrices <> 1 and store_calculateTax = 1 and item_includedTax = 1 then cost_payable_withoutTax * taxRate else 0 end,
	@cost_payable_withTax_withDiscount money, -- as  cost_totalTax_included + cost_payable_withoutTax,
	@cost_payable_withTax_withDiscount_remaining money, --as cost_payable_withTax_withDiscount + sumPaid,
	@cost_totalTax_info money ,-- as case when store_calculateTax =1 and item_includedTax = 1 then cost_payable_withoutTax * taxRate else cost_totalTax_info end,
	@cost_payable_withoutTax_withoutDiscount money, -- as sum_qty * (cost_oneUnit_withoutDiscount + cost_warranty),
	@cost_totalTax_included_withoutDiscount money,-- as case when @store_taxIncludedInPrices <> 1	AND @store_calculateTax = 1	AND @item_includedTax = 1 then cost_payable_withoutTax_withoutDiscount * @taxRate else 0 end,
	@cost_payable_withTax_withoutDiscount money ,-- as cost_totalTax_included_withoutDiscount + cost_payable_withoutTax_withoutDiscount,
	@cost_discount money, -- @cost_payable_withTax_withDiscount - @cost_payable_withTax_withoutDiscount,
	@cost_prepayment money, -- as cost_payable_withTax_withDiscount * prepaymentPercent,
    @cost_cancellationPenalty money ,-- as cancellationPenaltyPercent * cost_prepayment,
	@cost_prepayment_remaining money ;-- as case when cost_prepayment + @cost_payable_withTax_withDiscount_totalPaid > 0 then cost_prepayment + @cost_payable_withTax_withDiscount_totalPaid else 0 end,






 declare cr cursor for
 select 
 orderId,
rowId,
sum_qty,
sum_sent,
sum_delivered,
sumPaid,
discount_minCnt,
cost_oneUnit_withoutDiscount,
isnull(discount_percent,0),
cost_warranty,
store_taxIncludedInPrices,
store_calculateTax,
item_includedTax,
taxRate,
isnull(prepaymentPercent,0),
isnull(cancellationPenaltyPercent,0),
itemId,
isnull(store_promo_discount_percent,0),
cost_color,
cost_size
from 
@returntable;

open cr;

fetch next from cr into 
	@c_orderId ,
	@c_rowId ,
	@c_sum_qty ,
	@c_sum_sent,
	@c_sum_delivered ,
	@c_sumPaid ,--باید کوچکتر یا مساوی صفر باشد
	@c_discount_minCnt ,
	@c_cost_oneUnit_withoutDiscount ,
	@c_discount_percent ,
	@c_cost_warranty ,
	@c_store_taxIncludedInPrices ,
	@c_store_calculateTax ,
	@c_item_includedTax ,
	@c_taxRate ,
	@c_prepaymentPercent ,
	@c_cancellationPenaltyPercent ,
	@c_itemId,
	@c_store_promo_discount_percent,
	@c_cost_color,
	@c_cost_size;



	  WHILE @@FETCH_STATUS = 0  
    BEGIN  
	

	set @sendRemaining = @c_sum_qty - ISNULL(@c_sum_sent,0);
	set @deliveryRemaining = @c_sum_qty - isnull(@c_sum_delivered,0);
set @cost_oneUnit_withDiscount =  ROUND((case when @c_sum_qty >= @c_discount_minCnt then @c_cost_oneUnit_withoutDiscount - (@c_cost_oneUnit_withoutDiscount * (@c_discount_percent + @c_store_promo_discount_percent)) else (@c_cost_oneUnit_withoutDiscount - (@c_cost_oneUnit_withoutDiscount * @c_store_promo_discount_percent)) end),0);
set @cost_payable_withoutTax = @c_sum_qty * (@cost_oneUnit_withDiscount + isnull(@c_cost_warranty,0) + isnull(@c_cost_color,0) + isnull(@c_cost_size,0));
	set @cost_totalTax_included  =  ROUND(case when @c_store_taxIncludedInPrices <> 1 and @c_store_calculateTax = 1 and @c_item_includedTax = 1 then @cost_payable_withoutTax * @c_taxRate else 0 end,0);
	set @cost_payable_withTax_withDiscount =  @cost_totalTax_included + @cost_payable_withoutTax;
	set @cost_payable_withTax_withDiscount_remaining = @cost_payable_withTax_withDiscount + isnull(@c_sumPaid,0);
	set @cost_totalTax_info =  ROUND(case when @c_store_calculateTax =1 and @c_item_includedTax = 1 then @cost_payable_withoutTax * @c_taxRate else @cost_totalTax_info end,0);
	set @cost_payable_withoutTax_withoutDiscount = @c_sum_qty * (@c_cost_oneUnit_withoutDiscount + isnull(@c_cost_warranty,0) + isnull(@c_cost_color,0) + isnull(@c_cost_size,0) );
	set @cost_totalTax_included_withoutDiscount =  ROUND(case when @c_store_taxIncludedInPrices <> 1	AND @c_store_calculateTax = 1	AND @c_item_includedTax = 1 then @cost_payable_withoutTax_withoutDiscount * @c_taxRate else 0 end,0);
	set @cost_payable_withTax_withoutDiscount = @cost_totalTax_included_withoutDiscount + @cost_payable_withoutTax_withoutDiscount;
	set @cost_discount = @cost_payable_withoutTax - @cost_payable_withoutTax_withoutDiscount;
	set @cost_prepayment = ROUND(@cost_payable_withTax_withDiscount * @c_prepaymentPercent,0);
set @cost_cancellationPenalty = ROUND(@c_cancellationPenaltyPercent * @cost_prepayment,0);
	set @cost_prepayment_remaining = case when @cost_prepayment + isnull(@c_sumPaid,0) > 0 then @cost_prepayment + isnull(@c_sumPaid,0) else 0 end;








	update @returntable

	set 
	sendRemaining = @sendRemaining,
	deliveryRemaining = @deliveryRemaining,
	cost_oneUnit_withDiscount = @cost_oneUnit_withDiscount,
	cost_payable_withoutTax = @cost_payable_withoutTax,
	cost_totalTax_included = @cost_totalTax_included,
	cost_payable_withTax_withDiscount = @cost_payable_withTax_withDiscount,
	cost_payable_withTax_withDiscount_remaining = @cost_payable_withTax_withDiscount_remaining,
	cost_totalTax_info = @cost_totalTax_info,
	cost_payable_withoutTax_withoutDiscount =@cost_payable_withoutTax_withoutDiscount,
	cost_totalTax_included_withoutDiscount = @cost_totalTax_included_withoutDiscount,
	cost_payable_withTax_withoutDiscount =@cost_payable_withTax_withoutDiscount,
	cost_discount = @cost_discount,
	cost_prepayment = @cost_prepayment,
	cost_cancellationPenalty = @cost_cancellationPenalty,
	cost_prepayment_remaining =@cost_prepayment_remaining
	where orderId = @c_orderId and rowId = @c_rowId;





	


	fetch next from cr into 
	@c_orderId ,
	@c_rowId ,
	@c_sum_qty ,
	@c_sum_sent,
	@c_sum_delivered ,
	@c_sumPaid ,--باید کوچکتر یا مساوی صفر باشد
	@c_discount_minCnt ,
	@c_cost_oneUnit_withoutDiscount ,
	@c_discount_percent ,
	@c_cost_warranty ,
	@c_store_taxIncludedInPrices ,
	@c_store_calculateTax ,
	@c_item_includedTax ,
	@c_taxRate ,
	@c_prepaymentPercent ,
	@c_cancellationPenaltyPercent ,
	@c_itemId ,
	@c_store_promo_discount_percent,
	@c_cost_color,
	@c_cost_size;



	END


	CLOSE cr  
    DEALLOCATE cr  









 RETURN
END
