CREATE PROCEDURE [dbo].[SP_getBasicPanelSettings]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = null,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@userId as bigint,
	@storeId as bigint
AS	
	SET NOCOUNT ON
	DECLARE @storeAccessLevel AS TINYINT
	SELECT @storeAccessLevel = accessLevel FROM TB_STORE WHERE id = @storeId
	-- STORE LOGO
	SELECT
		 doc.id, 
		 doc.completeLink as ImageUrl,
		 doc.thumbcompeleteLink thumbImageUrl, 
		 isDefault,
		 fk_documentType_id
		 
	FROM
		 TB_DOCUMENT as doc with (nolock) 
		 INNER JOIN
		 TB_DOCUMENT_STORE as s with (nolock) 
		 ON doc.id = s.pk_fk_document_id
	WHERE 
		 s.pk_fk_store_id = @storeId 
		 AND 
		 doc.isDeleted <> 1 
		 AND
		 isDefault = 1 
		 AND
		 fk_documentType_id = 5 
	-- STORE INFO
	SELECT
		S.id,
		S.title,
		ISNULL(CCR.title,CC.title) crTITLE,
		@storeAccessLevel accessLevel,
		shiftStartTime,
		shiftEndTime,
		isnull(canBeSalesNegative,0) canSalesNegativeQty,
		itemEvaluationNeedConfirm,
		itemEvaluationShowName,
		(taxRate * 100) taxRate,
		calculateTax,
		taxIncludedInPrices,
		rialCurencyUnit,
		cast((case when fk_status_shiftStatus = 18 then 1 else 0 END) as bit) storeIsClose,
		ISNULL(s.autoSyncTimePeriod,0) autoSyncTimePeriod,
		ISNULL(s.reducedQtyPercent,0) reducedQtyPercent
	FROM
		TB_STORE S 
		INNER JOIN
		TB_COUNTRY C
		ON C.id = S.fk_country_id
		INNER JOIN 
		TB_CURRENCY CC
		ON C.fk_currency_id = CC.id
		LEFT JOIN
		TB_CURRENCY_TRANSLATIONS CCR 
		ON	CC.id = CCR.id AND CCR.lan = @clientLanguage
	WHERE
		S.id = @storeId
	-- STORE ACCESS LEVEL
	--IF(@storeAccessLevel = 2)
	--BEGIN
		SELECT 
			fk_itemGrp_id id
		FROM
			TB_STORE_ITEMGRP_ACCESSLEVEL 
		WHERE
			fk_store_id = @storeId
	--END
	--ELSE
	--	SELECT 0 as id
	--USER ACCESS LEVEL
	SELECT
		AP.id,
		AP.description,
		AP.area,
		APU.hasAccess	
	FROM
		TB_APP_FUNC AP
		INNER JOIN
		TB_APP_FUNC_USR APU
		ON AP.id = APU.fk_func_id 
	WHERE
		AP.fk_app_id = 1
		AND
		DBO.func_GetUserStaffStore(@userId,@storeId) = APU.fk_staff_id

		--Promotion
	SELECT
		id,
		fk_store_id,
		(promotionPercent * 100) promotionPercent,
		promotionDsc,
		isActive
	FROM
		TB_STORE_PROMOTION
	WHERE 
		--isActive = 1
		--AND
		fk_store_id = @storeId

	-- terms and conditions
	SELECT 
		 tc.pk_version newTC_termsAndConditions
		,isnull(tc_trn.title,tc.title) newTC_title
		,ISNULL(tc_trn.[description],tc.[description]) newTC_description
		,dbo.func_getDateByLanguage(@clientLanguage,tc.saveDateTime,1) newTC_saveDateTime_dsc
	FROM
		 TB_TERMS_AND_CONDITIONS as tc with(nolock)
		 left join TB_TERMS_AND_CONDITIONS_TRANSLATIONS as tc_trn with(nolock) on tc.pk_fk_app_id = tc_trn.pk_fk_app_id and tc.pk_version = tc_trn.pk_version and tc_trn.pk_lan = @clientLanguage
	WHERE
		 tc.pk_fk_app_id = 1 
		 AND
		 tc.isActive = 1
		 AND 
		 tc.pk_version > isnull((select max(us.pk_fk_version)
									 from TB_TERMS_AND_CONDITIONS_ACCEPT as us with(nolock)
									   where us.fk_store_id = @storeId and us.pk_fk_app_id = @appId),0)
		 AND 
		   dbo.func_GetUserStaffStore(@userId,@storeId) = 11
		order by tc.pk_version desc;
RETURN 0
