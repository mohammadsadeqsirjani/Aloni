CREATE PROCEDURE [dbo].[SP_opinionpoll_getList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@opinionPollId as bigint,
	@storeId as bigint,
	@itemId as bigint,
	@itemBarcode as varchar(150),
	@itemGrpType as smallint,
	@sex as bit,
	@itemGrpId as bigint,
	@itemType as smallint = null,
	@isActive as bit,
	@publish as bit,
	@resultIsPublic as bit,
	@startDateTime as datetime,
	@endDateTime as datetime,
	@opinionPollIsRunning as bit
   ,@pageNo AS INT
   ,@search AS NVARCHAR(100)
   ,@parent AS VARCHAR(20)
   ,@sort_countOfparticipants as bit
   ,@sort_totalAvg as bit
   ,@sort_startDateTime as bit
	--@rCode as tinyint out,
	--@rMsg as nvarchar(max) out

AS
	
	if(@itemType is null)
	set @itemType = @itemGrpType;

	--set @pageNo = isnull(@pageNo,0);



with totalCnt as (
select op.id , COUNT ( *) as cnt from (select oppopiions.fk_opinionPollId as id,oppopiions.pk_fk_usr_id 
from  TB_STORE_ITEM_OPINIONPOLL_OPINIONS as oppopiions
--where opp.id = 1
group by  oppopiions.fk_opinionPollId, oppopiions.pk_fk_usr_id) as op 
group by  op.id

),

totalAvg
as(
select opp.id, round(avg(oppopiions.score),1)  as [avg]
from TB_STORE_ITEM_OPINIONPOLL as opp
left join TB_STORE_ITEM_OPINIONPOLL_OPTIONS as oppo
on opp.id = oppo.fk_opinionpoll_id
left join TB_STORE_ITEM_OPINIONPOLL_OPINIONS as oppopiions
on oppo.id = oppopiions.pk_fk_opinionOption_id
--where opp.id = 1
group by  opp.id),

base
as
(
	select --distinct	
	opp.id,
	opp.title,
	--dbo.func_getDateByLanguage(@clientLanguage,opp.saveDateTime,1) as createDateTime,
	opp.saveDateTime as createDateTime,
	opp.fk_store_id as store_id,
	st.title as store_title,
	st.title_second as store_titleSecond,
	dbo.func_getDateByLanguage(@clientLanguage,opp.startDateTime,0) as startDate,
	dbo.func_getDateByLanguage(@clientLanguage,opp.endDateTime,0) as endDate,
	opp.isActive,
	opp.publish,
	opp.startDateTime,
	opp.endDateTime,
	--opp.itemGrpTitle,
	--opp.
	opp.resultIsPublic,
	i.id as itemId,
	i.sex,
	i.barcode as itemBarcode,
	ig.[type] as itemGrpType,
	ISNULL(i_trn.title,i.title) as item_title,
	ISNULL(opp.itemGrpTitle, ISNULL(ig_trn.title,ig.title)) as itemGrp_title,
	ISNULL(d_op.thumbcompeleteLink,d_di.thumbcompeleteLink) as picUrl_thumb,
	ISNULL(d_op.completeLink,d_di.completeLink) as picUrl_full,
	case when @appId = 2 and resultIsPublic <> 1 then null else ta.avg end as totalAvg,
	case when @appId = 2 and resultIsPublic <> 1 then null else tc.cnt end as countOfparticipants,
	case when (opp.isActive = 1 and opp.startDateTime <= getdate() and opp.endDateTime > getdate() and opp.publish = 1) then 1 else 0 end as opinionPollIsRunning,
    case when dateadd(MINUTE,[dbo].[func_store_item_opinionpoll_editTimeout](), opp.publishDateTime) > getdate() and isnull(tc.cnt,0) = 0 then 1 else 0  end as isEditable,
	i.itemType
	from TB_STORE_ITEM_OPINIONPOLL as opp with(nolock)
	join TB_STORE as st  with(nolock)
	on opp.fk_store_id = st.id
	join TB_ITEM as i with(nolock)
	on opp.fk_item_id = i.id
	join TB_TYP_ITEM_GRP as ig with(nolock)	
	on i.fk_itemGrp_id = ig.id
	left join TB_ITEM_TRANSLATIONS as i_trn with(nolock)
	on i.id = i_trn.id and i_trn.lan = @clientLanguage
	left join TB_TYP_ITEM_GRP_TRANSLATIONS as ig_trn with(nolock)
	on ig.id = ig_trn.id and ig_trn.lan = @clientLanguage
	left join TB_DOCUMENT_ITEM as di with(nolock)
	on i.id = di.pk_fk_item_id and di.isDefault = 1
	left join TB_DOCUMENT as d_di with(nolock)
	on di.pk_fk_document_id = d_di.id
	left join TB_DOCUMENT as d_op with(nolock)
	on opp.fk_document_picId = d_op.id
	left join totalCnt as tc on opp.id = tc.id
	left join totalAvg as ta on opp.id = ta.id

	where 
	(@opinionPollId is null or opp.id = @opinionPollId)
	and
	(@storeId is null or st.id = @storeId)
	and
	(@itemId is null or i.id = @itemId)
	and
	(@itemBarcode is null or i.barcode = @itemBarcode)
	and
	(@itemGrpId is null or ig.id = @itemGrpId)
	and
	(@itemType is null or i.itemType = @itemType)
	and
	(@isActive is null or opp.isActive = @isActive)
	and
	(@sex is null or i.sex = @sex)
	--and
	--(@itemGrpType is null or ig.[type] = @itemGrpType)
	and
	((@appId = 1 and @storeId is not null) or (opp.publish = 1))--اطلاعات منتشر نشده در خروجی نمی آیند مگر آنکه اپ فروشنده باشد و شناسه فروشگاه خود را صریحا داده باشد - اینکه فروشگاه با کاربر فروشنده ارتباط دارد یا خیر در رویه اهراز هویت بررسی می شود
	and
	(@search is null or @search = '' or i.technicalTitle like '%' + @search + '%' or i.title like '%' + @search + '%' or opp.title like '%' + @search + '%')
	and
	(@publish is null or opp.publish = @publish)
	and
	(@resultIsPublic is null or opp.resultIsPublic = @resultIsPublic)
	and
	(@startDateTime is null or opp.startDateTime = @startDateTime)
	and
	(@endDateTime is null or opp.endDateTime = @endDateTime)
	and
	(@opinionPollIsRunning is null or ((@opinionPollIsRunning = 1 and opp.isActive = 1 and opp.startDateTime <= getdate() and opp.endDateTime > getdate() and opp.publish = 1) or (@opinionPollIsRunning = 0 and opp.isActive = 0 or opp.startDateTime > getdate() or opp.endDateTime <= GETDATE())))
	)

	select *  into #tmp from base

	if(@appId in(1,2) and @itemId is null and @itemBarcode is null)
	begin--group by , select last
	with lr
	as
	(select b.*,ROW_NUMBER() over(partition by b.itemId order by b.id desc) as rowNum  from #tmp as b)
	select * from lr
	where rowNum = 1
	   ORDER BY
		--lr.id
		CASE 
		WHEN @sort_countOfparticipants = 0
			THEN countOfparticipants
		ELSE 0
		END ASC
	,CASE 
		WHEN @sort_countOfparticipants = 1
			THEN countOfparticipants
		ELSE 0
		END DESC
	,CASE 
		WHEN @sort_totalAvg = 0
			THEN totalAvg
		ELSE 0
		END ASC
	,CASE 
		WHEN @sort_totalAvg = 1
			THEN totalAvg
		ELSE 0
		END DESC
	,CASE 
		WHEN @sort_startDateTime = 0
			THEN startDateTime
		ELSE 0
		END ASC
	,CASE 
		WHEN @sort_startDateTime = 1
			THEN startDateTime
		ELSE 0
		END DESC
	,CASE
	    WHEN @sort_startDateTime is null and @sort_totalAvg is null and @sort_countOfparticipants is null then id end asc
		OFFSET (@pageNo * 10 ) ROWS
		FETCH NEXT 10 ROWS ONLY;
	end
	else
	begin
	   select b.* from #tmp as b
	    ORDER BY
		--lr.id
		CASE 
		WHEN @sort_countOfparticipants = 0
			THEN countOfparticipants
		ELSE 0
		END ASC
	,CASE 
		WHEN @sort_countOfparticipants = 1
			THEN countOfparticipants
		ELSE 0
		END DESC
	,CASE 
		WHEN @sort_totalAvg = 0
			THEN totalAvg
		ELSE 0
		END ASC
	,CASE 
		WHEN @sort_totalAvg = 1
			THEN totalAvg
		ELSE 0
		END DESC
	,CASE 
		WHEN @sort_startDateTime = 0
			THEN startDateTime
		ELSE 0
		END ASC
	,CASE 
		WHEN @sort_startDateTime = 1
			THEN startDateTime
		ELSE 0
		END DESC
	,CASE
	    WHEN @sort_startDateTime is null and @sort_totalAvg is null and @sort_countOfparticipants is null then id end asc
		OFFSET (@pageNo * 10 ) ROWS
		FETCH NEXT 10 ROWS ONLY;
	 --  ORDER BY
		--b.id
		--OFFSET (@pageNo * 10 ) ROWS
		--FETCH NEXT 10 ROWS ONLY;
	end
	
	drop table #tmp;




	if(@opinionPollId is not null)
	begin
	
		select oppo.id as id, --گزینه ها
		oppo.title as title,
		oppo.isActive as isActive,
		case when (@appId = 1 or opp.resultIsPublic = 1 ) then round (avg(oppopiions.score),1) else null end as optionAvg,
		case when @appId = 2 then userOppopiions.score else null end as userScore
		from TB_STORE_ITEM_OPINIONPOLL as opp  with(nolock)
	    join TB_STORE_ITEM_OPINIONPOLL_OPTIONS as oppo  with(nolock) on opp.id = oppo.fk_opinionpoll_id
		left join TB_STORE_ITEM_OPINIONPOLL_OPINIONS as oppopiions  with(nolock) on oppo.id = oppopiions.pk_fk_opinionOption_id
		left join TB_STORE_ITEM_OPINIONPOLL_OPINIONS as userOppopiions  with(nolock) on oppo.id = userOppopiions.pk_fk_opinionOption_id and userOppopiions.pk_fk_usr_id = @userId
		where opp.id = @opinionPollId and ( @appId = 1 or (oppo.isActive = 1)) -- گزینه / سوالات غیر فعال به اپ خریدار داده نمی شود
		group by  oppo.id,oppo.title,oppo.isActive,opp.resultIsPublic,userOppopiions.score;


		with avgOfScores as (select pk_fk_usr_id, ROUND(avg(score),1) as [avg]
		from TB_STORE_ITEM_OPINIONPOLL_OPINIONS
		group by pk_fk_usr_id,fk_opinionPollId)

		select
		u.id as userId,
		u.fname + ' ' + u.lname as [name],
		cm.comment,
		round(avgOfScores.avg,1) as avgOfScores,
		dbo.func_getDateByLanguage(@clientLanguage,cm.saveDateTime,1) as [time],
		cm.edited,
		d1.id as d1,
		d1.thumbcompeleteLink as p1_thumbcompeleteLink,
		d1.completeLink as p1_completeLink,
		d2.id as d2,
		d2.thumbcompeleteLink as p2_thumbcompeleteLink,
		d2.completeLink as p2_completeLink,
		d3.id as d3,
		d3.thumbcompeleteLink as p3_thumbcompeleteLink,
		d3.completeLink as p3_completeLink,
		d4.id as d4,
		d4.thumbcompeleteLink as p4_thumbcompeleteLink,
		d4.completeLink as p4_completeLink,
		d5.id as d5,
		d5.thumbcompeleteLink as p5_thumbcompeleteLink,
		d5.completeLink as p5_completeLink
		from TB_STORE_ITEM_OPINIONPOLL_COMMENTS as cm with(nolock)
		join TB_USR as u with(nolock) on cm.fk_usr_commentUserId = u.id
		left join TB_DOCUMENT as d1 with(nolock) on cm.fk_document_doc1 = d1.id
		left join TB_DOCUMENT as d2 with(nolock) on cm.fk_document_doc2 = d2.id
		left join TB_DOCUMENT as d3 with(nolock) on cm.fk_document_doc3 = d3.id
		left join TB_DOCUMENT as d4 with(nolock) on cm.fk_document_doc4 = d4.id
		left join TB_DOCUMENT as d5 with(nolock) on cm.fk_document_doc5 = d5.id
		left join avgOfScores on cm.fk_usr_commentUserId = avgOfScores.pk_fk_usr_id
		where cm.fk_opinionpoll_id = @opinionPollId and @appId = 2 and cm.fk_usr_commentUserId = @userId;

	    select count(1) as commentCount from TB_STORE_ITEM_OPINIONPOLL_COMMENTS with(nolock) where fk_opinionpoll_id = @opinionPollId;

	end





RETURN 0