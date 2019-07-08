CREATE PROCEDURE [dbo].[SP_getStoreList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = null,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@userId as bigint
AS
	select 
		store.id,
		store.title  as title
	from
    TB_USR_STAFF as us with(nolock)
    inner join TB_STORE as store with(nolock)  on us.fk_store_id = store.id
	where 
			us.fk_usr_id = @userId and us.fk_status_id = 8 and  store.title like case when @search is not null and @search <> '' then  '%'+@search+'%' else store.title end
			and 
			store.fk_status_id <> 14
RETURN 0
