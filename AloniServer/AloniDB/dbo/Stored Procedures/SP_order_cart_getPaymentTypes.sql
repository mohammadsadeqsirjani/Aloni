CREATE PROCEDURE [dbo].[SP_order_cart_getPaymentTypes]
		@clientLanguage AS CHAR(2)
	,@clientIp AS VARCHAR(50)
	,@appId as tinyint
	,@userId as bigint
 
	--,@orderHdrId AS bigint
	,@orderId as bigint
    ,@pageNo as int = null
	,@search as nvarchar(100) = null
	,@parent as varchar(20) = null
AS
select top(1)
 case when (ISNULL(hdr.total_remaining_payment_payable,0) - ISNULL(hdr.total_remaining_prepayment_payable,0) ) > 0 then 1 else 0 end as hasPrePayment,
 1 as cash,0 as credit,case when st.fk_OnlinePayment_StatusId = 13 then 1 else 0 end as [online]
 from
 dbo.[func_getOrderHdrs](@orderId) as hdr
 join 
 TB_STORE as st with(nolock)
 on hdr.storeId = st.id