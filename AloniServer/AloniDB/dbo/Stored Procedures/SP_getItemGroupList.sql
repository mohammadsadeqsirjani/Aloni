CREATE PROCEDURE [dbo].[SP_getItemGroupList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@pageNo as int,
	@search as nvarchar(100) = NULL,
	@type as smallint,
	@parent as varchar(20) = NULL

AS
	SET NOCOUNT ON
	set @pageNo = ISNULL(@pageNo,0)
	if(@parent is not null and @parent <> '')
	begin
		SELECT
			TYG.id,TYG.title,D.completeLink,d.thumbcompeleteLink,CASE 
		WHEN EXISTS (
				SELECT 1
				FROM TB_TYP_ITEM_GRP AS cg
				WHERE cg.fk_item_grp_ref = TYG.id
				)
			THEN 1
		ELSE 0
		END AS hasChild
		FROM
			TB_TYP_ITEM_GRP TYG WITH(NOLOCK) LEFT JOIN TB_DOCUMENT D WITH(NOLOCK) ON TYG.fk_document_id = D.id
		WHERE
			TYG.fk_item_grp_ref =  cast(@parent as bigint) 
			and  title like case when @search is not null and @search <> '' then '%'+@search+'%' else title end
			and (TYG.[type] = @type or @type = 0 or @type is null)
		ORDER BY TYG.id desc
		--OFFSET (@pageNo * 10 ) ROWS
		--FETCH NEXT 10 ROWS ONLY;
	end
	else
	begin
		SELECT
			TYG.id,TYG.title,D.completeLink,d.thumbcompeleteLink,CASE 
		WHEN EXISTS (
				SELECT 1
				FROM TB_TYP_ITEM_GRP AS cg
				WHERE cg.fk_item_grp_ref = TYG.id
				)
			THEN 1
		ELSE 0
		END AS hasChild
		FROM
			TB_TYP_ITEM_GRP TYG WITH(NOLOCK) LEFT JOIN TB_DOCUMENT D WITH(NOLOCK) ON TYG.fk_document_id = D.id
		WHERE
			TYG.fk_item_grp_ref is null 
			and  (title like case when @search is not null and @search <> '' then '%'+@search+'%' else title end or @search is null or @search = '')
			and (TYG.[type] = @type or @type = 0 or @type is null)
		ORDER BY TYG.id desc
		--OFFSET (@pageNo * 10 ) ROWS
		--FETCH NEXT 10 ROWS ONLY;
	end
	
RETURN 0
