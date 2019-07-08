CREATE PROCEDURE [dbo].[SP_getUserAccessByStoreId]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint
AS
set nocount on
select  
ap.fk_func_id,ap.fk_usr_id,ap.fk_staff_id,ap.fk_store_id,ap.hasAccess
from 
TB_USR_STAFF us with(nolock) inner join TB_STAFF s with(nolock) on s.id = us.fk_staff_id 
inner join TB_APP_FUNC_USR ap with(nolock) on ap.fk_staff_id = s.id
where ap.fk_store_id = @storeId and us.fk_usr_id = @userId 
RETURN 0
