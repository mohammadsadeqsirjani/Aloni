CREATE PROCEDURE [dbo].[SP_reportGetEntities]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20) = null,
	@storeId as bigint,
	@groupId as bigint,
	@type as smallint
AS
	set nocount on
	declare @spotSearch as nvarchar(100)= case when @search = '' or @search is null then '""' else @search end
	select
		 i.id,
		 i.title,
		 technicalTitle,
		 barcode,
		 siq.localBarcode,
		 i.uniqueBarcode,
		 ISNULL(tygtr.title,tyg.title) groupTitle,
		 s.title state,
		 c.title city,
		 i.unitName,
		 i.village,
		 ISNULL(edur.title,edu.title) educationTitle,
		 --SCC.title categoryTitle,
		 substring(
						(select 
							','+SCC.title
						 from TB_STORE_CUSTOMCATEGORY_ITEM sci inner JOIN TB_STORE_CUSTOM_CATEGORY SCC on sci.pk_fk_custom_category_id = SCC.id
						where
							SCC.fk_store_id = @storeId 
							and 
							SCC.type = @type
							and
							sci.pk_fk_item_id = i.id
						for xml path (''))
						,2,2147483647 ) as categoryTitle,
		 siq.ManufacturerCo,
		 siq.importerCo,
		 cou.title ManufacturerCountry
	from
		 TB_ITEM I with(nolock) 
		 INNER JOIN TB_STORE_ITEM_QTY siq with(nolock) on i.id = siq.pk_fk_item_id
		 INNER JOIN TB_TYP_ITEM_GRP tyg on i.fk_itemGrp_id = tyg.id
		 LEFT JOIN TB_TYP_ITEM_GRP_TRANSLATIONS tygtr on tyg.id = tygtr.id and tygtr.lan = @clientLanguage
		 LEFT JOIN TB_STATE s on i.fk_state_id = s.id
		 LEFT JOIN TB_CITY c on i.fk_city_id = c.id
		 LEFT JOIN TB_TYP_EDUCATION edu on i.fk_education_id = edu.id
		 LEFT JOIN TB_TYP_EDUCATION_TRANSLATION edur on edu.id = edur.id and edur.lan = @clientLanguage
		 --LEFT JOIN TB_STORE_CUSTOMCATEGORY_ITEM sci on i.id = sci.pk_fk_item_id
		 --LEFT JOIN TB_STORE_CUSTOM_CATEGORY SCC on sci.pk_fk_custom_category_id = SCC.id and SCC.fk_store_id = @storeId and SCC.type = @type
		 LEFT JOIN TB_COUNTRY cou  on siq.fk_country_Manufacturer = cou.id
		 
	where
		pk_fk_store_id = @storeId 
		and 
		itemType = @type 
		and 
		i.fk_status_id != 16
		and
		(tyg.id = @groupId or @groupId is null or @groupId = 0)
		and 
		((freetext((i.title,technicalTitle,barcode),@spotSearch)) or @search is null or @search = '')
	ORDER BY i.id
	--OFFSET (@pageNo * 10 ) ROWS
	--FETCH NEXT 10 ROWS ONLY;
RETURN 0