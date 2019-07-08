CREATE PROCEDURE [dbo].[SP_searchItemListScale2]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100),
	@type as smallint,
	@parent as varchar(20),
	@userId as bigint,
	@itemGrpId as bigint,
	@itemId as bigint,
	@cityId as bigint,
	@justAvailableGoods as bit,
    @minPrice as money,
    @maxPrice as money,
    @distance as int,
    @orderByPrice as bit = NULL,
    @orderByDistance as bit = NULL,
    @orderByAlphabetic as bit = NULL,
	@orderByStoreState as bit = NULL,
	@justOpenStore as bit,
	@sessionId as bigint,
	@curLat as float = null,
	@curLng as float = null
AS
	
	SET NOCOUNT ON

	-- remove and fixed
	set @cityId = 0

	if(@curLat is not null and @curLng is not null)
		declare @curLoc as geography = geography::Point(@curLat,@curLng,4326)
	;with base
	as
	(
	SELECT distinct
		I.id,I.title,D.thumbcompeleteLink  as ImageUrl,
		I.technicalTitle,
		SIQ.price,
		 case when isnull(SIQ.price,0) = 0 then '-' else (CAST([dbo].[func_addThousandsSeperator] (ISNULL(SIQ.price,0) - (isnull(SIQ.price,0) * isnull(SIQ.discount_percent,0))) AS VARCHAR(50)) + ' تومان') end as price_dsc  ,
		SIQ.price -(SIQ.price * isnull(SIQ.discount_percent,0))  purePrice,
		S.score,s.[address],
		case when @curLat is not null and @curLoc is not null  then cast(@curLoc.STDistance(ISNULL(S.[location],0xE6100000010C7905A22765DA41409529E620E8B04940)) as int) else 0 end distance,

		s1.image_thumbUrl STOREImageUrl,
		ISNULL(STATR.id,STA.id) statusId,ISNULL(STATR.title,STA.title) statusTitle,S.title storeTitle,s.id storeId,fk_itemGrp_id,SIQ.qty,S.fk_status_shiftStatus
		, substring(
					(select top 2
					',' + tt.title as [text()]
					 from 
					 TB_STORE_ITEMGRP_PANEL_CATEGORY ss 
					 inner join TB_TYP_ITEM_GRP tt on ss.pk_fk_itemGrp_id = tt.id
					where
						ss.pk_fk_store_id = s.id
					for xml path (''))
					,2,2147483647 ) as storeExpertise
,
I.barcode, ISNULL(c.id,0) cityId,c.title cityTitle

	FROM
		TB_ITEM I with(nolock)
		INNER join TB_TYP_ITEM_GRP TYG with(nolock) on TYG.id = i.fk_itemGrp_id
		INNER JOIN TB_STORE_ITEM_QTY SIQ with(nolock) ON I.id = SIQ.pk_fk_item_id   
		LEFT JOIN TB_DOCUMENT_ITEM DI with(nolock) ON I.id = DI.pk_fk_item_id and DI.isDefault = 1
		LEFT JOIN TB_DOCUMENT D with(nolock) ON DI.pk_fk_document_id = D.id
		LEFT JOIN TB_STORE S with(nolock) ON SIQ.pk_fk_store_id = S.id
		LEFT JOIN TB_STATUS  STA with(nolock) ON STA.id = S.fk_status_id
		LEFT JOIN TB_STATUS_TRANSLATIONS STATR with(nolock) ON STA.id = STATR.id
		LEFT JOIN TB_CITY c with(nolock) on c.id = s.fk_city_id
		left join dbo.func_getStoreDefaultImage(5) as S1 on S1.storeId = s.id 
	WHERE
	 S.fk_status_id = 13
	 and
			(@itemId is null or @itemId = 0 or I.id = @itemId)
		and
			(@cityId is null or @cityId = 0 or S.fk_city_id = @cityId)
		and
	   		(S.fk_store_type_id = 1 OR S.id IN
			 ((SELECT TSC.pk_fk_store_id FROM TB_STORE_CUSTOMER TSC
			  INNER JOIN TB_STORE S ON TSC.pk_fk_store_id = S.id 
			  where TSC.pk_fk_usr_cstmrId = @userId AND TSC.fk_status_id = 32 AND S.fk_store_type_id = 2)))
		and 
			I.fk_status_id = 15 and SIQ.fk_status_id = 15
		and
			(TYG.type = @type or @type = 0 or @type is null)

	)
	
	select *,case when distance > 0 then dbo.func_getDistanceUnitByLanguage(@clientLanguage,distance) end distanc_dsc from base
	where
			storeTitle LIKE case when @search is not null and @search <> '' then '%'+@search+'%' else storeTitle end
		AND
			(fk_itemGrp_id =  @itemGrpId  or  @itemGrpId = 0 or  @itemGrpId is null or fk_itemGrp_id in(select pk_fk_item_grp_id_link from tb_typ_item_grp_relationship where pk_fk_item_grp_id = @itemGrpId))
		AND
			(qty > case when @justAvailableGoods = 1 then 0 end or @justAvailableGoods is null or @justAvailableGoods = 0)
		AND
			distance < case when  @distance is not null and @distance <> 0 then @distance else 1000000000 end
		AND
			price >= CASE WHEN @minPrice IS NOT NULL  THEN @minPrice ELSE 1 END
		AND
			price <= CASE WHEN @maxPrice IS NOT NULL and @maxPrice <> 0 THEN @maxPrice else 10000000000 END 
		AND
			isnull(fk_status_shiftStatus,0) = CASE WHEN @justOpenStore = 1 THEN 17 else ISNULL(fk_status_shiftStatus,0) END

	ORDER BY
	qty DESC,
	CASE WHEN @orderByDistance = 1 THEN distance END ASC,
	CASE WHEN @orderByPrice = 1 then price END ASC,
	CASE WHEN @orderByStoreState = 1 THEN fk_status_shiftStatus END ASC,title  
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;

	
RETURN 0