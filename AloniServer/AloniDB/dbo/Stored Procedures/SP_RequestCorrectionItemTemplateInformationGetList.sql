CREATE PROCEDURE [dbo].[SP_RequestCorrectionItemTemplateInformationGetList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint, 
	@pageNo as int = 0,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@storeId as bigint,
	@filterByStatus as int = 0,
	@filterByDateFrom as datetime = null,
	@filterByDateTo as datetime = null
AS
	SET NOCOUNT ON
	set @pageNo = ISNULL(@pageNo,0)
	
	SELECT
		i.id,
		i.title,
		SE.id rqId,
		SE.suggestedTitle,
		SE.suggestedBarcode,
		SE.fk_status_id,
		ISNULL(SR.title,S.title) statusTitle,
		SE.[description],
		dbo.func_udf_Gregorian_To_Persian(SE.requestDate) requestDate,
		dbo.func_udf_Gregorian_To_Persian(SE.reviewDateTime) reviewDate,
		SE.reviewDescription
	FROM
		TB_REQUEST_CORRECTION_TEMPLATE_INFORMATION SE with(nolock) 
		inner join TB_ITEM I with(nolock) on SE.fk_item_id = I.id
		inner join TB_STATUS S on s.id  = SE.fk_status_id
		left join TB_STATUS_TRANSLATIONS SR on s.id = SR.id and lan = @clientLanguage
		
	WHERE
		SE.fk_store_id = @storeId
		AND
		(SE.fk_status_id = @filterByStatus or @filterByStatus = 0 or @filterByStatus is NULL)
		AND
		((SE.requestDate between @filterByDateFrom AND @filterByDateTo) OR @filterByDateFrom is NULL or @filterByDateTo is NULL)
		AND
		(i.title like '%'+@search+'%' or @search is null or @search = '')
	order by se.requestDate DESC
	OFFSET case when @pageNO >= 0 then (@pageNo * 10 ) else 100000000 end ROWS
	FETCH NEXT case when @pageNO >= 0 then 10 else 100000000 end ROWS ONLY;

	SELECT 
		r.id,
		D.thumbcompeleteLink,
		d.id documentId
	FROM

	TB_REQUEST_CORRECTION_TEMPLATE_INFORMATION r WITH(NOLOCK)
	INNER JOIN TB_DOCUMENT_REQUEST_CORRECTION_ITEM_TEMPLATE_INFORMATION dr
	ON R.id = dr.pk_fk_request_correction_id
	INNER JOIN TB_DOCUMENT d
	ON dr.pk_fk_document_id = d.id
	WHERE
		D.fk_documentType_id = 14
		AND
		r.fk_store_id = @storeId
		AND
		(r.fk_status_id = @filterByStatus or @filterByStatus = 0 or @filterByStatus is NULL)
		AND
		((r.requestDate between @filterByDateFrom AND @filterByDateTo) OR @filterByDateFrom is NULL or @filterByDateTo is NULL)
		
RETURN 0
