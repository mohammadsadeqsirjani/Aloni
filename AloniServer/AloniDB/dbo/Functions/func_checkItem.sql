CREATE FUNCTION [dbo].[func_checkItem]
(
	@storeId as bigint,
	@itemIds as dbo.MessageType readonly
)
RETURNS int
AS
BEGIN
		declare @itemsCount int = (select count(msgId) from @itemIds)

	-- exist in items
		
		if((select count(id) from TB_ITEM where id in ((select msgId from @itemIds))) <>  @itemsCount)
			return 0;
	-- get activition item

		if((select count(id) from TB_ITEM where id in ((select msgId from @itemIds)) and fk_status_id <> 15) > 0)
			return 0;
	
	-- get store expertise

		--if(
		--	(
		--		select 
		--			 COUNT(i.id)
		--		from 
		--			 TB_EXPERTISE_ITEMGRP eit with(nolock) inner join TB_TYP_ITEM_GRP tyg with(nolock) on eit.pk_fk_itemGrp_id = tyg.id inner join TB_ITEM i with(nolock) on tyg.id = i.fk_itemGrp_id
		--		where 
		--		     i.id in ((select msgId from @itemIds)) and eit.pk_fk_expertise_id  in(select s.pk_fk_expertise_id from TB_STORE_EXPERTISE s where s.pk_fk_store_id = @storeId)
		--	) <> @itemsCount
		  
		--  )
		--	return 0



	return 1
	
END
