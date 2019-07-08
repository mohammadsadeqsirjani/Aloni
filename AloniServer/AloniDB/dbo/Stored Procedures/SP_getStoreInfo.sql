CREATE PROCEDURE [dbo].[SP_getStoreInfo]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100)=null,
	@parent as varchar(20) = null ,
	@userId as bigint,
	@storeId as bigint,
	@msg as nvarchar(100) out,
	@rCode as smallint out
AS
	set nocount on;

	set @rCode = 1;
	if(@appId = 2)
	begin
		if((select fk_store_type_id from TB_STORE where id = @storeId) = 2) -- private store
		begin
			if((select count(id) from TB_USR_STAFF where fk_store_id = @storeId and fk_usr_id = @userId) = 0)
			begin
				
				set @msg = dbo.func_getSysMsg('not access',OBJECT_NAME(@@PROCID),@clientLanguage, 'store is private!')
				--باید فقط فیلدهای عمومی نمایش داده شود
			end
		end
	end


;with scheduleInfo as (select * from TB_STORE_SCHEDULE with(nolock) where fk_store_id = @storeId)

	select top 1
		st.id,
		st.title,
		st.fk_status_id,
		isnull(stat.title,sta.title) statusTitle, 
		fk_store_type_id,
		isnull(stypr.title,styp.title) storeTypTitle, 
		fk_store_category_id,
		ctyp.title categoryTitle,
		st.[description],
		description_second,
		title_second,
		[location].Lat lat,
		[location].Long lng, 
		st.email,
		[address],
		address_full,
		fk_city_id,
		c.title cityTitle,
		st.fk_country_id,
		cu.title countryTitle,
		verifiedAsOriginal,
		st.shiftStartTime,
		shiftEndTime,
		fk_status_shiftStatus,
		isnull(isnull(stat1.title,sta1.title),'برنامه زمانبندی نامشخص') fk_status_shiftStatus_dsc, 
		keyWords,
		st.id_str,
		case when score = 0 then 5 else score end score,
		ordersNeedConfimBeforePayment,
		onlyCustomersAreAbleToSeeItems,
		onlyCustomersAreAbleToSetOrder,
		customerJoinNeedsConfirm,
		taxRate,
		taxIncludedInPrices,
		calculateTax,
		canOrderWhenClose,
		st.account,
		SC.notification,
		U.mobile,
		st.second_lan_title,
		st.second_lan_about,
		st.second_lan_manager,
		st.second_lan_address,
		SC.notification,
		st.fk_storePersonalityType_id as storePersonalityType,
		ISNULL(spt_trn.title,spt.title) as storePersonalityType_dsc,
		case when exists(select 1 from scheduleInfo as sch ) then 1 else 0 end as hasSchedule
		,substring(
						(select 
						'-' +'از ' + substring(cast(isActiveFrom as varchar(7)),0,6) + ' تا ' + substring(CAST(activeUntil as varchar(7)),0,6) as [text()]
						 from scheduleInfo --TB_STORE_ITEM_SCHEDULE with(nolock)
						where
						-- fk_store_id = 9
						--and fk_item_id = 22217 and
						 onDayOfWeek = case when DATEPART(dw,getdate())  = 7 then 0 else DATEPART(dw,getdate()) end
						for xml path (''))
						,2,2147483647 ) as todaySchedule

		,case when st.fk_status_shiftStatus = 17 then 1 when st.fk_status_shiftStatus = 18 then 0 when
		 exists(select 1 from scheduleInfo where onDayOfWeek = 
		 case when DATEPART(dw,getdate()) = 7 then 0 else DATEPART(dw,getdate()) end
		 and cast(GETDATE() as time(0)) >= isActiveFrom and cast(GETDATE() as time(0)) < activeUntil )
		 then 1 else 0 end as currentShiftStatus,
		 t.id stateId,
		 t.title stateTitle,
		 SAB.[description] storeAbout,
		 case when sr.id is null then 0 else 1 end as reportedByCaller
	from 
		 TB_STORE st
		 left join TB_STATUS sta on st.fk_status_id = sta.id
		 left join TB_STATUS_TRANSLATIONS stat on sta.id = stat.id and stat.lan = @clientLanguage
		 left join TB_STATUS sta1 on st.fk_status_shiftStatus = sta1.id
		 left join TB_STATUS_TRANSLATIONS stat1 on sta1.id = stat1.id and stat1.lan = @clientLanguage
		 left join TB_TYP_STORE_TYPE styp on st.fk_store_type_id = styp.id
		 left join TB_TYP_STORE_TYPE_TRANSLATIONS stypr on styp.id = stypr.id and stypr.lan = @clientLanguage
		 left join TB_TYP_STORE_CATEGORY ctyp on st.fk_store_category_id = ctyp.id
		 left join TB_CITY c on st.fk_city_id = c.id
		 left join TB_STATE t on c.fk_state_id = t.id
		 left join TB_COUNTRY cu on st.fk_country_id = cu.id
		 left join TB_STORE_CUSTOMER SC on sc.pk_fk_store_id = st.id and sc.pk_fk_usr_cstmrId = @userId
		 left join TB_USR_STAFF STF on STF.fk_store_id = st.id and STF.fk_staff_id = 11 
		 left join TB_USR U on STF.fk_usr_id = u.id
		 left join TB_TYP_STORE_PERSONALITY_TYPE as spt on st.fk_storePersonalityType_id = spt.id
		 left join TB_TYP_STORE_PERSONALITY_TYPE_TRANSLATIONS as spt_trn on st.fk_storePersonalityType_id = spt_trn.id and spt_trn.lan = @clientLanguage
		 left join TB_STORE_ABOUT SAB on st.id = SAB.fk_store_id and SAB.fk_language_id = @clientLanguage
		 left join TB_STORE_REPORT as sr on st.id = sr.fk_store_id and sr.fk_usr_id = @userId
	where
	 st.id = @storeId 

	select pk_fk_expertise_id,tes.title from TB_STORE_EXPERTISE s inner join TB_TYP_STORE_EXPERTISE tes on s.pk_fk_expertise_id = tes.id where pk_fk_store_id = @storeId

	select phone,isDefault from TB_STORE_PHONE where fk_store_id = @storeId and isActive = 1

	select 
		s.fk_bank_id,b.title bankName,ISNULL(star.title,st.title) statusTitle,s.fk_OnlinePayment_StatusId statusId
	from
		TB_STORE s inner join TB_STATUS st on s.fk_OnlinePayment_StatusId = st.id
		left join TB_STATUS_TRANSLATIONS star on st.id = star.id and lan = @clientLanguage
		left join TB_BANK b on s.fk_bank_id = b.id
	where s.id = @storeId

	select 
		ISNULL(star.title,st.title) statusTitle,s.fk_securePayment_StatusId statusId,case when exists(select top 1 pk_fk_item_id from TB_STORE_ITEM_QTY siq where pk_fk_store_id = @storeId and hasDelivery = 1 ) then 1 else 0 END hasDelivery
	from
		TB_STORE s inner join TB_STATUS st on s.fk_securePayment_StatusId = st.id
		left join TB_STATUS_TRANSLATIONS star on st.id = star.id and lan = @clientLanguage
		
	where s.id = @storeId

	select case when COUNT(pk_fk_usr_cstmrId) > 1000 then cast((COUNT(pk_fk_usr_cstmrId) / 1000) as varchar(10)) + ' K' else cast(COUNT(pk_fk_usr_cstmrId) as varchar(10)) end followersCount from TB_STORE_CUSTOMER where pk_fk_store_id = @storeId
	
	select socialNetworkType,socialNetworkAccount from TB_STORE_SOCIALNETWORK where fk_store_id = @storeId

	select distinct
		TYG.id,tyg.title,d.completeLink,d.thumbcompeleteLink
	from 
		TB_STORE S 
		inner join TB_STORE_ITEM_QTY SIQ on s.id = SIQ.pk_fk_store_id
		inner join TB_ITEM I on SIQ.pk_fk_item_id = i.id 
		inner join TB_TYP_ITEM_GRP TYG on i.fk_itemGrp_id = TYG.id
		left join TB_DOCUMENT D on TYG.fk_document_id = d.id
	where 
		s.id = @storeId and SIQ.fk_status_id = 15 and TYG.fk_item_grp_ref is null

	select dbo.func_getActiveStoreTimeDay(@clientLanguage,@storeId) storeActiveTime

	select 
		c.id,c.title,c.dsc,ISNULL(SR.title,ST.title) status_,st.id statusId
	from 
		TB_STORE S
		inner join TB_STORE_CERTIFICATE C on s.id = c.fk_store_id
		left join TB_STATUS ST on c.fk_status_id = ST.id
		left join TB_STATUS_TRANSLATIONS SR on ST.id = SR.id and SR.lan = @clientLanguage
	where 
		s.id =  @storeId
	
	select 
		c.id,d.id guid_,d.thumbcompeleteLink,d.completeLink
	from 
		TB_STORE S
		inner join TB_STORE_CERTIFICATE C on s.id = c.fk_store_id
		inner join TB_DOCUMENT_STORE_CERTIFICATE DS on c.id = DS.pk_fk_store_certificate_id
		inner join TB_DOCUMENT D on ds.pk_fk_document_id = D.id
	where 
		s.id = @storeId;

		select case when  fk_status_id in (32,44) then fk_status_id else null end as cstmrJoinStatus,
		 case when  fk_status_id in (32,44) then isnull(stt.title,st.title)  else null end as cstmrJoinStatus_dsc
	    from TB_STORE_CUSTOMER as sc with(nolock)
		join TB_STATUS as st on sc.fk_status_id = st.id
		left join TB_STATUS_TRANSLATIONS as stt on st.id = stt.id and stt.lan = @clientLanguage
		where pk_fk_store_id = @storeId and pk_fk_usr_cstmrId = @userId ;

	
	select 
		d.id,d.thumbcompeleteLink,d.completeLink,ds.isDefault
	from 
		TB_STORE S
		inner join TB_DOCUMENT_STORE DS on s.id = DS.pk_fk_store_id
		inner join TB_DOCUMENT D on ds.pk_fk_document_id = D.id
	where 
		s.id = @storeId
		and
		d.fk_documentType_id <> 5
		and
		d.isDeleted <> 1
	order by DS.isDefault desc

	select 
	ST.id onlineGetway_id,
	ISNULL(STRR.title,ST.title) onlineGetway_dsc,
	ST1.id securePayment_id,
	isnull(STRR1.title,ST1.title) securePayment_dsc
	from TB_STORE S 
	left join TB_STATUS ST on S.fk_OnlinePayment_StatusId = ST.id
	left join TB_STATUS_TRANSLATIONS STRR on ST.id = STRR.id
	left join TB_STATUS ST1 on S.fk_securePayment_StatusId = ST1.id
	left join TB_STATUS_TRANSLATIONS STRR1 on ST1.id = STRR1.id
	where s.id = @storeId
	
	select 
		c.*,
		d.thumbcompeleteLink,
		d.completeLink
	from 
		TB_STORE_CUSTOM_CATEGORY C 
		left join TB_DOCUMENT D on C.fk_document_id = D.id
	where 
		c.fk_store_id = @storeId
	
	select 
		c.id,
		i.id itemId,
		i.title itemTitle
	from 
		TB_STORE_CUSTOM_CATEGORY C
		inner join TB_STORE_CUSTOMCATEGORY_ITEM CI on c.id = CI.pk_fk_custom_category_id
		inner join TB_ITEM I on CI.pk_fk_item_id = i.id
	where 
		c.fk_store_id = @storeId
		AND
		c.isActive <> 0

	select doc.id, doc.completeLink as ImageUrl,doc.thumbcompeleteLink thumbImageUrl, isDefault,fk_documentType_id from TB_DOCUMENT as doc with (nolock) inner join TB_DOCUMENT_STORE as s with (nolock) on doc.id = s.pk_fk_document_id
			where s.pk_fk_store_id = @storeId and doc.isDeleted <> 1 and isDefault = 1 and  (caption like '%'+@search+'%' or @search is null) and fk_documentType_id = 5 
	
	select id from TB_CONVERSATION where (fk_from = @userId and fk_to = @storeId) or (fk_to = @userId and fk_from = @storeId)

	select sp.pk_fk_itemGrp_id as id,ISNULL(ig_trn.title,ig.title) as title
	 from TB_STORE_ITEMGRP_PANEL_CATEGORY as sp
	 join TB_TYP_ITEM_GRP as ig on sp.pk_fk_itemGrp_id = ig.id
	 left join TB_TYP_ITEM_GRP_TRANSLATIONS as ig_trn on sp.pk_fk_itemGrp_id = ig_trn.id and ig_trn.lan = @clientLanguage
	 where sp.pk_fk_store_id = @storeId;


	--select ss.pk_fk_itemGrp_id as id,ISNULL(ig_trn.title,ig.title) as title
	-- from TB_STORE_ITEMGRP_ITEMGRP_AND_SERVICES as ss
	-- join TB_TYP_ITEM_GRP as ig on ss.pk_fk_itemGrp_id = ig.id
	-- left join TB_TYP_ITEM_GRP_TRANSLATIONS as ig_trn on ss.pk_fk_itemGrp_id = ig_trn.id and ig_trn.lan = @clientLanguage
	-- where ss.pk_fk_store_id = @storeId;
	
	select id,title,[type] from [dbo].[TB_STORE_CUSTOM_CATEGORY] where fk_store_id = @storeId
	union  select  -1,'همه',1
	union  select  -2,'تخفیف ها',1
	union  select  -3,'جدیدترین ها',1
	union  select  -4,'ویترین',1
	union  select  -1,'همه',0
	union  select  -4,'شاخص',0 
	 
	select 
		SV.id,
		SV.title,
		SV.fk_item_id,
		SV.fk_itemGrp_id,
		SV.[type],
		case when d.thumbcompeleteLink is not null then d.thumbcompeleteLink when d2.thumbcompeleteLink is not null then d2.thumbcompeleteLink when d3.thumbcompeleteLink is not null then d3.thumbcompeleteLink end thumbcompeleteLink
	from
	TB_STORE_VITRIN SV
	left join TB_DOCUMENT_STORE_VITRIN DST on DST.pk_fk_vitrin_id = SV.id and DST.isPrime = 1
	left join TB_DOCUMENT D on DST.pk_fk_document_id = d.id

	left join tb_document_item di on sv.fk_item_id = di.pk_fk_item_id and di.isDefault = 1
	left join TB_DOCUMENT d2 on di.pk_fk_document_id = d2.id
	left join TB_TYP_ITEM_GRP as ig on sv.fk_itemGrp_id = ig.id
	left join TB_DOCUMENT as d3 on  ig.fk_document_id = d3.id
	where 
		SV.fk_store_id = @storeId
		and
		SV.isDeleted = 0
RETURN 0
