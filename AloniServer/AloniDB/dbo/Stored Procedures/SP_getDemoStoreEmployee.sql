CREATE PROCEDURE [dbo].[SP_getDemoStoreEmployee]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint, 
	@pageNo as int = 0,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@storeId as bigint
AS
	SET NOCOUNT ON
	set @pageNo = ISNULL(@pageNo,0)
	
	SELECT
		se.id,se.fullname,se.mobile,se.staff,se.description,d.id docId,d.completeLink,d.thumbcompeleteLink
	FROM
		TB_STORE_EMPLOYEE SE with(nolock) left join TB_DOCUMENT D with(nolock) on se.fk_document_id = d.id
	WHERE
		SE.fk_store_id = @storeId
		and
		se.fullname like case when @search is not null and @search <> '' then '%'+@search+'%' else se.fullname end
	order by se.id
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;
	
RETURN 0
