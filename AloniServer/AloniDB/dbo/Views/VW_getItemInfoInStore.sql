CREATE view VW_getItemInfoInStore
as
select 
	s.id,
	i.id itemId,
	i.title,
	--u.id userId,
	case when siq.qty = 0 or (siq.qty < 0 and (s.canBeSalesNegative = 0 or siq.canBeSalesNegative = 0)) then 0 else 1 END hasStock,
	case when d.id is not null then 1 else 0 END hasPic,
	case when s.fk_status_shiftStatus = 17 then 1 when s.fk_status_shiftStatus = 18 then 0 when
		 exists(select 1 from TB_STORE_SCHEDULE where fk_store_id = s.id and onDayOfWeek = 
		 case when DATEPART(dw,getdate()) = 7 then 0 else DATEPART(dw,getdate()) end
		 and cast(GETDATE() as time(0)) >= isActiveFrom and cast(GETDATE() as time(0)) < activeUntil )
		 then 1 else 0 end as currentShiftStatus
from

	TB_STORE S 
	inner join TB_STORE_ITEM_QTY siq on s.id = siq.pk_fk_store_id
	inner join TB_ITEM I on siq.pk_fk_item_id = i.id
	--left join tb_order o on o.fk_store_storeId = s.id
	--left join TB_ORDER_HDR oh on o.id = oh.fk_order_orderId
	--left join TB_ORDER_DTL od on od.fk_orderHdr_id = oh.id and i.id = od.fk_item_id
	--left join TB_USR u on u.id = o.fk_usr_customerId
	left join TB_DOCUMENT_ITEM di on i.id = di.pk_fk_item_id and isDefault = 1
	left join TB_DOCUMENT d on d.id = di.pk_fk_document_id 
where
	--o.fk_status_statusId not in(102,103)
	--and
	i.fk_status_id = 15
	and
	siq.fk_status_id = 15
	and
	s.fk_status_id = 13
	and
	(d.isDeleted = 0 or d.isDeleted is null)
group by 
	s.id,
	i.id,
	i.title,
	siq.qty,
	s.canBeSalesNegative,
	siq.canBeSalesNegative,
	d.id,
	s.fk_status_shiftStatus