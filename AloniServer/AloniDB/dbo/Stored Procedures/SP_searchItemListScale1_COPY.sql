CREATE PROCEDURE [dbo].[SP_searchItemListScale1_COPY]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100),
	@type as smallint,
	@parent as varchar(20) = null,
	@userId as bigint,
	@itemGrpId as bigint,
	@cityId as bigint,
	@storeId as bigint = null,
	@justAvailableGoods as bit,
    @minPrice as money,
    @maxPrice as money,
    @distance as int,
    @orderByPrice as bit=NULL,
    @orderByDistance as bit=NULL,
    @orderByAlphabetic as bit=NULL,
	@sessionId as bigint,
	@curLat as float = 0,
	@curLng as float = 0,
	@centerLocLat as float = 0,
	@centerLocLng as float = 0,
	@categoryId as bigint = 0,
	@onlyDiscount as bit = 0,
	@searchBarcode as varchar(max) = NULL,
	@rcode as int out 
AS
	
	SET NOCOUNT ON

	-- remove and fixed
	--set @cityId = 0
	declare @wordSearch as varchar(500) = case when @search is null or @search = ' ' or @search = '' then '""' else @search END
	DECLARE @temp as table(id bigint,title varchar(max),technicalTitle varchar(max),lat float,lng float,maxPrice_val money,minPrice_val money,minPrice varchar(max),maxPrice varchar(max),itemGrpDsc varchar(max),maxDiscount money,[type] smallint,maxStoreId bigint,pk_fk_store_id bigint,[date] varchar(10),barcode varchar(100),uniqueBarcode varchar(100),cityId int,cityTitle varchar(150),[rank] int)
	declare @curLoc geography = 0xE6100000010C69FD2D01F8D7414098F8A3A833AF4940
	set @rcode = 1
	IF @itemGrpId = 0
	BEGIN
		SET @itemGrpId = null
	END
	
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
	  where id = @itemGrpId or id in(select pk_fk_item_grp_id_link from tb_typ_item_grp_relationship where pk_fk_item_grp_id = @itemGrpId) or @itemGrpId is null
	  union all
	  select C.id, C.fk_item_grp_ref,c.[type]
	  from TB_TYP_ITEM_GRP c
	  join name_tree p on C.fk_item_grp_ref = P.id 
	  AND C.id<>C.fk_item_grp_ref 
	) 
	select * INTO #TEMP_GRP from name_tree where (([type] =case when @type not in(2,6) then @type end) or @type = 0 or @type is null or @type in(2,6)) OPTION (MAXRECURSION 0)

	if(@searchBarcode is not null)
	begin
	;with items
	as
	(
	
		SELECT
				siq.[location].Lat as lat,
				siq.[location].Long as lng,
				isNULL(c.id,0) cityId,
				c.title cityTitle, 
				siq.pk_fk_store_id,
				I.id,
				I.title,
				i.modifyDateTime,
				I.technicalTitle,
				0 maxPrice_val,
				0 minPrice_val,
				'' as minPrice, 
				'' as maxPrice,
				G.title itemGrpDsc,
				0 maxDiscount,
				i.itemType as [type],
				0 maxStoreId,
				I.barcode,
				i.uniqueBarcode
		FROM
			TB_ITEM I  
			INNER JOIN TB_STORE_ITEM_QTY SIQ  ON I.id = SIQ.pk_fk_item_id
			INNER JOIN TB_STORE S  ON SIQ.pk_fk_store_id = S.id
			INNER JOIN TB_TYP_ITEM_GRP G ON I.fk_itemGrp_id = G.id
			LEFT JOIN TB_CITY c on S.fk_city_id = c.id
			LEFT JOIN TB_STORE_CUSTOMCATEGORY_ITEM STC ON  STC.pk_fk_item_id = I.id 
		WHERE
				S.fk_status_id = 13
			AND
				(@storeId is null OR @storeId = 0 OR S.id = @storeId )
			AND
			   (I.fk_status_id = 15 and SIQ.fk_status_id = 15)
			AND
			   (i.barcode = @searchBarcode or i.uniqueBarcode = @searchBarcode or (SIQ.localBarcode = @searchBarcode and @storeId is not null and @storeId > 0))
			
		
	)
		    insert into @temp(id,title,technicalTitle,lat,lng,maxPrice_val,maxPrice,minPrice,minPrice_val,maxDiscount,type,itemGrpDsc,maxStoreId,pk_fk_store_id,[date],[barcode],[uniqueBarcode],cityId,cityTitle,[rank]) select id,title,technicalTitle,lat,lng,maxPrice_val,maxPrice,minPrice,minPrice_val,maxDiscount,type,itemGrpDsc,maxStoreId,pk_fk_store_id,modifyDateTime,barcode,uniqueBarcode,cityId,cityTitle,0 from items option (recompile)
		
	end
	else if(@type not in(2,6) OR (@storeId is not null and @storeId > 0) )
	begin
		    if((select fk_store_type_id from TB_STORE where id = @storeId) = 2 and not exists (select top 1 1 from TB_STORE_CUSTOMER where pk_fk_store_id = @storeId and pk_fk_usr_cstmrId = @userId and fk_status_id = 32))
			begin
				set @rcode = 0
				return 0
			end
		;with items
	as
	(
	
		SELECT distinct
				siq.[location].Lat as lat,
				siq.[location].Long as lng,
				isNULL(c.id,0) cityId,
				c.title cityTitle, 
				siq.pk_fk_store_id,
				I.id,
				I.title,
				i.modifyDateTime,
				I.technicalTitle,
				0 maxPrice_val,
				0 minPrice_val,
				'' as minPrice, 
				'' as maxPrice,
				G.title itemGrpDsc,
				0 maxDiscount,
				i.itemType as [type],
				0 maxStoreId,
				I.barcode,
				I.uniqueBarcode,
				KEY_TBL.[RANK]
		FROM
			TB_ITEM I  with (nolock)
			INNER JOIN TB_STORE_ITEM_QTY SIQ with (nolock)  ON I.id = SIQ.pk_fk_item_id
			INNER JOIN TB_STORE S with (nolock) ON SIQ.pk_fk_store_id = S.id
			INNER JOIN TB_TYP_ITEM_GRP G with (nolock) ON I.fk_itemGrp_id = G.id
			LEFT JOIN FREETEXTTABLE (tb_item, (title,barcode,uniqueBarcode), @wordSearch) AS KEY_TBL ON i.id = KEY_TBL.[key]
			LEFT JOIN TB_CITY c with (nolock) on c.id = s.fk_city_id
			LEFT JOIN TB_STORE_CUSTOMCATEGORY_ITEM STC with (nolock) ON  STC.pk_fk_item_id = I.id 
			
			
		WHERE
				S.fk_status_id = 13
			AND
				(i.itemType = @type or @type = 0 or @type is null)
			AND
				(@storeId is null OR @storeId = 0 OR S.id = @storeId )
			AND
				(@cityId is null OR @cityId = 0 OR S.fk_city_id = @cityId )
			AND
				 (@type <> 2 or (@type = 2 and findJustBarcode <> 1 or findJustBarcode is null))
			AND
			   (S.fk_store_type_id = 1 OR S.id IN ((SELECT TSC.pk_fk_store_id FROM TB_STORE_CUSTOMER TSC INNER JOIN TB_STORE S ON TSC.pk_fk_store_id = S.id where TSC.pk_fk_usr_cstmrId = @userId AND TSC.fk_status_id = 32 AND S.fk_store_type_id = 2)))
			AND
			   (@itemGrpId is null OR @itemGrpId = 0 OR @itemGrpId = i.fk_itemGrp_id OR  EXISTS(select fk_item_grp_ref from #TEMP_GRP PP where PP.id = i.fk_itemGrp_id or PP.fk_item_grp_ref = i.fk_itemGrp_id) )
			AND
			   (@curLoc.STDistance(isnull(SIQ.[location],ISNULL(s.[location], 0xE6100000010C69FD2D01F8D7414098F8A3A833AF4940))) <  @distance or @distance = 0 or @curLat = 0 or @curLng = 0)
			AND
			   (I.fk_status_id = 15 and SIQ.fk_status_id = 15)
			AND
				(STC.pk_fk_custom_category_id = @categoryId or @categoryId = 0 or @categoryId is null)
		
	)
	insert into @temp(id,title,technicalTitle,lat,lng,maxPrice_val,maxPrice,minPrice,minPrice_val,maxDiscount,type,itemGrpDsc,maxStoreId,pk_fk_store_id,[date],[barcode],[uniqueBarcode],cityId,cityTitle,rank) select id,title,technicalTitle,lat,lng,maxPrice_val,maxPrice,minPrice,minPrice_val,maxDiscount,type,itemGrpDsc,maxStoreId,pk_fk_store_id,modifyDateTime,barcode,uniqueBarcode,cityId,cityTitle,[rank] from items option(recompile)

	end
	else
	begin
		;with items
	as
	(
	
		SELECT
				siq.[location].Lat as lat,
				siq.[location].Long as lng,
				isNULL(c.id,0) cityId,
				c.title cityTitle, 
				siq.pk_fk_store_id,
				I.id,
				I.title,
				I.technicalTitle,
				0 maxPrice_val,
				0 minPrice_val,
				'' as minPrice, 
				'' as maxPrice,
				G.title itemGrpDsc,
				0 maxDiscount,
				i.itemType as [type],
				0 maxStoreId,
				I.barcode,
				I.uniqueBarcode,
				KEY_TBL.[RANK]
		FROM
			TB_ITEM I  with(nolock)
			INNER JOIN TB_STORE_ITEM_QTY SIQ with(nolock) ON I.id = SIQ.pk_fk_item_id
			INNER JOIN TB_STORE S with(nolock) ON SIQ.pk_fk_store_id = S.id
			INNER JOIN TB_TYP_ITEM_GRP G with(nolock) ON I.fk_itemGrp_id = G.id
			LEFT JOIN FREETEXTTABLE (tb_item, (title,barcode,uniqueBarcode), @wordSearch) AS KEY_TBL ON i.id = KEY_TBL.[key]
			LEFT JOIN TB_CITY c with(nolock) on c.id = s.fk_city_id
			LEFT JOIN TB_STORE_ITEMGRP_PANEL_CATEGORY pc with(nolock) ON S.id = PC.pk_fk_store_id
			
		WHERE
				S.fk_status_id = 13
			AND
				(i.itemType = @type or @type = 0 or @type is null)
			AND
				(@storeId is null OR @storeId = 0 OR S.id = @storeId )
			AND
				(@cityId is null OR @cityId = 0 OR S.fk_city_id = @cityId )
			AND
			    (@type <> 2 or (@type = 2 and findJustBarcode <> 1 or findJustBarcode is null or i.barcode = @search or i.uniqueBarcode = @search)) 
			AND
			   (S.fk_store_type_id = 1 OR S.id IN ((SELECT TSC.pk_fk_store_id FROM TB_STORE_CUSTOMER TSC INNER JOIN TB_STORE S ON TSC.pk_fk_store_id = S.id where TSC.pk_fk_usr_cstmrId = @userId AND TSC.fk_status_id = 32 AND S.fk_store_type_id = 2)))
			AND
			   (@itemGrpId is null OR @itemGrpId = 0 OR @itemGrpId = pc.pk_fk_itemGrp_id OR EXISTS(select fk_item_grp_ref from #TEMP_GRP PP where PP.id = pc.pk_fk_itemGrp_id or PP.fk_item_grp_ref = pc.pk_fk_itemGrp_id) )
			AND
			   (@curLoc.STDistance(isnull(SIQ.[location],ISNULL(s.[location], 0xE6100000010C69FD2D01F8D7414098F8A3A833AF4940))) <  @distance or @distance = 0 or @curLat = 0 or @curLng = 0)
			AND
			   (I.fk_status_id = 15 and SIQ.fk_status_id = 15)
		
	)
	insert into @temp(id,title,technicalTitle,lat,lng,maxPrice_val,maxPrice,minPrice,minPrice_val,maxDiscount,type,itemGrpDsc,maxStoreId,pk_fk_store_id,barcode,uniqueBarcode,cityId,cityTitle,[rank]) select id,title,technicalTitle,lat,lng,maxPrice_val,maxPrice,minPrice,minPrice_val,maxDiscount,type,itemGrpDsc,maxStoreId,pk_fk_store_id,barcode,uniqueBarcode,cityId,cityTitle,[rank] from items option (recompile)
		
	end




----------------------------------------------------------------- Select Final -----------------------------------------------------------------------------------------------------------------------------------------
	select * into #distinctRecord from (select distinct * from @temp) T
	select * into #temp	from (select  *,ROW_NUMBER() OVER (ORDER BY [rank] DESC) AS RowNum from #distinctRecord) t
		
	
	SELECT 
			t.id ,
			t.title ,
			t.technicalTitle ,
			t.minPrice , 
			t.maxPrice,
			t.itemGrpDsc,
			t.maxDiscount--,
			,t.lat
			,t.lng
			,t.maxStoreId
			,t.barcode
			,t.uniqueBarcode
			,t.[type]
			,cityId
			,cityTitle
		
		FROM #temp t 
		
		ORDER BY 
	     t.RowNum 
		 OFFSET (@pageNo * 10 ) ROWS
		 FETCH NEXT 10 ROWS ONLY
	select 
		COUNT(siq.pk_fk_store_id)storeCount,
		pk_fk_item_id 
	from 
		TB_STORE_ITEM_QTY SIQ
		inner join #temp t on t.id = SIQ.pk_fk_item_id
		inner join TB_STORE S on SIQ.pk_fk_store_id = s.id and SIQ.fk_status_id = 15
	where 
	  S.fk_status_id = 13 --and pk_fk_item_id in(select distinct id from #temp)
	 AND (S.fk_store_type_id = 1 OR S.id IN ((SELECT TSC.pk_fk_store_id FROM TB_STORE_CUSTOMER TSC 
	 INNER JOIN TB_STORE S ON TSC.pk_fk_store_id = S.id where TSC.pk_fk_usr_cstmrId = @userId AND TSC.fk_status_id = 32 
	 AND S.fk_store_type_id = 2)))
	

	group by pk_fk_item_id

	
	select distinct
		SIO.fk_item_id id,
		case when SIO.id is not null then 1 else 0 end hasOpinion,
			SIO.resultIsPublic,
			(select sum(isnull(avgOpinions,0))/COUNT(id) from TB_STORE_ITEM_OPINIONPOLL_OPTIONS where fk_opinionpoll_id = (select max(id) from TB_STORE_ITEM_OPINIONPOLL where fk_item_id =i.id and isActive = 1 ) and isActive = 1) avgOpinions,
			(select top 1 cntOpinions from TB_STORE_ITEM_OPINIONPOLL_OPTIONS where fk_opinionpoll_id = (select max(id) from TB_STORE_ITEM_OPINIONPOLL where fk_item_id =i.id and isActive = 1 ) order by cntOpinions desc) cntOpinions
	FROM
			#temp I  
			Left join TB_STORE_ITEM_OPINIONPOLL SIO WITH (NOLOCK) ON I.id = SIO.fk_item_id and SIO.isActive = 1 and SIO.fk_store_id = i.maxStoreId
	

	
	select
		s.title + ' - ' + ST.title + ' - ' + c.title branchMap_dsc
	from
		#temp t 
		inner  join TB_STORE S on s.id = t.pk_fk_store_id
		inner join TB_ITEM I on t.id = i.id
		left join TB_CITY C on i.fk_city_id = c.id
		left join TB_STATE ST on ST.id = c.fk_state_id
	where t.[type] = 6 

	select
		t.id,
		d.completeLink  as ImageUrl,
		d.thumbcompeleteLink
	from
		(select distinct id from #temp) T
		inner JOIN TB_DOCUMENT_ITEM DI ON  DI.pk_fk_item_id = T.id and DI.isDefault = 1
		inner JOIN TB_DOCUMENT D ON DI.pk_fk_document_id = D.id and D.fk_documentType_id = 2	

    
	select
			 t.id ,
			 count(sie.id) evalCnt
			,cast (sum(sie.rate) / count(sie.id) as decimal(10,2)) evalAvg
	from 
		#temp t
		inner join 
	    TB_STORE_item_EVALUATION sie on t.id = sie.fk_item_id
	 
	
	group by t.id

		
		
	
	
RETURN 0