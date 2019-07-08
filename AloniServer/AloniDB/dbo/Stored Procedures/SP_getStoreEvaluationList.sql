CREATE PROCEDURE [dbo].[SP_getStoreEvaluationList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint, 
	@pageNo as int = 0,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@storeId as bigint,
	@permitToVote as bit out
AS
	SET NOCOUNT ON 
	set @pageNo = ISNULL(@pageNo,0)
	declare @storeType as int = (select fk_store_type_id from TB_STORE where id = @storeId)
	set @permitToVote = case when (exists (select top 1 1 from TB_STORE_CUSTOMER where pk_fk_store_id = @storeId and pk_fk_usr_cstmrId = @userId and fk_status_id = 32 and @storeType = 2) or (dbo.func_GetUserStaffStore(@userId,@storeId) in(11,12,13,14)) or @storeType = 1 ) and not exists(select top 1 1 from TB_STORE_EVALUATION where fk_store_id = @storeId and fk_usr_id = @userId) then 1  else 0 end
	select 
		e.id,
		u.fname + ISNULL(u.lname,'') name, 
		dbo.func_getDateByLanguage('fa',e.saveDateTime,0) date,
		cast(comment as nvarchar(max)) comment,
		(select COUNT(ev.[like]) from TB_STORE_EVALUATION_VOTE ev where fk_store_evaluation_id = e.id and [like] = 1) likeNo,
		(select COUNT(ev.dislike) from TB_STORE_EVALUATION_VOTE ev where fk_store_evaluation_id = e.id and dislike = 1) disLikeNo,
		isnull((select COUNT(o.id) from TB_ORDER O where fk_status_statusId in(102,105) and fk_usr_customerId = u.id),0) orderCnt,
		rate,
		case when exists(select top 1 1 from TB_STORE_EVALUATION_VOTE where fk_store_evaluation_id = e.id and fk_usr_voteUsrId = @userId) then 1 else 0 END voted
	from
		TB_STORE_EVALUATION E inner join TB_USR U on e.fk_usr_id = u.id
	where
		fk_store_id = @storeId 
	order by e.id
	OFFSET (@pageNo * 10) ROWS
	FETCH NEXT 10 ROWS ONLY;

	select 
		COUNT(e.id) commentNo, 
		sum(e.rate * e.sumPurchese) / case when e.sumPurchese > 0 then SUM(e.sumPurchese * 5) else 1 end storeRate
		
	from
		TB_STORE_EVALUATION E
	where
	fk_store_id = @storeId 
	group by e.sumPurchese

	
RETURN 0
