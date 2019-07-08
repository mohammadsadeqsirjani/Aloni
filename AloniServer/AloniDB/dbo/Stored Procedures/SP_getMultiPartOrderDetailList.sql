CREATE PROCEDURE [dbo].[SP_getMultiPartOrderDetailList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20),
	@userId as bigint,
	@orderId as bigint,
	@itemId as bigint
AS
	
			SELECT 
				OH.id,DBO.func_getDateByLanguage(@clientLanguage,OH.saveDateTime,1) DATE,STA.id statusId,ISNULL(STAR.title,STA.title) status_dsc,oh.saveDateTime
			FROM
				TB_ORDER OH
				INNER JOIN TB_STORE S ON OH.fk_store_storeId = S.id
				INNER JOIN TB_STATUS as STA ON STA.id = [dbo].[func_getOrderStatus](OH.id,OH.fk_status_statusId,OH.lastDeliveryDateTime)
				LEFT JOIN TB_STATUS_TRANSLATIONS as STAR ON STA.id = STAR.id AND STAR.lan = @clientLanguage
			WHERE
				OH.id = @orderId
		
		
		--SELECT 
		--	i.id,i.title,od.delivered,OD.cstmrAcknowledgmentOnDelivery
		--FROM
		--	TB_ORDER_HDR OH 
		--	INNER JOIN TB_ORDER_DTL OD ON OH.id = OD.fk_orderHdr_id
		--	INNER JOIN TB_ITEM I ON OD.fk_item_id = I.id
		--	LEFT JOIN  TB_DOCUMENT_ITEM DI ON OD.fk_item_id = DI.pk_fk_item_id
		--	LEFT JOIN TB_DOCUMENT D ON DI.pk_fk_document_id = D.id AND fk_documentType_id = 2
		--	LEFT JOIN TB_COLOR C ON OD.vfk_store_item_color_id = C.ID
		--	LEFT JOIN TB_COLOR_TRANSLATIONS CR ON C.id = CR.id AND lan = @clientLanguage
			
		--WHERE
		--	OD.fk_orderHdr_id = @orderId and OD.fk_item_id = @itemId
RETURN 0
