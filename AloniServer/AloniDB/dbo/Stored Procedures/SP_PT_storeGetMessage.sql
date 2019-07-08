CREATE PROCEDURE [dbo].[SP_PT_storeGetMessage]
	@clientLanguage as char(2) = null,
	@appId as tinyint = null,
	@clientIp as varchar(50) = null,
	@pageNo as int = 0,
	@search as nvarchar(100) = null,
	@parent as varchar(20)  = null,
	@userId as bigint = null,
	@targetStoreId as bigint   
AS
	set nocount on

	--SELECT	 [id]
	--	,[message]
		
	--	,[fk_usr_senderUser]
	--	,[dbo].[func_getUserDesc] ([fk_usr_senderUser]) fk_usr_senderUserDesc
	--	,[fk_staff_senderStaffId]
	--	,[dbo].[func_getStaffDesc] ([fk_staff_senderStaffId],default) fk_staff_senderStaffDesc

	--	,[fk_usr_destUserId]
	--	,[dbo].[func_getUserDesc] ([fk_usr_destUserId]) fk_usr_destUserDesc
	--	,[fk_staff_destStaffId]
	--	,[dbo].[func_getStaffDesc] ([fk_staff_destStaffId],default) fk_staff_destStaffDesc
		
	--	,[saveDateTime]
	--	,[seenDateTime]
	--	,[deleted]
		
	--  , case
	--	when fk_store_senderStoreId is null
	--	then 1 
	--	else 0
	--	end as sendFromPortal
 -- FROM [dbo].[TB_MESSAGE]
 -- where  ( fk_store_destStoreId = @targetStoreId or fk_store_senderStoreId = @targetStoreId )
 -- and (fk_staff_destStaffId in (33 , 32 , 31 ) or fk_staff_senderStaffId in (33 , 32 , 31 ) )
 -- order by id desc
 -- OFFSET (@pageNo * 20 ) ROWS
 -- FETCH NEXT 20 ROWS ONLY;

 select 
		 m.id as [id]
		 ,m.fk_conversation_id as convId
		,[message]
		,[fk_usr_senderUser]
		,[dbo].[func_getUserDesc] ([fk_usr_senderUser]) fk_usr_senderUserDesc
		,[fk_staff_senderStaffId]
		,[dbo].[func_getStaffDesc] ([fk_staff_senderStaffId],default) fk_staff_senderStaffDesc
		,[fk_usr_destUserId]
		,[dbo].[func_getUserDesc] ([fk_usr_destUserId]) fk_usr_destUserDesc
		,[fk_staff_destStaffId]
		,[dbo].[func_getStaffDesc] ([fk_staff_destStaffId],default) fk_staff_destStaffDesc	
		,m.saveDateTime as [saveDateTime]
		,[seenDateTime]
		,[deleted]	
	    ,case
		when fk_usr_senderUser = @userId
		then 1 
		else 0
		end as sendFromPortal
		from 
			TB_MESSAGE m inner join tb_conversation C on m.fk_conversation_id = c.id
			--left join TB_USR U on m.fk_usr_senderUser = u.id
			--left join TB_USR U1 on m.fk_usr_destUserId = u1.id
			left join TB_STORE s on m.fk_store_senderStoreId = s.id
			left join TB_STORE s1 on m.fk_store_destStoreId = s1.id
			where (s.id = @targetStoreId or s1.id = @targetStoreId) and (m.fk_usr_senderUser in (select fk_usr_id from TB_USR_STAFF 
			where fk_staff_id in (select id from TB_STAFF where fk_app_id in (0,3))) or m.fk_usr_destUserId in (select fk_usr_id from TB_USR_STAFF 
			where fk_staff_id in (select id from TB_STAFF where fk_app_id in (0,3))))
			order by m.saveDateTime




RETURN 0
