CREATE PROCEDURE [dbo].[SP_reportGetEmployee]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@userId as bigint,
	@search as nvarchar(100),
	@parent as varchar(20) = null,
	@storeId as bigint,
	@groupId as bigint
AS
	set nocount on
	declare @spotSearch as nvarchar(100)= case when @search = '' or @search is null then '""' else @search end
	select
		 i.id,
		 i.title,
		 case when sex = 1 then 'مرد' when sex = 0 then 'زن' else 'نامشخص' end sex,
		 technicalTitle,
		 barcode,
		 uniqueBarcode,
		 ISNULL(tygtr.title,tyg.title) groupTitle,
		 s.title state,
		 c.title city,
		 i.unitName,
		 i.village,
		 ISNULL(edur.title,edu.title) educationTitle,
		 SCC.title categoryTitle
	from
		 TB_ITEM I with(nolock) 
		 INNER JOIN TB_TYP_ITEM_GRP tyg on i.fk_itemGrp_id = tyg.id
		 LEFT JOIN TB_TYP_ITEM_GRP_TRANSLATIONS tygtr on tyg.id = tygtr.id and tygtr.lan = @clientLanguage
		 LEFT JOIN TB_STATE s on i.fk_state_id = s.id
		 LEFT JOIN TB_CITY c on i.fk_city_id = c.id
		 LEFT JOIN TB_TYP_EDUCATION edu on i.fk_education_id = edu.id
		 LEFT JOIN TB_TYP_EDUCATION_TRANSLATION edur on edu.id = edur.id and edur.lan = @clientLanguage
		 LEFT JOIN TB_STORE_CUSTOMCATEGORY_ITEM sci on i.id = sci.pk_fk_item_id
		 LEFT JOIN TB_STORE_CUSTOM_CATEGORY SCC on sci.pk_fk_custom_category_id = SCC.id and SCC.fk_store_id = @storeId and SCC.type = 2
		 
	where
		fk_savestore_id = @storeId 
		and 
		itemType = 2 
		and 
		fk_status_id != 16
		and
		(tyg.id = @groupId or @groupId is null or @groupId = 0)
		and 
		((freetext((i.title,technicalTitle,barcode),@spotSearch)) or @search is null or @search = '')
	ORDER BY i.id
	--OFFSET (@pageNo * 10 ) ROWS
	--FETCH NEXT 10 ROWS ONLY;
RETURN 0
