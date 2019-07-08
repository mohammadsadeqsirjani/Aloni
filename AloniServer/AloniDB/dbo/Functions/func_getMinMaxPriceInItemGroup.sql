CREATE FUNCTION [func_getMinMaxPriceInItemGroup]
(
	@grpId as bigint,
	@storeId as bigint
)
RETURNS TABLE 
AS
RETURN 
(
	select 
		max(siq.price) as max_,
		min(SIQ.price) as min_
	from 
	TB_STORE_ITEM_QTY SIQ 
	inner join TB_ITEM I on siq.pk_fk_item_id = i.id and siq.pk_fk_store_id = @storeId
	where
		i.fk_status_id = 15
		and
		i.fk_itemGrp_id = @grpId
)
GO
