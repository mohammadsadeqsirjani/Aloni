CREATE PROCEDURE [dbo].[SP_getNearByLocation]
	 @clientLanguage AS CHAR(2)
	,@appId AS TINYINT
	,@clientIp AS VARCHAR(50)
	,@userId AS BIGINT
	,@pageNo AS INT = 0
	,@search AS NVARCHAR(100) = null
	,@parent AS NVARCHAR(100) = null
	,@centerScreenLat AS FLOAT
	,@centerScreenLng AS FLOAT
	,@curLat AS FLOAT
	,@curLng AS FLOAT
AS
	SET NOCOUNT ON
	declare @distance as float = 10000
	declare @centerLocation as geography = geography::Point(@centerScreenLat,@centerScreenLng,4326)
	if(@curLng > 0 and @curLat > 0)
	begin
	
		declare @curLoc geography = geography::Point(@curLat,@curLng,4326);
	end
	
	select * into #temp from (select 
			s.id,
			s.title,
			s.[description] title2,
			case when @centerScreenLat > 0 and @centerScreenLng > 0 then dbo.func_calcDistance('fa',@curLoc,s.[location]) else '0' end distance,
			s.[location].Lat lat,
			s.[location].Long lng,
			d.thumbcompeleteLink,
			d.completeLink,
			7 [type],
			'فروشگاه' type_dsc,
			s.id storeId
			
	from 
			TB_STORE s  
			inner join TB_DOCUMENT_STORE ds on s.id = ds.pk_fk_store_id and ds.isDefault = 1
			inner join TB_DOCUMENT d on d.id = ds.pk_fk_document_id and d.fk_documenttype_id = 5
	where
			 (@centerLocation.STDistance(ISNULL(s.[location], 0xE6100000010C69FD2D01F8D7414098F8A3A833AF4940)) <  @distance  or @centerScreenLat = 0 or @centerScreenLng = 0)
			 AND
			 s.fk_status_id = 13
			 ) tt
	
	select * into #temp1 from (select 
			s.id,
			s.title,
			s.technicalTitle title2,
			case when @centerScreenLat > 0 and @centerScreenLng > 0 then dbo.func_calcDistance('fa',@curLoc,siq.[location]) else '0' end distance,
			siq.[location].Lat lat,
			siq.[location].Long lng,
			d.thumbcompeleteLink,
			d.completeLink,
			tyg.[type] [type],
			case when tyg.[type] = 1 then 'کالا' when tyg.[type] = 2 then 'پرسنل' when tyg.[type] = 3 then 'شغل' when tyg.[type] = 4 then 'اشیاء' when tyg.[type] = 5 then 'سازمان' when tyg.[type] = 6 then 'سازمان' END type_dsc,
			siq.pk_fk_store_id storeId
	from 
	        tb_item s inner join
			TB_STORE_ITEM_QTY siq on s.id = siq.pk_fk_item_id
			inner join TB_TYP_ITEM_GRP tyg on s.fk_itemGrp_id = tyg.id
			left join TB_DOCUMENT_ITEM ds on s.id = ds.pk_fk_item_id and ds.isDefault = 1
			left join TB_DOCUMENT d on d.id = ds.pk_fk_document_id
	where
			 (@centerLocation.STDistance(ISNULL(siq.[location], 0xE6100000010C69FD2D01F8D7414098F8A3A833AF4940)) <  @distance  or @centerScreenLat = 0 or @centerScreenLng = 0)
			 AND
			 s.fk_status_id = 15 and siq.fk_status_id = 15
			 AND
			 tyg.[type] not in(1,2)
			 AND
			 siq.[location] is not null
			 ) ttt
 if(@pageNo >= 0)
 begin
  select * from (select * from #temp
	union all
	select * from #temp1) ss
  order by ss.id
  OFFSET  (@pageNo * 10 ) ROWS
  FETCH NEXT 10 ROW ONLY
end		
else
begin
	 select * from (select * from #temp
	union all
	select * from #temp1) ss
  order by ss.id
end		
RETURN 0
