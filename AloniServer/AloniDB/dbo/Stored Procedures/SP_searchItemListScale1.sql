CREATE PROCEDURE [dbo].[SP_searchItemListScale1]
	@clientLanguage		as char(2),
	@appId				as tinyint,
	@clientIp			as varchar(50),
	@pageNo				as int,
	@search				as nvarchar(100),
	@type				as smallint,
	@parent				as varchar(20) = null,
	@userId				as bigint,
	@itemGrpId			as bigint,
	@cityId				as bigint,
	@storeId			as bigint = null,
	@justAvailableGoods as bit,
    @minPrice			as money,
    @maxPrice			as money,
    @distance			as int,
    @orderByPrice		as bit= NULL,
    @orderByDistance	as bit = NULL,
    @orderByAlphabetic  as bit = NULL,
	@sessionId			as bigint,
	@curLat				as float = 0,
	@curLng				as float = 0,
	@centerLocLat		as float = 0,
	@centerLocLng		as float = 0,
	@categoryId			as bigint = 0,
	@onlyDiscount		as bit = 0,
	@withMinMaxValues as bit,
	@searchBarcode as varchar(max) = NULL,
	@rcode as int out
AS
	
	SET NOCOUNT ON
	
	-- remove and fixed
	--set @cityId = 0
	
	DECLARE @temp as table(id bigint,maxPrice money,minPrice money)
	set @rcode = 1
			
	-- جستجوی مستقیم بارکد
	if( @searchBarcode is not null)
	begin
		insert into @temp select * from
		(SELECT 
				
				I.id,
				0 maxPrice,
				0 minPrice
		FROM
			TB_ITEM I  with(nolock)
			INNER JOIN TB_STORE_ITEM_QTY SIQ with(nolock) ON I.id = SIQ.pk_fk_item_id
			INNER JOIN TB_STORE S with(nolock) ON SIQ.pk_fk_store_id = S.id
			INNER JOIN tb_typ_item_grp G with(nolock) ON G.id = i.[fk_itemGrp_id]
			LEFT JOIN TB_STORE_CUSTOMCATEGORY_ITEM STC with(nolock) ON  STC.pk_fk_item_id = I.id 
		WHERE
				S.fk_status_id = 13
			AND
				(@storeId is null OR @storeId = 0 OR S.id = @storeId )
		
			AND
				(
						I.barcode = @searchBarcode
					OR
						I.uniqueBarcode = @searchBarcode
					OR
						(SIQ.localBarcode = @searchBarcode and SIQ.pk_fk_store_id = @storeId and @storeId > 0 )
			   )
			AND
			   (S.fk_store_type_id = 1 OR S.id IN ((SELECT TSC.pk_fk_store_id FROM TB_STORE_CUSTOMER TSC INNER JOIN TB_STORE S ON TSC.pk_fk_store_id = S.id where TSC.pk_fk_usr_cstmrId = @userId AND TSC.fk_status_id = 32 AND S.fk_store_type_id = 2)))
			AND
			   (I.fk_status_id = 15 and SIQ.fk_status_id = 15)
			
			
			Group BY i.id,SIQ.price,i.title,i.saveDateTime,siq.qty
			ORDER BY 
				siq.qty desc,
				CASE WHEN @orderByPrice = 0 then SIQ.price else 0 END ASC,
				CASE WHEN @orderByPrice = 1 then SIQ.price else 0 END DESC,
				CASE WHEN @orderByAlphabetic = 0 THEN i.title else NULL END ASC,
				CASE WHEN @orderByAlphabetic = 1 THEN i.title else NULL END DESC,
				CASE WHEN @orderByPrice = 0 and @orderByPrice = 0 and @orderByAlphabetic = 0 THEN i.saveDateTime END DESC
				OFFSET (@pageNo * 10 ) ROWS
				FETCH NEXT 10 ROWS ONLY ) as tt OPTION (recompile)
			
		SELECT distinct
				siq.[location].Lat as lat,
				siq.[location].Long as lng,
				c.id cityId,
				c.title cityTitle,
				I.id,
				I.title,
				i.modifyDateTime,
				I.technicalTitle,
				BD.maxPrice maxPrice_val,
				BD.minPrice minPrice_val,
				'' minPrice, 
			    '' maxPrice, 
				G.title itemGrpDsc,
				isnull((select MAX(discount_percent) from TB_STORE_ITEM_QTY where pk_fk_item_id = i.id),0) maxDiscount,
				 g.[type],
				case when @storeId > 0 then @storeId else isnull((select max(pk_fk_store_id) from TB_STORE_ITEM_QTY ii with(nolock) inner join TB_STORE ss with(nolock) on ii.pk_fk_store_id = ss.id where pk_fk_item_id = BD.id  and ss.fk_status_id = 13),0) end as maxStoreId,
				case when @storeId is not null and @storeId > 0 then case when SIQ.qty > 0 then 1 else 0 end else NULL END itemExists,
			    I.barcode,
				I.uniqueBarcode,
				case when pm.id is not null then pm.promotionPercent * 100 else 0 END promotionDiscount
		FROM 
			TB_ITEM I with(nolock)
			INNER JOIN @temp BD on BD.id = i.id
			INNER JOIN TB_TYP_ITEM_GRP G with(nolock) on i.fk_itemGrp_id = G.id
			INNER JOIN TB_STORE_ITEM_QTY SIQ with(nolock)  ON I.id = SIQ.pk_fk_item_id
			INNER JOIN TB_STORE s with(nolock) on s.id = SIQ.pk_fk_store_id
			LEFT JOIN TB_CITY c with(nolock) on s.fk_city_id = c.id
			LEFT JOIN TB_STORE_PROMOTION PM with(nolock) ON PM.fk_Store_id = siq.pk_fk_store_id and pm.isActive = 1
	    where SIQ.pk_fk_store_id = @storeId or @storeId is null or @storeId = 0
	end
	else 
	-- جستجوی عادی
	begin

	--**************************************************************************************** بلوک پیمایش گروه ای زیرمجموعه و همچنین بررسی نقاط جغرافیایی
	
	IF @itemGrpId = 0
	BEGIN
		SET @itemGrpId = null
	END
	declare @wordSearch as varchar(500) = case when @search is null or @search = ' ' or @search = '' then '""' else @search END
	declare @curLoc geography = 0xE6100000010C69FD2D01F8D7414098F8A3A833AF4940
	if(@centerLocLat > 0 and @centerLocLng > 0)
	begin
		set @curLoc = geography::Point(@centerLocLat,@centerLocLng,4326);
		set @distance = 10000 -- 10KM
	end
	-- get ItemGrp Tree
	;with name_tree
	as 
	(
	  select id, fk_item_grp_ref,[type]
	  from TB_TYP_ITEM_GRP
	  where id = @itemGrpId or @itemGrpId is null or id in(select pk_fk_item_grp_id_link from tb_typ_item_grp_relationship where pk_fk_item_grp_id = @itemGrpId)
	  union all
	  select C.id, C.fk_item_grp_ref,c.[type]
	  from TB_TYP_ITEM_GRP c
	  join name_tree p on C.fk_item_grp_ref = P.id 
	  AND C.id<>C.fk_item_grp_ref 
	) 
	-- برای پرسنل و شعب گروه کالای مشاغل و سازمان ها نمایش داده می شود
	select * INTO #TEMP_GRP from name_tree where (([type] =case when @type not in(2,6) then @type end) or @type = 0 or @type is null or @type in(2,6)) OPTION (MAXRECURSION 0)

	--**************************************************************************************** پایان بلوک

	--**************************************************************************************** جستجوی آیتم های در یک پنل خاص
		if(@storeId > 0 and @storeId is not null)
		begin
			if((select fk_store_type_id from TB_STORE where id = @storeId) = 2 and not exists (select top 1 1 from TB_STORE_CUSTOMER where pk_fk_store_id = @storeId and pk_fk_usr_cstmrId = @userId and fk_status_id = 32))
			begin
				set @rcode = 0
				return 0
			end
			if(@search is null or @search ='' or @search = ' ')
			begin
				insert into @temp select * from
		(SELECT 
				
				I.id,
				vi.maxPrice,
				vi.minPrice
				
		FROM
			TB_ITEM I  with(nolock)
			INNER JOIN TB_STORE_ITEM_QTY SIQ with(nolock) ON I.id = SIQ.pk_fk_item_id
			INNER JOIN TB_STORE S with(nolock) ON SIQ.pk_fk_store_id = S.id
			INNER JOIN tb_typ_item_grp G with(nolock) ON G.id = i.[fk_itemGrp_id]
			inner join VW_itemMinMaxPrice_PerStore vi on i.id = vi.id 
			LEFT JOIN TB_STORE_CUSTOMCATEGORY_ITEM STC with(nolock) ON  STC.pk_fk_item_id = I.id 
			left join VW_getItemInfoInStore vii with(nolock) on i.id = vii.itemId and vii.id = @storeId
			left join VW_getUserOrderDetailsInStore viii with(nolock) on viii.itemId = vii.itemId
			
		WHERE
				S.fk_status_id = 13
			AND
				i.itemType = 1
			AND
				(@storeId is null OR @storeId = 0 OR S.id = @storeId )
			AND
				vi.storeId = @storeId 
			AND
				(@cityId is null OR @cityId = 0 OR S.fk_city_id = @cityId )
			AND
			   (S.fk_store_type_id = 1 OR S.id IN ((SELECT TSC.pk_fk_store_id FROM TB_STORE_CUSTOMER TSC INNER JOIN TB_STORE S ON TSC.pk_fk_store_id = S.id where TSC.pk_fk_usr_cstmrId = @userId AND TSC.fk_status_id = 32 AND S.fk_store_type_id = 2)))
			AND
			   i.fk_itemGrp_id in(select id from #TEMP_GRP) 
			AND
			   ((SIQ.qty > 0 and @justAvailableGoods = 1 ) or @justAvailableGoods is null or @justAvailableGoods = 0)
			AND
			   (@curLoc.STDistance(isnull(SIQ.[location],ISNULL(s.[location], 0xE6100000010C69FD2D01F8D7414098F8A3A833AF4940))) <  @distance or @distance = 0 or @curLat = 0 or @curLng = 0)
			AND
			   (SIQ.price >= CASE WHEN @minPrice IS NOT NULL and @minPrice <> 0 THEN @minPrice ELSE 0 END)
			AND
			   ((SIQ.price <= CASE WHEN @maxPrice IS NOT NULL THEN @maxPrice END) or @maxPrice = 0 or @maxPrice is null)
			AND
			   (I.fk_status_id = 15 and SIQ.fk_status_id = 15)
			AND
				(SIQ.discount_percent > 0 or @onlyDiscount = 0 or @onlyDiscount is null)
			AND
				(STC.pk_fk_custom_category_id = @categoryId or @categoryId = 0 or @categoryId is null)
			AND
				(i.isLocked is null or i.isLocked = 0)
			
			Group BY i.id,vi.MaxPrice,vi.MinPrice,SIQ.price,i.title,i.saveDateTime,siq.qty,vii.hasStock,viii.hasPicture,vii.hasPic,vii.currentShiftStatus
			ORDER BY 
				--siq.qty desc,
				CASE WHEN @orderByPrice = 0 then SIQ.price else 0 END ASC,
				CASE WHEN @orderByPrice = 1 then SIQ.price else 0 END DESC,
				CASE WHEN @orderByAlphabetic = 0 THEN i.title else NULL  END ASC,
				CASE WHEN @orderByAlphabetic = 1 THEN i.title else NULL  END DESC,
				vii.hasStock DESC,
				viii.hasPicture DESC,
				--vii.hasStock DESC,
				vii.hasPic DESC,
				vii.currentShiftStatus--,
				--vii.hasStock,
				--vii.hasPic
				OFFSET (@pageNo * 10 ) ROWS
				FETCH NEXT 10 ROWS ONLY ) as tt OPTION (recompile)
			end
			else
			begin
						insert into @temp select * from
		(SELECT 
				
				I.id,
				vi.maxPrice,
				vi.minPrice
				
		FROM
			TB_ITEM I  with(nolock)
			INNER JOIN TB_STORE_ITEM_QTY SIQ with(nolock) ON I.id = SIQ.pk_fk_item_id
			INNER JOIN TB_STORE S with(nolock) ON SIQ.pk_fk_store_id = S.id
			INNER JOIN tb_typ_item_grp G with(nolock) ON G.id = i.[fk_itemGrp_id]
			INNER join VW_itemMinMaxPrice_PerStore vi on i.id = vi.id 
			INNER JOIN FREETEXTTABLE(tb_item, title, @wordSearch) AS ft  ON ft.[key] = I.id 
			LEFT JOIN TB_STORE_CUSTOMCATEGORY_ITEM STC with(nolock) ON  STC.pk_fk_item_id = I.id 
			left join VW_getItemInfoInStore vii with(nolock) on i.id = vii.itemId and vii.id = @storeId
			left join VW_getUserOrderDetailsInStore viii with(nolock) on viii.itemId = vii.itemId
			
		WHERE
				S.fk_status_id = 13
			AND
				i.itemType = 1
			AND
				(@storeId is null OR @storeId = 0 OR S.id = @storeId )
			AND
				vi.storeId = @storeId 
			AND
				(@cityId is null OR @cityId = 0 OR S.fk_city_id = @cityId )
			AND
			   (S.fk_store_type_id = 1 OR S.id IN ((SELECT TSC.pk_fk_store_id FROM TB_STORE_CUSTOMER TSC INNER JOIN TB_STORE S ON TSC.pk_fk_store_id = S.id where TSC.pk_fk_usr_cstmrId = @userId AND TSC.fk_status_id = 32 AND S.fk_store_type_id = 2)))
			AND
			   i.fk_itemGrp_id in(select id from #TEMP_GRP) 
			AND
			   ((SIQ.qty > 0 and @justAvailableGoods = 1) or @justAvailableGoods is null or @justAvailableGoods = 0)
			AND
			   (@curLoc.STDistance(isnull(SIQ.[location],ISNULL(s.[location], 0xE6100000010C69FD2D01F8D7414098F8A3A833AF4940))) <  @distance or @distance = 0 or @curLat = 0 or @curLng = 0)
			AND
			   (SIQ.price >= CASE WHEN @minPrice IS NOT NULL and @minPrice <> 0 THEN @minPrice ELSE 0 END)
			AND
			   ((SIQ.price <= CASE WHEN @maxPrice IS NOT NULL THEN @maxPrice END) or @maxPrice = 0 or @maxPrice is null)
			AND
			   (I.fk_status_id = 15 and SIQ.fk_status_id = 15)
			AND
				(SIQ.discount_percent > 0 or @onlyDiscount = 0 or @onlyDiscount is null)
			AND
				(STC.pk_fk_custom_category_id = @categoryId or @categoryId = 0 or @categoryId is null)
			AND
				(i.isLocked is null or i.isLocked = 0)
			
			Group BY i.id,vi.MaxPrice,vi.MinPrice,SIQ.price,i.title,i.saveDateTime,siq.qty,vii.hasStock,viii.hasPicture,vii.hasPic,vii.currentShiftStatus,ft.[Rank]
			ORDER BY 
				ft.[Rank] DESC,
				SIQ.qty DESC,
				CASE WHEN @orderByPrice = 0 then SIQ.price else 0 END ASC,
				CASE WHEN @orderByPrice = 1 then SIQ.price else 0 END DESC,
				CASE WHEN @orderByAlphabetic = 0 THEN i.title else NULL  END ASC,
				CASE WHEN @orderByAlphabetic = 1 THEN i.title else NULL  END DESC,
				vii.hasStock DESC,
				viii.hasPicture DESC,
				--vii.hasStock DESC,
				vii.hasPic DESC,
				vii.currentShiftStatus--,
				--vii.hasStock,
				--vii.hasPic
				OFFSET (@pageNo * 10 ) ROWS
				FETCH NEXT 10 ROWS ONLY ) as tt OPTION (recompile)
			end
			
		end --************************************************************ انتهای جستجو در فروشگاه خاص





		else
		begin
			if(@search is null or @search ='' or @search = ' ')
			begin
				insert into @temp select * from
		(SELECT 
				
				I.id,
				vi.maxPrice,
				vi.minPrice
			
		FROM
			TB_ITEM I  with(nolock)
			INNER JOIN TB_STORE_ITEM_QTY SIQ with(nolock) ON I.id = SIQ.pk_fk_item_id
			INNER JOIN TB_STORE S with(nolock) ON SIQ.pk_fk_store_id = S.id
			INNER JOIN tb_typ_item_grp G with(nolock) ON G.id = i.[fk_itemGrp_id]
			inner join VW_itemMinMaxPrice vi on i.id = vi.id 
			LEFT JOIN TB_STORE_CUSTOMCATEGORY_ITEM STC with(nolock) ON  STC.pk_fk_item_id = I.id 
		WHERE
				S.fk_status_id = 13
			AND
				i.itemType = 1
			AND
				(@storeId is null OR @storeId = 0 OR S.id = @storeId )
			AND
				(@cityId is null OR @cityId = 0 OR S.fk_city_id = @cityId )
			
			AND
			   (S.fk_store_type_id = 1 OR S.id IN ((SELECT TSC.pk_fk_store_id FROM TB_STORE_CUSTOMER TSC INNER JOIN TB_STORE S ON TSC.pk_fk_store_id = S.id where TSC.pk_fk_usr_cstmrId = @userId AND TSC.fk_status_id = 32 AND S.fk_store_type_id = 2)))
			AND
			   i.fk_itemGrp_id in(select id from #TEMP_GRP) 
			AND
			   (SIQ.qty > case when @justAvailableGoods = 1 then 0 end or @justAvailableGoods is null or @justAvailableGoods = 0)
			AND
			   (@curLoc.STDistance(isnull(SIQ.[location],ISNULL(s.[location], 0xE6100000010C69FD2D01F8D7414098F8A3A833AF4940))) <  @distance or @distance = 0 or @curLat = 0 or @curLng = 0)
			AND
			   (SIQ.price >= CASE WHEN @minPrice IS NOT NULL and @minPrice <> 0 THEN @minPrice ELSE 0 END)
			AND
			   ((SIQ.price <= CASE WHEN @maxPrice IS NOT NULL THEN @maxPrice END) or @maxPrice = 0 or @maxPrice is null)
			AND
			   (I.fk_status_id = 15 and SIQ.fk_status_id = 15)
			AND
				(SIQ.discount_percent > 0 or @onlyDiscount = 0 or @onlyDiscount is null)
			AND
				(STC.pk_fk_custom_category_id = @categoryId or @categoryId = 0 or @categoryId is null)
			AND
				(i.isLocked is null or i.isLocked = 0)
			Group BY i.id,vi.MaxPrice,vi.MinPrice,SIQ.price,i.title,i.saveDateTime,siq.qty
			ORDER BY
				CASE WHEN @orderByPrice = 0 then vi.maxPrice else 0 END ASC,
				CASE WHEN @orderByPrice = 1 then vi.maxPrice else 0 END DESC,
				CASE WHEN @orderByAlphabetic = 0 THEN i.title else NULL END ASC,
				CASE WHEN @orderByAlphabetic = 1 THEN i.title else NULL END DESC,
				CASE WHEN @orderByPrice is NULL and @orderByPrice is NULL and @orderByAlphabetic is NULL THEN i.saveDateTime END DESC,
				siq.qty desc
				OFFSET (@pageNo * 10 ) ROWS
				FETCH NEXT 10 ROWS ONLY ) as tt OPTION (recompile)
			end
			else
			begin
				insert into @temp select * from
		(SELECT 
				
				I.id,
				vi.maxPrice,
				vi.minPrice
			
		FROM
			TB_ITEM I  with(nolock)
			INNER JOIN TB_STORE_ITEM_QTY SIQ with(nolock) ON I.id = SIQ.pk_fk_item_id
			INNER JOIN TB_STORE S with(nolock) ON SIQ.pk_fk_store_id = S.id
			INNER JOIN tb_typ_item_grp G with(nolock) ON G.id = i.[fk_itemGrp_id]
			inner join VW_itemMinMaxPrice vi on i.id = vi.id 
			INNER JOIN FREETEXTTABLE(tb_item, title, @wordSearch) AS ft  ON ft.[key] = I.id 
			LEFT JOIN TB_STORE_CUSTOMCATEGORY_ITEM STC with(nolock) ON  STC.pk_fk_item_id = I.id 
		WHERE
				S.fk_status_id = 13
			AND
				i.itemType = 1
			AND
				(@storeId is null OR @storeId = 0 OR S.id = @storeId )
			AND
				(@cityId is null OR @cityId = 0 OR S.fk_city_id = @cityId )
			
			AND
			   (S.fk_store_type_id = 1 OR S.id IN ((SELECT TSC.pk_fk_store_id FROM TB_STORE_CUSTOMER TSC INNER JOIN TB_STORE S ON TSC.pk_fk_store_id = S.id where TSC.pk_fk_usr_cstmrId = @userId AND TSC.fk_status_id = 32 AND S.fk_store_type_id = 2)))
			AND
			   i.fk_itemGrp_id in(select id from #TEMP_GRP) 
			AND
			   (SIQ.qty > case when @justAvailableGoods = 1 then 0 end or @justAvailableGoods is null or @justAvailableGoods = 0)
			AND
			   (@curLoc.STDistance(isnull(SIQ.[location],ISNULL(s.[location], 0xE6100000010C69FD2D01F8D7414098F8A3A833AF4940))) <  @distance or @distance = 0 or @curLat = 0 or @curLng = 0)
			AND
			   (SIQ.price >= CASE WHEN @minPrice IS NOT NULL and @minPrice <> 0 THEN @minPrice ELSE 0 END)
			AND
			   ((SIQ.price <= CASE WHEN @maxPrice IS NOT NULL THEN @maxPrice END) or @maxPrice = 0 or @maxPrice is null)
			AND
			   (I.fk_status_id = 15 and SIQ.fk_status_id = 15)
			AND
				(SIQ.discount_percent > 0 or @onlyDiscount = 0 or @onlyDiscount is null)
			AND
				(STC.pk_fk_custom_category_id = @categoryId or @categoryId = 0 or @categoryId is null)
			AND
				(i.isLocked is null or i.isLocked = 0)
			Group BY i.id,vi.MaxPrice,vi.MinPrice,SIQ.price,i.title,i.saveDateTime,siq.qty,ft.[Rank]
			ORDER BY
				ft.[Rank] DESC,
				CASE WHEN @orderByPrice = 0 then vi.maxPrice else 0 END ASC,
				CASE WHEN @orderByPrice = 1 then vi.maxPrice else 0 END DESC,
				CASE WHEN @orderByAlphabetic = 0 THEN i.title else NULL END ASC,
				CASE WHEN @orderByAlphabetic = 1 THEN i.title else NULL END DESC,
				CASE WHEN @orderByPrice is NULL and @orderByPrice is NULL and @orderByAlphabetic is NULL THEN i.saveDateTime END DESC,
				siq.qty desc
				OFFSET (@pageNo * 10 ) ROWS
				FETCH NEXT 10 ROWS ONLY ) as tt OPTION (recompile)
			end
		end
		
		select * from (		
		SELECT distinct
				siq.[location].Lat as lat,
				siq.[location].Long as lng,
				--c.id cityId,
				--c.title cityTitle,
				I.id,
				I.title,
				i.saveDateTime modifyDateTime,
				I.technicalTitle,
				BD.maxPrice maxPrice_val,
				BD.minPrice minPrice_val,
				case when BD.minPrice - BD.minPrice * isnull(SIQ.discount_percent,0) = 0 then '' 
					 when BD.minPrice - BD.minPrice * isnull(SIQ.discount_percent,0) > 0 and BD.maxPrice - BD.maxPrice * isnull(SIQ.discount_percent,0) > 0 and (BD.minPrice - BD.minPrice * isnull(SIQ.discount_percent,0)) = (BD.maxPrice - BD.maxPrice * isnull(SIQ.discount_percent,0)) then ''
					 else case when @storeId > 0 then '' else 'از ' end + [dbo].[func_addThousandsSeperator] (BD.minPrice - BD.minPrice * isnull(SIQ.discount_percent,0)) + ' ' + 'تومان' end  as minPrice, 
			    case when BD.maxPrice - BD.maxPrice * isnull(SIQ.discount_percent,0) = 0 then '' 
					 when BD.minPrice - BD.minPrice * isnull(SIQ.discount_percent,0) > 0 and BD.maxPrice - BD.maxPrice * isnull(SIQ.discount_percent,0) > 0 and (BD.minPrice - BD.minPrice * isnull(SIQ.discount_percent,0)) = (BD.maxPrice - BD.maxPrice * isnull(SIQ.discount_percent,0)) then [dbo].[func_addThousandsSeperator] (BD.maxPrice - BD.maxPrice * isnull(SIQ.discount_percent,0)) + ' ' + 'تومان'
				else case when BD.minPrice > 0 then 'تا ' else '' END + [dbo].[func_addThousandsSeperator] (BD.maxPrice - BD.maxPrice * isnull(SIQ.discount_percent,0)) + ' ' + 'تومان' end	  as maxPrice, 
				G.title itemGrpDsc,
				isnull((select MAX(discount_percent) from TB_STORE_ITEM_QTY where pk_fk_item_id = i.id),0) maxDiscount,
				 g.[type],
				case when @storeId > 0 then @storeId else isnull((select max(pk_fk_store_id) from TB_STORE_ITEM_QTY ii with(nolock) inner join TB_STORE ss with(nolock) on ii.pk_fk_store_id = ss.id where pk_fk_item_id = BD.id and ss.fk_city_id = @cityId and ss.fk_status_id = 13),0) end as maxStoreId,
				case when @storeId > 0  
					 then 
					  ---
						case when SIQ.qty <> 0 and (SIQ.canBeSalesNegative = 1 or s.canBeSalesNegative = 1)  then 1 
						     when SIQ.qty <= 0 and (SIQ.canBeSalesNegative = 0 or SIQ.canBeSalesNegative is null) and (s.canBeSalesNegative = 0 or s.canBeSalesNegative is null) then 0 
							 when SIQ.qty = 0 then 0 
							 else 1
					    end 
					 --
					else NULL END itemExists,
			    I.barcode,
				'' uniqueBarcode,
				case when @storeId > 0 then case when pm.id is not null then pm.promotionPercent * 100 else 0 END else 0 END promotionDiscount,
				isnull(vii.hasStock,0) hasStock,
				ISNULL(viii.hasPicture,0) hasPicture,
				isnull(vii.hasPic,0) hasPic
		FROM 
			TB_ITEM I with(nolock)
			INNER JOIN @temp BD on BD.id = i.id
			INNER JOIN TB_TYP_ITEM_GRP G with(nolock) on i.fk_itemGrp_id = G.id
			INNER JOIN TB_STORE_ITEM_QTY SIQ with(nolock)  ON I.id = SIQ.pk_fk_item_id
			inner join TB_STORE s with(nolock) on s.id = SIQ.pk_fk_store_id
			--LEFT JOIN TB_CITY c with(nolock) on s.fk_city_id = c.id
			LEFT JOIN TB_STORE_PROMOTION PM with(nolock) ON PM.fk_Store_id = siq.pk_fk_store_id and pm.isActive = 1
			left join VW_getItemInfoInStore vii with(nolock) on i.id = vii.itemId and vii.id = @storeId
			left join VW_getUserOrderDetailsInStore viii with(nolock) on viii.itemId = vii.itemId
			 where 
				(SIQ.pk_fk_store_id = @storeId or @storeId is null or @storeId = 0 ) and s.fk_status_id = 13 and (SIQ.price = bd.maxPrice or @storeId > 0)) as t
			 
			 ORDER BY
				--case when @storeId is null or @storeId = 0 then itemExists else 0 END DESC,
				CASE WHEN @orderByPrice = 0 then maxPrice_val ELSE 0  END ASC,
				CASE WHEN @orderByPrice = 1 then maxPrice_val ELSE 0 END DESC,
				CASE WHEN @orderByAlphabetic = 0 THEN title ELSE NULL END ASC,
				CASE WHEN @orderByAlphabetic = 1 THEN title ELSE NULL END DESC,
				hasStock DESC,
				hasPicture DESC,
				hasPic DESC--,
				--CASE WHEN @orderByPrice is NULL and @orderByPrice is NULL and @orderByAlphabetic is NULL THEN modifyDateTime END DESC--,
				--,
				--vii.hasPic DESC

	end
	
	select
	 COUNT(pk_fk_store_id) storeCount,
	 pk_fk_item_id 
	from
	 TB_STORE S with(nolock) inner join 
	 TB_STORE_ITEM_QTY SIQ with(nolock) on s.id = SIQ.pk_fk_store_id
	
	where 
		S.fk_status_id = 13 
		and
		SIQ.fk_status_id = 15 
		AND
		(S.fk_city_id = @cityId or @cityId = 0 or @cityId is null)
		AND
		 SIQ.pk_fk_item_id in(select id from @temp)
	group by pk_fk_item_id
	
	
	select
		i.id,
		case when SIO.id is not null then 1 else 0 end hasOpinion,
			SIO.resultIsPublic,
			case when (select (sum(avgOpinions)/COUNT(id)) from TB_STORE_ITEM_OPINIONPOLL_OPTIONS where fk_opinionpoll_id = SIO.id group by fk_opinionpoll_id) is null then 0 else (select (sum(avgOpinions)/COUNT(id)) from TB_STORE_ITEM_OPINIONPOLL_OPTIONS where fk_opinionpoll_id = SIO.id group by fk_opinionpoll_id) end avgOpinions,
			case when SIOPT.cntOpinions is null then 0 else SIOPT.cntOpinions end cntOpinions
	FROM
			@temp I  
					
			LEFT join TB_STORE_ITEM_OPINIONPOLL SIO WITH (NOLOCK) ON I.id = SIO.fk_item_id and SIO.isActive = 1 
		    LEFT join TB_STORE_ITEM_OPINIONPOLL_OPINIONS SIOO WITH (NOLOCK) ON SIOO.fk_opinionPollId = SIO.id
			LEFT join TB_STORE_ITEM_OPINIONPOLL_OPTIONS SIOPT WITH (NOLOCK) ON SIOPT.fk_opinionpoll_id = SIO.id
	group by
		i.id,
		SIO.id,
		SIOPT.cntOpinions,
		SIO.resultIsPublic
	select * into #stores from (select distinct Q.pk_fk_store_id from TB_STORE_ITEM_QTY Q inner join @temp B on b.id = Q.pk_fk_item_id ) as y
	select
		s.title + ' - ' + ST.title + ' - ' + c.title branchMap_dsc
	from
	    
		 TB_STORE S
		 inner join #stores ss on ss.pk_fk_store_id = s.id
		 inner join TB_STORE_ITEM_QTY sqi with(nolock) on sqi.pk_fk_store_id = s.id
		 inner  join @temp t on t.id = sqi.pk_fk_item_id
		
		inner join TB_ITEM I on t.id = i.id
		inner join TB_TYP_ITEM_GRP g on i.fk_itemGrp_id = g.id and g.[type] = 6
		left join TB_CITY C on i.fk_city_id = c.id
		left join TB_STATE ST on ST.id = c.fk_state_id
	select
		t.id,
		d.completeLink  as ImageUrl,
		d.thumbcompeleteLink
	from
		@temp T
		inner JOIN TB_DOCUMENT_ITEM DI with(nolock) ON  DI.pk_fk_item_id = T.id and DI.isDefault = 1
		inner JOIN TB_DOCUMENT D with(nolock) ON DI.pk_fk_document_id = D.id and D.fk_documentType_id = 2	
	if(@withMinMaxValues = 1)
	begin
		select 
		min(price) - (min(price) * siq.discount_percent) minPrice_val,
		max(price) - (max(price) * siq.discount_percent) maxPrice_val
		from 
	 TB_ITEM i with(nolock)
	 inner join
	 TB_STORE_ITEM_QTY siq with(nolock) on i.id = siq.pk_fk_item_id
	 inner join 
	 TB_STORE S  on siq.pk_fk_store_id = s.id
	where
			((I.title LIKE case when @search is not null and @search <> '' then '%'+@search+'%' else i.title end) 
					OR 
						@search is null 
					OR 
						@search = ''
					OR
						I.barcode = @search
					OR
						i.uniqueBarcode = @search)
			AND
			s.fk_status_id = 13
			AND
			i.fk_status_id = 15
			AND
			i.fk_itemGrp_id in(select id from #TEMP_GRP) 
			AND
			(S.fk_city_id = @cityId or @cityId = 0 or @cityId is null)
			AND
			(s.id = @storeId or @storeId is null or @storeId = 0)
		Group by siq.discount_percent
	END
RETURN 0