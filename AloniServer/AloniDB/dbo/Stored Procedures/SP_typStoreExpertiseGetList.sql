CREATE PROCEDURE [dbo].[SP_typStoreExpertiseGetList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100) = null,
	@parent as varchar(20),
	@userId as bigint = null
AS
set @pageNo = ISNULL(@pageNo,0)
select E.id,E.title from TB_TYP_STORE_EXPERTISE as E with (nolock)
inner join TB_STORECATEGORY_STOREEXPERTISE as C with (nolock)
on E.id = C.pk_fk_storeExpertise_id
	where isActive = 1 
	and e.title like case when @search is not null and @search <> '' then '%'+@search+'%' else e.title end
	and  C.pk_fk_storeCategory_id = case when @parent is not null and  @parent <> '' then CAST(@parent as int) else c.pk_fk_storeCategory_id end
	ORDER BY Id
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;