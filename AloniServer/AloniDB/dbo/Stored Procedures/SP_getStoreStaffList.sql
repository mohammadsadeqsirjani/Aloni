CREATE PROCEDURE [dbo].[SP_getStoreStaffList]
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
	select
		s.id,isnull(st.title,s.title) title
	from
		TB_STAFF s left join TB_STAFF_TRANSLATIONS st on s.id = st.id and st.lan = @clientLanguage 
	where
		s.fk_app_id = 1 and s.id <> 11
	order by s.id
	OFFSET (@pageNo * 10) rows
	Fetch next 10 rows only	
RETURN 0
