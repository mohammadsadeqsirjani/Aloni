CREATE PROCEDURE [dbo].[SP_searchTemplateItem]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@pageNo as int,
	@search as nvarchar(100),
	@type as smallint,
	@parent as varchar(20) = null,
	@storeId as bigint
	
AS
	SET NOCOUNT ON
	SELECT 
		i.id,i.barcode,i.title,i.technicalTitle,i.fk_itemGrp_id,g.title grpName
	FROM
		 TB_TYP_ITEM_GRP g with(nolock) inner join  TB_ITEM i with(nolock) on  i.fk_itemGrp_id = g.id  
		 inner join TB_STORE_ITEM_QTY si with(nolock) on i.id = si.pk_fk_item_id inner join TB_USR_STAFF us on si.pk_fk_store_id = us.fk_store_id
	WHERE
		 i.barcode = @search 
		 or
		 FREETEXT(i.*, @search) 
		 and
		 si.pk_fk_store_id = @storeId 
		 and
		 i.isTemplate = 1 
		 and 
		 si.fk_status_id = 15
		 and 
		 us.fk_usr_id = @userId
		 and 
		 (@search is null or @search = '' or i.title like '%'+@search+'%')
		 and 
		 (g.[type] = @type or @type = 0 or @type is null)
	ORDER BY i.id
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;
RETURN 0