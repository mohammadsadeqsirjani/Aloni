CREATE PROCEDURE [dbo].[SP_getStorePlanList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100) = null,
	@parent as varchar(20),
	@userId as bigint,
	@storeId as bigint
AS
	SET NOCOUNT ON
	set @pageNo = ISNULL(@pageNo,0)
SELECT 
		m.id,m.title,m.minCommission,m.maxCommission,dbo.func_getDateByLanguage(@clientLanguage,M.validityDate,0)validityDate,ISNULL(r.title,s.title) status,(select COUNT(*) from TB_STORE_MARKETING_MEMBER where fk_store_marketing_id = m.id) memberCount,
		case when m.fk_status_id = 48 then 1 else 0 end isActive
	FROM
		TB_STORE_MARKETING M
		inner join TB_STATUS S on m.fk_status_id = s.id left join TB_STATUS_TRANSLATIONS R on s.id = r.id and r.lan = @clientLanguage
	where 
		m.fk_store_id = @storeId
		and 
		m.title like case when @search is not null and @search <> '' then '%'+@search+'%' else m.title end
	order by fk_status_id
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY
RETURN 0
