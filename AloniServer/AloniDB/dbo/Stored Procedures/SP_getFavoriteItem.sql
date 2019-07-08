CREATE PROCEDURE [dbo].[SP_getFavoriteItem]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100) = NULL,
	@parent as varchar(20) = null,
	@userId as bigint,
	@storeId as bigint
AS
	SET NOCOUNT ON
	SELECT
		 i.id,
		 i.title,
		 s.id storeId,
		 s.title storeTitle,
		 d.thumbcompeleteLink
	FROM
		TB_STORE_ITEM_FAVORITE sif
		inner join 	TB_ITEM i on sif.pk_fk_item_id = i.id
		inner join TB_STORE s on sif.pk_fk_store_id = s.id
		left join TB_DOCUMENT_ITEM di on di.pk_fk_item_id = i.id and di.isDefault = 1
		left join TB_DOCUMENT d on di.pk_fk_document_id = d.id
	WHERE
		sif.pk_fk_usr_id = @userId
	ORDER BY i.id
	OFFSET (isnull(@pageNo,0) * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;
RETURN 0
