CREATE PROCEDURE [dbo].[SP_getStoreItemEvaluation]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = null,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@userId as bigint,
	@storeId as bigint,
	@itemId as bigint,
	@filterByStatus as int = 0,
	@filterByItemGrp as bigint,
	@type as smallint = 0,
	@orderType as smallint
AS
	SET NOCOUNT ON
	set @pageNo = isnull(@pageNo,0)
	select 
		i.id,
		I.title,
		i.barcode,
		i.itemType,
		tyg.id itemGrpId,
		tyg.title itemGrpTitle,
		U.fname+' '+ISNULL(U.lname,'') name,
		u.id userId,
		sie.id evId,
		cast(SIE.comment as nvarchar(max)) comment,
		SIE.rate,
		ISNULL(ST.title,STRR.title) status_dsc,
		ST.id statusId,
		dbo.func_udf_Gregorian_To_Persian_withTime(SIE.saveDateTime) date_,
		d.thumbcompeleteLink
	from 
		TB_ITEM i with(nolock) 
		INNER JOIN TB_TYP_ITEM_GRP tyg with(nolock) ON i.fk_itemGrp_id = tyg.id
		INNER JOIN TB_STORE_ITEM_QTY SIQ with(nolock) ON i.id = SIQ.pk_fk_item_id 
		INNER JOIN TB_STORE_ITEM_EVALUATION SIE with(nolock) ON SIE.fk_item_id = SIQ.pk_fk_item_id
		INNER JOIN TB_USR U ON SIE.fk_usr_id = U.id
		LEFT JOIN TB_STATUS ST ON SIE.fk_status_id = ST.id
		LEFT JOIN TB_STATUS_TRANSLATIONS STRR ON ST.id = STRR.id AND lan = @clientLanguage
		left join TB_DOCUMENT_ITEM DI with(nolock) on i.id = DI.pk_fk_item_id and DI.isDefault = 1
		left join TB_DOCUMENT D with(nolock) on d.id = DI.pk_fk_document_id
	where
		SIE.fk_store_id = @storeId 
		AND
		(i.id = @itemId or @itemId = 0)
		AND
		(SIE.fk_status_id = @filterByStatus or @filterByStatus = 0)
		AND
		(i.fk_itemGrp_id = @filterByItemGrp or @filterByItemGrp = 0)
		AND
		(i.itemType = @type or @type = 0)
		AND
		(i.title like '%'+@search +'%' or i.barcode like '%'+@search +'%' or u.fname like '%'+@search +'%' or u.lname like '%'+@search +'%' or SIE.comment like '%'+@search +'%' or @search is null or @search = '')
	order by
	case when @orderType = 0 then SIE.saveDateTime else SIE.rate END DESC,
	case when @orderType = 1 then SIE.rate else SIE.saveDateTime END DESC
	OFFSET (@pageNo * 10) ROWS
	FETCH NEXT 10 ROWS ONLY

	
RETURN 0
