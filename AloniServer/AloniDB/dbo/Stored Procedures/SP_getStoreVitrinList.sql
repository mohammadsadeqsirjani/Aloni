CREATE PROCEDURE [dbo].[SP_getStoreVitrinList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = 0,
	@search as nvarchar(100)= null,
	@parent as varchar(20) = null,
	@storeId as bigint,
	@userId as bigint,
	@rcode as int out ,
	@type as smallint,
	@isHighlight as bit
AS
	set nocount on;
	set @pageNo = ISNULL(@pageNo,0)
	set @rcode = 1
	if((select fk_store_type_id from TB_STORE where id = @storeId) = 2 and not exists (select top 1 1 from TB_STORE_CUSTOMER where pk_fk_store_id = @storeId and pk_fk_usr_cstmrId = @userId and fk_status_id = 32) and @appId = 2)
			begin
				set @rcode = 0
				return 0
			end
	;with result
	as
	(
		select 
			sv.id,sv.fk_item_id,sv.fk_itemGrp_id,i.title itemTitle,isnull(tryg.title,tyg.title) itemGrpTitle,sv.title,sv.description,
		case when @type <> 1 then '' else (select dbo.func_addThousandsSeperator(min_) +' '+dbo.func_getCurrencyTitleByLanguage(@clientLanguage,@storeId) from func_getMinMaxPriceInItemGroup(tyg.id,@storeId)) END fromPrice,
		case when @type <> 1 then '' else (select dbo.func_addThousandsSeperator(max_) +' '+dbo.func_getCurrencyTitleByLanguage(@clientLanguage,@storeId) from func_getMinMaxPriceInItemGroup(tyg.id,@storeId)) END toPrice,
		case when @type <> 1 then '' else dbo.func_addThousandsSeperator(SIQ.price) +' '+dbo.func_getCurrencyTitleByLanguage(@clientLanguage,@storeId) END price_dsc,
		case when @type <> 1 then '' else dbo.func_addThousandsSeperator(siq.price -(SIQ.price * SIQ.discount_percent)) +' '+dbo.func_getCurrencyTitleByLanguage(@clientLanguage,@storeId) END priceAfterDiscount_dsc,
			SIQ.qty,
			case when SIQ.discount_percent > 0 then SIQ.discount_percent else null end discount_percent,
			 SIQ.isNotForSelling ,
			tyg1.[type],
			(select b.sum_qty from dbo.func_getOrderDtls(null,null) as b
				join TB_ORDER o on b.orderId = o.id and o.fk_usr_customerId = @userId and [dbo].[func_getOrderStatus](o.id,o.fk_status_statusId,o.lastDeliveryDateTime) = 100 and o.fk_store_storeId = @storeId and b.itemId = i.id) itemInCart,
				sv.[type] as vitrinType,
				sv.isHighlight
		from 
			TB_STORE_VITRIN SV
			left join TB_ITEM I on sv.fk_item_id = I.id
			left join TB_STORE_ITEM_QTY SIQ on SIQ.pk_fk_item_id = i.id and SV.fk_store_id = SIQ.pk_fk_store_id
			left join TB_TYP_ITEM_GRP tyg1 on I.fk_itemGrp_id = tyg1.id
			left join TB_TYP_ITEM_GRP tyg on sv.fk_itemGrp_id = tyg.id
			left join TB_TYP_ITEM_GRP_TRANSLATIONS tryg on tryg.id = tyg.id and tryg.lan = @clientLanguage 
		where 
			sv.fk_store_id = @storeId
			and
			isDeleted <> 1
			and
			(@type is null or (sv.type = @type ))
			and
			(@isHighlight is null or (sv.isHighlight = @isHighlight))
			
	)
	select * into #temp from result

	select * from #temp
	order by id
	OFFSET (@pageNo *10) ROWS
	FETCH NEXT 10 ROW ONLY
	select 
	      b.id  as pk_fk_vitrin_id
		,case when  (@appId = 1 or d.id is not null) then d.completeLink when did.id is not null then did.completeLink else dig.completeLink end as completeLink
		,case when (@appId = 1 or d.id is not null)  then dv.isPrime when did.id is not null then di.isDefault else 1 end as isPrime
		,case when (@appId = 1 or d.id is not null)  then d.thumbcompeleteLink when did.id is not null then did.thumbcompeleteLink else dig.thumbcompeleteLink end as thumbcompeleteLink--d.thumbcompeleteLink
		,case when (@appId = 1 or d.id is not null)  then d.id when did.id is not null then did.id else dig.id end as id
	from
	#temp as b
	   left join 
		TB_DOCUMENT_STORE_VITRIN as dv on b.id = dv.pk_fk_vitrin_id 
		 left join TB_DOCUMENT as d on  dv.pk_fk_document_id = d.id

		 left join TB_DOCUMENT_ITEM as di on b.fk_item_id = di.pk_fk_item_id and di.isDefault = 1
		 left join TB_DOCUMENT as did on  di.pk_fk_document_id = did.id


		 left join TB_TYP_ITEM_GRP as ig on b.fk_itemGrp_id = ig.id
		 left join TB_DOCUMENT as dig on  ig.fk_document_id = dig.id


	

RETURN 0
