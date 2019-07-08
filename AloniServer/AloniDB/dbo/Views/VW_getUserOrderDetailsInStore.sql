

CREATE view [dbo].[VW_getUserOrderDetailsInStore]
as
select 
	s.id,
	i.id itemId,
	i.title,
	u.id userId,
	oh.fk_order_orderId,
	od.rowId,
	case when d.id is not null then 1 else 0 END hasPicture
from

	TB_STORE S 
	inner join TB_STORE_ITEM_QTY siq on s.id = siq.pk_fk_store_id
	inner join TB_ITEM I on siq.pk_fk_item_id = i.id
	inner join tb_order o on o.fk_store_storeId = s.id
	inner join TB_ORDER_HDR oh on o.id = oh.fk_order_orderId
	inner join TB_ORDER_DTL od on od.fk_orderHdr_id = oh.id and i.id = od.fk_item_id
	inner join TB_USR u on u.id = o.fk_usr_customerId
	left join tb_document_item di on di.pk_fk_item_id = i.id and di.isDefault = 1
	left join tb_document d on di.pk_fk_document_id = d.id
where
	o.fk_status_statusId not in(102,103)
	and
	i.fk_status_id = 15
	and
	siq.fk_status_id = 15
	and
	s.fk_status_id = 13
	
group by 
	s.id,
	i.id,
	i.title,
	u.id,
	oh.fk_order_orderId,
	od.rowId,
	d.id