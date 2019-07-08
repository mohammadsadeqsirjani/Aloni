CREATE PROCEDURE [dbo].[SP_getInvitationList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint, 
	@pageNo as int = 0,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null
AS
	SET NOCOUNT ON
	set @pageNo = ISNULL(@pageNo,0)
	
	SELECT
		us.id, u.fname + ' '+ISNULL(u.lname,'') name,u.mobile, dbo.Func_GetUserStaffStoreDescription(@clientLanguage,us.save_fk_usr_id,us.fk_store_id) + ' - ' + store.title storeInfo,ISNULL(STT.title,st.title) semat_pishnahadi
		,US.[description] recommanderDesc
	FROM
		TB_USR U with(nolock) inner join TB_USR_STAFF US with(nolock) on u.id = US.save_fk_usr_id -- ersal konandeh davatname
		inner join TB_STORE store with(nolock) on us.fk_store_id = store.id
		inner join TB_STAFF ST with(nolock) on US.fk_staff_id = ST.id left join TB_STAFF_TRANSLATIONS STT with(nolock) on ST.id = STT.id and STT.lan = @clientLanguage
	WHERE
		us.fk_usr_id = @userId and us.fk_status_id = 6 
		and u.fname like case when @search is not null and @search <> '' then '%'+ @search +'%' else u.fname end
	order by us.id 
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;

RETURN 0
