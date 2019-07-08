CREATE PROCEDURE [dbo].[SP_searchStore]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100) = null,
	@parent as varchar(20) ,
	@userId as bigint,
	@itemGroupId as bigint,
	@lat as float,
	@lng as float,
	@curLat as float = 0,
	@curLng as float = 0,
	@justOpenStore as bit,
	@maxDistanceToStore as float,
	@sortByDistance as bit,
	@sortByOpenCloseState as bit,
	@sortAlphabetic as bit,
	@cityId as int,
	@typeStore as int
AS
	SET NOCOUNT ON

	set @cityId = 0

	declare @curLoc geography
	declare @loc geography
	if(@lat > 0 and @lng > 0 )--and @curLng > 0 and @curLat > 0)
	begin
		set @loc = geography::Point(@lat,@lng,4326);
		set @curLoc = geography::Point(@curLat,@curLng,4326);
		set @maxDistanceToStore = 10000 -- 10KM
	end
	--;with name_tree
	--as 
	--(
	--  select id, fk_item_grp_ref
	--  from TB_TYP_ITEM_GRP as g  with(nolock)
	--  --where id = 21532
	--  --join TB_STORE_ITEMGRP_PANEL_CATEGORY as p on g.id = p.pk_fk_itemGrp_id and p.pk_fk_store_id = 56
	--  union all
	--  select C.id, C.fk_item_grp_ref
	--  from TB_TYP_ITEM_GRP c with(nolock)
	--  join name_tree p on C.id = P.fk_item_grp_ref  
	--)
	--select * INTO #TEMP from name_tree OPTION (MAXRECURSION 0)
	

	;with result 
	as
	(
		select 
			ts.id,ts.title,
			ts.[location].Lat lat,ts.[location].Long lng,ts.[address],ts.fk_city_id,c.title cityTitle,ts.fk_country_id,ts.address_full,
			ts.keyWords,ts.score,ts.[location].STAsText() location,ts.fk_status_shiftStatus,
			case when ts.fk_OnlinePayment_StatusId = 13 then 1 else 0 end onlinePayment,
			case when ts.fk_securePayment_StatusId = 13 then 1 else 0 end securePayment,
			ts.fk_storePersonalityType_id,
			ts.fk_status_id
		from 
			TB_STORE ts  with(nolock)
			Left JOIN TB_CITY c with(nolock) on ts.fk_city_id = c.id
		where
			(ts.fk_store_type_id = 1  or (ts.fk_store_type_id = 2 and exists(select top 1 1 from TB_STORE_CUSTOMER where  pk_fk_store_id = ts.id and pk_fk_usr_cstmrId = @userId and fk_status_id = 32) or @typeStore = 0))
			and (@search is null or @search = '' or ts.title like '%'+ @search +'%'  or ts.keyWords like '%'+@search+'%' or ts.title_second like '%'+@search+'%')
			and (@itemGroupId is null or exists(select 1 from  dbo.storePanelCategory_getSelfAndParents(ts.id) as spp where spp.itemGrpId =  @itemGroupId))
			and (ts.fk_city_id = @cityId or @cityId = 0 or @cityId is null)
			and ((ts.fk_status_shiftStatus = case when @justOpenStore = 1 then 17 end) or @justOpenStore = 0)
		    and (@loc.STDistance(ts.[location]) < @maxDistanceToStore or @maxDistanceToStore = 0)
			and ts.fk_status_id = 13
	  ORDER BY 
		CASE WHEN @sortByDistance = 1 THEN @curLoc.STDistance([location]) else 0 END  ASC, 
		CASE WHEN @sortByOpenCloseState = 1 then fk_status_shiftStatus else 0 END  ASC,
		CASE WHEN @sortAlphabetic = 1 then ts.title else NULL END ASC
	  	OFFSET (@pageNo * 10 ) ROWS
		FETCH NEXT 10 ROWS ONLY
	) 
     select * into #basicResult from result OPTION (recompile)
	 if(@lat > 0 and @lng > 0)
	 begin
		SELECT  * FROM #basicResult
	 end
	else
	 begin
	    SELECT  * FROM #basicResult b 
	    where  (b.fk_storePersonalityType_id = @typeStore or @typeStore = 0)
	 end
	 select ex.pk_fk_store_id,sex.id,sex.title from TB_STORE_EXPERTISE ex inner join TB_TYP_STORE_EXPERTISE sex on ex.pk_fk_expertise_id = sex.id
	 where ex.pk_fk_store_id in ((select id from #basicResult))
	 
	 select count(pk_fk_store_id) userStoreMember,pk_fk_store_id from TB_STORE_CUSTOMER  where pk_fk_store_id in ((select id from #basicResult))
	 group by pk_fk_store_id

	  select count(pk_fk_store_id) userStoreMember,pk_fk_store_id from TB_STORE_CUSTOMER  where pk_fk_usr_cstmrId = @userId
	 group by pk_fk_store_id

	  select distinct ts.id,d1.id imageId,D1.completeLink completeLink1,d1.thumbcompeleteLink thumbcompeleteLink1
	 from #basicResult ts
				inner join TB_DOCUMENT_STORE DS1 on ts.id = DS1.pk_fk_store_id and DS1.isDefault = 1
			inner join TB_DOCUMENT D1 on D1.id = DS1.pk_fk_document_id and d1.fk_documentType_id = 5
				group by ts.id,d1.id ,D1.completeLink ,d1.thumbcompeleteLink
	declare @documents as table(id bigint,isDefault bit,fk_documenttype_id smallint,completeLink nvarchar(250),thumbcompeleteLink nvarchar(250),typ smallint)
	insert into @documents
 
 select
 ts.id,
 ds.isDefault,
 d.fk_documenttype_id,
  d.completeLink,
  d.thumbcompeleteLink,
  0 typ
  from #basicResult as ts
	 left join TB_DOCUMENT_STORE DS on ts.id = DS.pk_fk_store_id --and ds.isDefault = 1
	 left join TB_DOCUMENT D on D.id = DS.pk_fk_document_id
 
 if((select count(id) from @documents) < 5)
begin
insert into @documents
 select distinct
  ts.id,
  0 isDefault,
  d.fk_documenttype_id,
  d.completeLink,
  d.thumbcompeleteLink,
  1 typ
  from #basicResult as ts
  left join  TB_STORE_VITRIN SV on SV.fk_store_id = ts.id
  left join TB_DOCUMENT_STORE_VITRIN DSV on SV.id = DSV.pk_fk_vitrin_id
  left join TB_DOCUMENT D on D.id = DSV.pk_fk_document_id

end 
if((select count(id) from @documents) < 5)
begin
insert into @documents
select distinct
 ts.id,
 Di.isDefault,
 d.fk_documenttype_id,
  d.completeLink,
  d.thumbcompeleteLink,
  2 typ
  from #basicResult as ts
	 left join  TB_STORE_ITEM_QTY siq on siq.pk_fk_store_id = ts.id
	 left join TB_DOCUMENT_ITEM Di on siq.pk_fk_item_id = Di.pk_fk_item_id
	 left join TB_DOCUMENT D on D.id = Di.pk_fk_document_id

END
select * from @documents
 where completeLink is not null and fk_documentType_id <> 5
 order by typ,isDefault desc

  select s.hasDelivery,S.pk_fk_store_id storeId from TB_STORE_ITEM_QTY S inner join #basicResult b on s.pk_fk_store_id = b.id
  select 'از ' + cast(isActiveFrom as nvarchar(5))+' تا '+cast(activeUntil as nvarchar(5)) time_,fk_store_id storeId from TB_STORE_SCHEDULE where onDayOfWeek =case when (SELECT DATEPART(dw,GETDATE())) = 7 then 0 else (SELECT DATEPART(dw,GETDATE())) end and fk_store_id in(select id from #basicResult)
  select fk_store_id storeId from TB_STORE_SCHEDULE where (select cast(getdate() as time)) between isActiveFrom and activeUntil and fk_store_id in(select id from #basicResult)
  select pk_fk_store_id storeId,ISNULL(tr.title,grp.title) grpTitle,grp.id from TB_STORE_ITEMGRP_PANEL_CATEGORY cat inner join TB_TYP_ITEM_GRP grp on cat.pk_fk_itemGrp_id = grp.id left join TB_TYP_ITEM_GRP_TRANSLATIONS tr on grp.id = tr.id and lan = @clientLanguage where pk_fk_store_id in(select id from #basicResult)
  select id,ISNULL(dbo.func_calcDistance(@clientLanguage,@curLoc,[location]),0) distance from #basicResult  
  select  
	b.id,
	isnull(srt.id,s.id) statusId,
	isnull(srt.title,s.title) statusTitle
  from 
	#basicResult B 
	inner join TB_STATUS s on b.fk_status_id = s.id
	left join TB_STATUS_TRANSLATIONS srt on srt.id = s.id and srt.lan = @clientLanguage
RETURN 0

