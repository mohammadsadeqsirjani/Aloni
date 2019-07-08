﻿CREATE PROCEDURE [dbo].[SP_getStoreDiscountList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100)=null,
	@parent as varchar(20) = null ,
	@userId as bigint,
	@storeId as bigint,
	@msg as nvarchar(100) out,
	@rCode as smallint out
AS
	set @pageNo = ISNULL(@pageNo,0)
	set nocount on
	set @rCode = 1;
	if(@appId = 2)
	begin
		if((select fk_store_type_id from TB_STORE where id = @storeId) = 2) -- private store
		begin
			if(exists( select 1 from TB_STORE_CUSTOMER where pk_fk_store_id = @storeId and pk_fk_usr_cstmrId = @userId))
			begin
				set @rCode = 0
				set @msg = dbo.func_getSysMsg('notAccess',OBJECT_NAME(@@PROCID),@clientLanguage, 'store is private!')
				return 0
			end
		end
	end
	select 
		i.id,
		isnull( i.title,'') + ' - '  + ISNULL( i.technicalTitle,'') as title,
		d.completeLink as itemImage,
		d.thumbcompeleteLink,
		siq.price,
		[dbo].[func_getPriceAsDisplayValue](siq.price,@clientLanguage,@storeId) as price_dsc,
		siq.discount_percent * 100 as discount,
		'%' + REPLACE(cast((isnull(siq.discount_percent,0) * 100) as varchar(50)),'.00','') as discount_dsc,
		cast((siq.price - (siq.price * siq.discount_percent)) as int) as priceAfterDiscount,
		[dbo].[func_getPriceAsDisplayValue](cast(siq.price - (siq.price * siq.discount_percent) as int),@clientLanguage,@storeId) as priceAfterDiscount_dsc
		--CAST(siq.price as varchar(20)) + dbo.func_getCurrencyTitleByLanguage(@clientLanguage,@storeId,1) as price,
		-- CAST(siq.price -(SIQ.price * SIQ.discount_percent / 100) as varchar(20)) + dbo.func_getCurrencyTitleByLanguage(@clientLanguage,@storeId,1) as priceAfterDiscount,
		-- cast(siq.discount_percent as int) as discount
	from
	 TB_STORE_ITEM_QTY as siq
	  inner join TB_ITEM I on siq.pk_fk_item_id = i.id
	   left join TB_DOCUMENT_ITEM DI on i.id = DI.pk_fk_item_id and di.isDefault = 1
	    left join TB_DOCUMENT D on d.id = di.pk_fk_document_id  and fk_documentType_id = 2

	where discount_percent > 0 and qty > 0 and pk_fk_store_id = @storeId and I.fk_status_id = 15
	order by siq.pk_fk_item_id
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;
RETURN 0