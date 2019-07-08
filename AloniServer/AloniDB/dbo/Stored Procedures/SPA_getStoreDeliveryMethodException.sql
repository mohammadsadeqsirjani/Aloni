CREATE PROCEDURE [dbo].[SPA_getStoreDeliveryMethodException]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100) = NULL,
	@parent as varchar(20) = null,
	@storeId as bigint,
	@userId as bigint
AS
	set nocount on
	select
		si.id,
		si.fk_item_id,
		si.fk_itemgrp_id,
		si.fk_deliveryMethod_id,
		isnull(sdr.title,d.title) as title
	from
		 TB_STORE_DELIVERYMETHODTYPE_EXCEPTION as si
		 inner join TB_TYP_DELIVERY_METHOD as d on si.fk_deliveryMethod_id = d.id
		 left join TB_TYP_DELIVERY_METHOD_TRANSLATION as sdr on sdr.id = d.id and lan = @clientLanguage
	where
		si.fk_store_id = @storeId
		AND (sdr.title like '%' + @search + '%' or @search is null or @search = '')
		
	ORDER BY si.id
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;
RETURN 0
