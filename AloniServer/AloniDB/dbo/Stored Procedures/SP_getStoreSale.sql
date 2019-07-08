CREATE PROCEDURE [dbo].[SP_getStoreSale]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = null,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@storeId as bigint,
	@userId as bigint
AS
	set nocount on
	declare @storeAccountId as bigint
	select @storeAccountId = id from TB_FINANCIAL_ACCOUNT where fk_store_id = @storeId and fk_typFinancialAccountType_id = 1 and fk_status_id = 35
	select 
		sum(credit) - SUM(debit) sale,dbo.func_getDateByLanguage(@clientLanguage,saveDatetime,0) date
	from 
		TB_FINANCIAL_ACCOUNTING
	where fk_UsrFinancialAccount_id = @storeAccountId
		group by saveDatetime
	having DATEDIFF(DAY,saveDatetime,GETDATE()) < 10
	
	select 
	[dbo].[func_getPriceAsDisplayValue](cast(sum(credit) - SUM(debit) as varchar(20)),@clientLanguage,@storeId) as account-- cast(sum(credit) - SUM(debit) as varchar(20)) + dbo.func_getCurrencyTitleByLanguage(@clientLanguage,@storeId,1) account
	from 
	TB_FINANCIAL_ACCOUNTING
	where fk_UsrFinancialAccount_id = @storeAccountId

	select 
		COUNT(pk_fk_item_id) withoutstock
	from 
		TB_STORE_ITEM_QTY as q
		inner join TB_ITEM as i
		inner join TB_TYP_ITEM_GRP G on i.fk_itemGrp_id = g.id
		on q.pk_fk_item_id = i.id --and (i.displayMode is null or i.displayMode = 0)
	where pk_fk_store_id = @storeId and qty <= 0 and g.type = 1 --and fk_status_id = 15

	select 
		COUNT(pk_fk_item_id) orderPoint
	from 
		TB_STORE_ITEM_QTY  as q
		inner join TB_ITEM as i
		inner join TB_TYP_ITEM_GRP G on i.fk_itemGrp_id = g.id
		on q.pk_fk_item_id = i.id --and (i.displayMode is null or i.displayMode = 0)
	where pk_fk_store_id = @storeId and orderPoint >= qty and orderPoint > 0 and g.type = 1--and fk_status_id = 15

	select 
		count(id) orderIsRunning
	from
		TB_ORDER
	where 
		fk_store_storeId = @storeId and [dbo].[func_getOrderStatus](id,fk_status_statusId,lastDeliveryDateTime) = 101--select id from TB_STATUS where entityType = 'TB_ORDER_HDR' and isRunning = 1) 
	
	select 
		count(id) orderCanceled
	from
		TB_ORDER
	where 
		fk_store_storeId = @storeId and [dbo].[func_getOrderStatus](fk_status_statusId,fk_status_statusId,lastDeliveryDateTime) in (103,104) 
	
	select
	 H.id as orderId
	 ,ISNULL(u.fname,'') + ' ' + ISNULL(u.lname,'') name,dbo.func_calcActionOrderTime(@clientLanguage,saveDateTime) datetime_,
	d.countOfActiveDtls as tedAghlam
	from 
		TB_ORDER as H
		left join TB_USR U on h.fk_usr_customerId = u.id
		left join dbo.func_getOrderHdrs(null) d on h.id = d.orderId
	where h.fk_store_storeId = @storeId and [dbo].[func_getOrderStatus](h.id,h.fk_status_statusId,h.lastDeliveryDateTime) = 101 and h.fk_usr_reviewerUserId is null --کاربر بررسی کننده سفارش نال است.
	group by 
	h.id
	,u.fname
	,u.lname
	,saveDateTime
	,d.countOfActiveDtls
	order by h.saveDateTime desc
	

RETURN 0
