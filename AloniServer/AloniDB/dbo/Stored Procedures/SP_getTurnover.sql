CREATE PROCEDURE [dbo].[SP_getTurnover]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint, 
	@pageNo as int = 0,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@storeId as bigint = NULL

AS
SET NOCOUNT ON 
set @storeId = case when @storeId is not null and @storeId > 0 then @storeId else NULL END
select * into #temp from(SELECT 
		fa.id,regardDsc,debit,credit,dbo.func_getDateByLanguage('fa',saveDatetime,1) saveDatetime
FROM 
	tb_financial_account F
	inner join
	TB_FINANCIAL_ACCOUNTING FA
	on 
	F.id = fa.fk_UsrFinancialAccount_id
WHERE
	((f.fk_usr_userId = @userId and @storeId = NULL) or (f.fk_store_id = @storeId and @storeId > 0)) --and F.fk_status_id
	) as ttt

select t1.id,t1.regardDsc,t1.debit,t1.credit,t1.saveDatetime,(t1.debit+t1.credit) man, SUM(t2.debit+t2.credit) as sum
from #temp t1
inner join #temp t2 on t1.id >= t2.id
group by t1.id, t1.debit,t1.credit,t1.regardDsc,t1.debit,t1.credit,t1.saveDatetime
order by t1.id

RETURN 0

--drop table #temp