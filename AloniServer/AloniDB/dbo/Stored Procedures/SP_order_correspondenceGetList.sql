CREATE PROCEDURE [dbo].[SP_order_correspondenceGetList]
	 @clientLanguage AS CHAR(2)
	,@appId AS TINYINT
	,@clientIp AS VARCHAR(50)
	,@pageNo AS INT
	,@search AS NVARCHAR(100)
	,@parent AS VARCHAR(20)
	,@userId AS BIGINT
	,@storeId AS BIGINT
	,@isTicket as bit
	,@orderId AS bigint

AS
select 
 oc.id
,oc.fk_usr_senderUserId as senderUserId
,st.fk_app_id as senderAppId
,isnull(su.fname,'') + isnull(su.lname,'') as senderUserName
,case when @appId = 2 then 'customer' else ISNULL(st_trn.title,st.title) end as senderStaff_dsc
,oc.isTicket
,oc.[message]
,oc.saveDateTime
,dbo.func_getDateByLanguage(@clientLanguage, oc.saveDateTime, 1) as saveDateTime_dsc
,case when oc.fk_usr_senderUserId = @userId and ((isnull(oc.fk_staff_senderStaffId,21) = 21 and @appId = 2) or (oc.fk_staff_senderStaffId <> 21 and @appId <> 2))  then 1 else 0 end as callerIsOwner
,case when oc.fk_usr_senderUserId = o.fk_usr_customerId and isnull(oc.fk_staff_senderStaffId,21) = 21 then 1 else 0 end as cstmrIsOwner
,case when oc.controlDateTime is null then 0 else 1 end isSeen
from TB_ORDER_CORRESPONDENCE as oc with(nolock)
join TB_USR as su with(nolock) on oc.fk_usr_senderUserId = su.id
join TB_ORDER as o with(nolock) on oc.fk_order_orderId = o.id
--left join TB_USR_STAFF as us with(nolock)  on su.id = us.fk_usr_id and (@appId = 3 or us.fk_store_id = @storeId) and ((@appId = 1 and us.fk_status_id = 8) or (@appId = 3 and us.fk_status_id = 37))
left join TB_STAFF as st with(nolock) on oc.fk_staff_senderStaffId = st.id
left join TB_STAFF_TRANSLATIONS as st_trn with(nolock) on oc.fk_staff_senderStaffId = st_trn.id and st_trn.lan = @clientLanguage
where oc.fk_order_orderId = @orderId and oc.isDeleted = 0 and (@search is null or @search = '' or oc.message like '%' + @search + '%') and ((@appId = 1 and o.fk_store_storeId = @storeId and oc.isTicket = @isTicket) or (@appId = 3 and o.fk_store_storeId = @storeId and oc.isTicket = @isTicket) or (@appId = 2 and o.fk_usr_customerId = @userId and oc.isTicket = 1))
order by oc.saveDateTime desc
OFFSET (isnull(@pageNo,0) * 50 ) ROWS
FETCH NEXT case when @appId = 3 then 100000000 else 10 end ROWS ONLY;





--سین کردن تیکت های جدید در صورتی که کاربر فراخواننده مشتری است
update oc
set oc.controlDateTime = GETDATE()
from TB_ORDER_CORRESPONDENCE as oc
join TB_ORDER as o on oc.fk_order_orderId = o.id
where @appId = 2 and o.id = @orderId and @userId = o.fk_usr_customerId and oc.controlDateTime is null