CREATE PROCEDURE [dbo].[SP_storePendigToReviewGetList]
@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100),
	@userId as bigint = null
AS

select  S.id , S.title , ST.title as status_title , S.title_second , (select title from dbo.func_getCityById(S.fk_city_id)) city 
from TB_STORE S with (nolock)
left join TB_TYP_STORE_TYPE_TRANSLATIONS ST with (nolock)
on S.fk_store_type_id = ST.id and ST.lan = 'fa'

where fk_status_id = 11  
	and (@search is null or @search = '' or S.title like '%'+@search+'%' or  S.title_second like '%'+@search+'%' )
	ORDER BY S.Id
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;