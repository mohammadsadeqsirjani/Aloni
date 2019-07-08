create PROCEDURE [dbo].[SP_order_getChangeHistory]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100) = null,
	@parent as varchar(20),
	@orderId as bigint,
	@userId as bigint,
	@storeId as bigint
	
AS
	set nocount on
	
	SELECT 
	     h.fk_docType_id,
		 isnull(u.fname,'') + ISNULL(u.lname,'') as userName,
		 isnull(ISNULL(strn.title,s.title),'نامشخص') as userStaff,
		 ISNULL(tdtt.title,tdt.title) as actionType_dsc,
		 dbo.func_calcActionOrderTime(@clientLanguage,h.saveDateTime) as changeDateTime_dsc,
		 h.saveDateTime as changeDateTime,
		 case when h.fk_docType_id in (15) then '' else '' end as changeDtls
	from 
	    TB_ORDER as o
		join
		TB_ORDER_HDR as h on o.id = h.fk_order_orderId
		inner join TB_TYP_ORDER_DOC_TYPE tdt on h.fk_docType_id = tdt.id
		inner join TB_USR_SESSION us on h.fk_usrSession_id = us.id
		inner join TB_USR u on us.fk_usr_id = u.id
		--left join TB_USR_STAFF ust on u.id = ust.fk_usr_id and ust.fk_store_id = o.fk_store_storeId
		left join TB_STAFF s on h.fk_staff_operatorStaffId = s.id
		left join TB_TYP_ORDER_DOC_TYPE_TRANSLATIONS as tdtt on tdt.id = tdtt.id and tdtt.lan = @clientLanguage
		left join TB_STAFF_TRANSLATIONS strn on s.id = strn.id and strn.lan = @clientLanguage
	where 
		o.id = @orderId
		and
		h.isVoid = 0
		and
		((@appId = 1 and o.fk_store_storeId = @storeId) or (@appId = 2 and o.fk_usr_customerId = @userId) or (@appId = 3))
	order by h.saveDateTime

RETURN 0
