CREATE PROCEDURE [dbo].[SP_getStorePlannersSubscriberList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20),
	@userId as bigint,
	@storeId as bigint,
	@planId as bigint
AS
	SET NOCOUNT ON
	set @pageNo = ISNULL(@pageNo,0);
	with base
	as
	(
		SELECT 
			u.id,u.fname + ' '+ ISNULL(u.lname,'') name,[dbo].[func_getPriceAsDisplayValue](SUM(isnull(a.credit,0)),@clientLanguage,@storeId) as comission,
			isnull(strr.title,st.title) status--cast(SUM(a.credit) as varchar(50)) +' ' + dbo.func_getCurrencyTitleByLanguage(@clientLanguage,@storeId,1) comission
		FROM
			TB_STORE_MARKETING M 
			inner join TB_STORE_MARKETING_MEMBER MM on m.id = mm.fk_store_marketing_id
			inner join TB_USR U on mm.fk_usr_id = u.id
			inner join TB_STATUS st on st.id = M.fk_status_id
			left  join TB_STATUS_TRANSLATIONS strr on st.id = strr.id and lan = @clientLanguage
			left join TB_FINANCIAL_ACCOUNT F on f.fk_usr_userId = mm.fk_usr_id
			left join TB_FINANCIAL_ACCOUNTING A on f.id = A.fk_UsrFinancialAccount_id and A.fk_typFinancialRegardType_id = 7
		where 
			m.fk_store_id = @storeId and M.id = @planId 
			and (u.fname like '%'+@search+'%' or @search is null or @search = '')
		group by u.id,u.fname,u.lname,a.credit,strr.title,st.title
	)
	select * into #temp from base
	select * from #temp
	order by id
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY

	select fk_parent_usr_id,COUNT(fk_usr_id) member from TB_STORE_MARKETING_MEMBER where fk_parent_usr_id in(select id from #temp)
	group by fk_parent_usr_id
RETURN 0