CREATE PROCEDURE [dbo].[SP_getCustomerListOfStore]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20),
	@storeId as bigint,
	@rMsg as nvarchar(500) out,
	@status as smallint  
AS
	SET NOCOUNT ON
	if(dbo.func_GetUserStaffStore(@userId,@storeId) not in(11,12,13))
	begin
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,'شما مجاز به انجام این عملیات نمی باشید.')
		return
	end	
	if(@status = 1)
	begin
		select
			 u.id,fname + ' ' + isnull(lname,'') as name, mobile, d.completeLink, d.thumbcompeleteLink, SG.id as sgId, SG.title, SG.discountPercent
		from
			TB_STORE_CUSTOMER as SC
			inner join TB_USR as U on sc.pk_fk_usr_cstmrId = u.id
			left join TB_STORE_CUSTOMER_GROUP as SG on SC.fk_customerGroup_id = SG.id and SG.isActive = 1 and SG.fk_store_id = @storeId
			left join  TB_DOCUMENT_USR as DU on u.id = DU.pk_fk_usr_id 
			left join TB_DOCUMENT as D on DU.pk_fk_document_id = d.id
		where
			SC.pk_fk_store_id = @storeId and SC.fk_status_id = 32 and ( mobile like '%' + @search + '%' or @search is null or @search = '' or U.fname like '%' + @search + '%' or u.lname like '%' + @search + '%')
		order by u.id
		OFFSET (@pageNo * 10) ROWS
		FETCH NEXT 10 ROWS ONLY;

	end
	if(@status = 2)
	begin
		select
			 u.id,fname + ' ' + isnull(lname,'') as name, mobile, d.completeLink, d.thumbcompeleteLink, SG.id as sgId, SG.title, SG.discountPercent
		from
			TB_STORE_CUSTOMER as SC
			inner join TB_USR as U on sc.pk_fk_usr_cstmrId = u.id
			left join TB_STORE_CUSTOMER_GROUP as SG on SC.fk_customerGroup_id = SG.id and SG.isActive = 1 and SG.fk_store_id = @storeId
			left join TB_DOCUMENT_USR as DU on u.id = DU.pk_fk_usr_id 
			left join TB_DOCUMENT as D on DU.pk_fk_document_id = d.id
		where
			SC.pk_fk_store_id = @storeId and SC.fk_status_id = 33 and ( mobile like '%' + @search + '%' or @search is null or @search = '' or U.fname like '%' + @search + '%' or u.lname like '%' + @search + '%')
		order by u.id
		OFFSET (@pageNo * 10) ROWS
		FETCH NEXT 10 ROWS ONLY;
	end
	if(@status = 3)
	begin
		select
			 u.id,fname + ' ' + isnull(lname,'') as name, mobile, d.completeLink, d.thumbcompeleteLink, SG.id as sgId, SG.title, SG.discountPercent
		from
			TB_STORE_CUSTOMER as SC
			inner join TB_USR as U on sc.pk_fk_usr_cstmrId = u.id
			left join TB_STORE_CUSTOMER_GROUP as SG on SC.fk_customerGroup_id = SG.id and SG.isActive = 1 and SG.fk_store_id = @storeId
			left join TB_DOCUMENT_USR as DU on u.id = DU.pk_fk_usr_id 
			left join TB_DOCUMENT as D on DU.pk_fk_document_id = d.id
		
		where
			SC.pk_fk_store_id = @storeId and SC.fk_status_id = 34 and ( mobile like '%' + @search + '%' or @search is null or @search = '' or U.fname like '%' + @search + '%' or u.lname like '%' + @search + '%')
		order by u.id
		OFFSET (@pageNo * 10) ROWS
		FETCH NEXT 10 ROWS ONLY;
	end
	if(@status = 4)
	begin
		select
			 u.id,fname + ' ' + isnull(lname,'') as name, mobile, d.completeLink, d.thumbcompeleteLink, SG.id as sgId, SG.title, SG.discountPercent
		from
			TB_STORE_CUSTOMER as SC
			inner join TB_USR as U on sc.pk_fk_usr_cstmrId = u.id
			left join TB_STORE_CUSTOMER_GROUP as SG on SC.fk_customerGroup_id = SG.id and SG.isActive = 1 and SG.fk_store_id = @storeId
			left join TB_DOCUMENT_USR as DU on u.id = DU.pk_fk_usr_id 
			left join TB_DOCUMENT as D on DU.pk_fk_document_id = d.id
		where
			SC.pk_fk_store_id = @storeId and SC.fk_status_id = 44 and ( mobile like '%' + @search + '%' or @search is null or @search = '' or U.fname like '%' + @search + '%' or u.lname like '%' + @search + '%')
		order by u.id
		OFFSET (@pageNo * 10) ROWS
		FETCH NEXT 10 ROWS ONLY;
	end
	if(@status = 5)
	begin
		select
			 u.id,fname + ' ' + isnull(lname,'') as name,mobile,d.completeLink,d.thumbcompeleteLink,SG.id as sgId,SG.title,SG.discountPercent
		from
			TB_STORE_CUSTOMER as SC
			inner join TB_USR as U on sc.pk_fk_usr_cstmrId = u.id
			left join TB_STORE_CUSTOMER_GROUP as SG on SC.fk_customerGroup_id = SG.id and SG.isActive = 1 and SG.fk_store_id = @storeId
			left join TB_MESSAGE as M on (u.id = m.fk_usr_senderUser or u.id = m.fk_usr_destUserId) and (m.fk_store_senderStoreId = @storeId or m.fk_store_destStoreId = @storeId)
			left join TB_DOCUMENT_USR as DU on u.id = DU.pk_fk_usr_id 
			left join TB_DOCUMENT as D on DU.pk_fk_document_id = d.id
		where
			SC.pk_fk_store_id = @storeId and SC.fk_status_id = 32 and ( mobile like '%' + @search + '%' or @search is null or @search = '' or U.fname like '%' + @search + '%' or u.lname like '%' + @search + '%')
		order by u.id
		OFFSET (@pageNo * 10) ROWS
		FETCH NEXT 10 ROWS ONLY;
	end
RETURN 0
