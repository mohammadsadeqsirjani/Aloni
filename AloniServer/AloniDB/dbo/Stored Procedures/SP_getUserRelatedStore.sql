CREATE PROCEDURE [dbo].[SP_getUserRelatedStore]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint, 
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20)
AS
	set nocount on
	
	select 
		store.id,
		store.title  as title,
		ISNULL(ssss.title,staf.title) staffTitle,
		staf.id staffId,
		uu.fname + ' '+ ISNULL(uu.lname,'') userName,
		store.fk_status_id,
		isnull(st_tr.title,stat.title) status_des,
		0 unReadMessageCount,
		0 newOrderCount,
		store.fk_status_id,
		UU.mobile,
		ISNULL(store.autoSyncTimePeriod,0) autoSyncTimePeriod

		
	from
    TB_USR_STAFF as us with(nolock)
    inner join TB_STORE as store with(nolock)  on us.fk_store_id = store.id
	inner join TB_STAFF as staf with(nolock) on  us.fk_staff_id = staf.id
	left join TB_STAFF_TRANSLATIONS ssss on staf.id = ssss.id and ssss.lan = @clientLanguage
	inner join TB_STATUS as stat with(nolock) on store.fk_status_id = stat.id
	left join TB_USR UU on us.fk_usr_id = UU.id 
	left join TB_STATUS_TRANSLATIONS  as  st_tr with(nolock) on stat.id = st_tr.id and st_tr.lan = @clientLanguage
	where 
			us.fk_usr_id = @userId and us.fk_status_id = 8 and  store.title like case when @search is not null and @search <> '' then  '%'+@search+'%' else store.title end
			and 
			store.fk_status_id <> 14
	
RETURN 0
