

CREATE view [dbo].[VW_itemMinMaxPrice_PerStore]
as
select 
	i.id,
	s.id storeId,
	max(siq.price) maxPrice,
	min(siq.price) minPrice
from
	TB_STORE_ITEM_QTY siq with(nolock)
	inner join TB_ITEM i with(nolock) on i.id = siq.pk_fk_item_id
	inner join TB_STORE s with(nolock) on s.id = siq.pk_fk_store_id
where i.itemType = 1 and i.fk_status_id = 15 and siq.fk_status_id = 15 and s.fk_status_id = 13
group by i.id,s.id