CREATE PROCEDURE [dbo].[SP_getUserStatistic]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = null,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@userId as bigint
AS
	SET NOCOUNT ON
	
	select isnull(count(id),0) msgCnt from TB_MESSAGE where fk_usr_destUserId = @userId and seenDateTime is null;
 

select isnull(count(o.id),0) as cartCnt,
		 isnull(sum(oh.countOfActiveDtls),0) as itemsInCartsCnt
		
		 from dbo.func_getOrderHdrs(null) as oh
		join TB_ORDER as o on oh.orderId = o.id
		where o.fk_usr_customerId = @userId and
		 [dbo].[func_getOrderStatus](o.id,o.fk_status_statusId,o.lastDeliveryDateTime) = 100
		 
	--from
	--TB_ORDER as o
	--join dbo.func_getOrderDtls(null,null) as d on o.id = d.orderid
	--where o.fk_status_statusId = 100 and o.fk_usr_customerId = @userId and d.sum_qty <> 0

	--select count(id) orderCnt from TB_ORDER where fk_usr_customerId = @userId and fk_status_statusId = 100
RETURN 0
