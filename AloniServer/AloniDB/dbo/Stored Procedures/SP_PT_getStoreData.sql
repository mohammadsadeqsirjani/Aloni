-- =============================================
-- Author:		saeed m khorsand
-- Create date: 1396 10 03
-- Description:	return 4 table of store data
-- =============================================
CREATE PROCEDURE [dbo].[SP_PT_getStoreData]
	@clientLanguage as char(2) = null,
	@appId as tinyint = null,
	@clientIp as varchar(50) = null,
	@storeId as bigint
AS
BEGIN
	SET NOCOUNT ON;

	-- اطلاعات اولیه فروشگاه
select S.id , S.title , S.title_second , S.description , S.email  , S.address ,
	S.address_full  , s.keyWords , S.fk_store_category_id, SCT.title as category_title 
	, S.fk_store_type_id, STYP.title as fk_store_type_title 
	, S.fk_country_id , CO.title fk_country_title , S.fk_city_id  , CT.title fk_city_title
	, ST.Id fk_state_id , ST.title fk_state_title , S.fk_status_id , S.location.Lat as lat , S.location.Long as lon
	, S.fk_storePersonalityType_id, spt.title AS fk_storePersonalityType_Dsc,ordersNeedConfimBeforePayment,customerJoinNeedsConfirm
	,onlyCustomersAreAbleToSeeItems,onlyCustomersAreAbleToSetOrder,accessLevel
	from TB_STORE S WITH (NOLOCK)
	left join TB_TYP_STORE_TYPE_TRANSLATIONS STYP WITH (NOLOCK)
		on S.fk_store_type_id = STYP.id and STYP.lan = 'fa'
	left join TB_TYP_STORE_CATEGORY SCT WITH (NOLOCK)
		on S.fk_store_category_id = SCT.id --and SCT.lan = 'fa'
	left join TB_COUNTRY CO
		on S.fk_country_id = CO.id
	left join TB_CITY CT
		on S.fk_city_id = CT.id
	left join TB_STATE ST
		on CT.fk_state_id = ST.Id
	left join TB_TYP_STORE_PERSONALITY_TYPE AS spt
	    on S.fk_storePersonalityType_id = spt.id
		where S.id = @storeId

		-- اطلاعات گروه
		select sip.pk_fk_itemGrp_id AS id, igt.title from TB_STORE_ITEMGRP_PANEL_CATEGORY AS sip
		left join TB_TYP_ITEM_GRP AS igt ON sip.pk_fk_itemGrp_id = igt.id
		where sip.pk_fk_store_id = @storeId

		-- لگو فروشگاه
	select ISNULL(logo.thumbcompeleteLink, '/alonitest/Files/defult_thumbil.png') AS thumbcompeleteLink, 
	ISNULL(logo.completeLink, '/alonitest/Files/defult.png') As completeLink  from TB_DOCUMENT_STORE AS logoStore
	inner join TB_DOCUMENT As logo
	   on logoStore.pk_fk_document_id = logo.id AND logo.fk_documentType_id = 5 
    where logoStore.pk_fk_store_id = @storeId AND logoStore.isDefault = 1


	-- حوزه های فعالیت فروشگاه
	select ST_EX.pk_fk_expertise_id id ,TSET.title from TB_STORE_EXPERTISE ST_EX
	inner join TB_TYP_STORE_EXPERTISE_TRANSLATIONS TSET
	on ST_EX.pk_fk_expertise_id = TSET.id
	where ST_EX.pk_fk_store_id = @storeId


	-- لیست مجوز و تصاویر فروشگاه
	select
	D.id AS id,
	D.caption AS caption,
	D.description AS [description],
	D.completeLink AS downloadLink,
	D.fileName AS [file_Name],
	DS.isDefault AS isDefault,
	D.fk_documentType_id AS fk_documentType_id
	from TB_DOCUMENT_STORE DS WITH (NOLOCK)
	inner join TB_DOCUMENT D WITH (NOLOCK)
		on DS.pk_fk_document_id  = D.id
	inner join TB_TYP_DOCUMENT_TYPE_TRANSLATIONS TDTT WITH (NOLOCK)
		on D.fk_documentType_id = TDTT.id and TDTT.lan = 'fa' and D.fk_documentType_id in ( 1 , 3 )
	where DS.pk_fk_store_id = @storeId AND D.isDeleted = 0

	-- تلفن
	select 
	id ,
	case 
		when isDefault = 1 then phone + '(پیشفرض)'
		else phone
	end as phone
	 from TB_STORE_PHONE
	where fk_store_id = @storeId and isActive = 1

	-- لیست گروه کالاهای مرجع قابل ویرایش  فروشگاه
	select iGrp.id,grp.FullPath from TB_STORE AS s
    join TB_STORE_ITEMGRP_ACCESSLEVEL AS sia ON sia.fk_store_id = s.id 
	left join TB_TYP_ITEM_GRP AS iGrp ON iGrp.id = sia.fk_itemGrp_id AND iGrp.type = 1
	left join dbo.vw_itemGrp_fullPath AS grp ON grp.id = iGrp.id
	where sia.fk_store_id = @storeId


	--select SEX.pk_fk_expertise_id id , TY_EX_T.title from TB_STORE_EXPERTISE SEX
	--inner join TB_TYP_STORE_EXPERTISE_TRANSLATIONS TY_EX_T
	--on SEX.pk_fk_expertise_id = TY_EX_T.id and TY_EX_T.lan = 'fa'
	--where SEX.pk_fk_store_id = @storeId
    --select * from TB_TYP_STORE_EXPERTISE_TRANSLATIONS
END