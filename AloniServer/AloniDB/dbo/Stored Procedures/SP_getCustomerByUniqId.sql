CREATE PROCEDURE [dbo].[SP_getCustomerByUniqId]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@id_str as varchar(10),
	@storeId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out
	
AS
	if(dbo.func_GetUserStaffStore(@userId,@storeId) <> 11)
	begin
		set @rCode = 0 
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@procId),@clientLanguage,'access denied')
		return
	end	
	set @rCode = 1
	select u.id, fname + ' ' + isnull(lname,'') as name, mobile, d.completeLink, d.thumbcompeleteLink
    from 
		TB_USR as U 
		left join TB_DOCUMENT_USR as DU on u.id = DU.pk_fk_usr_id 
		left join TB_DOCUMENT as D on DU.pk_fk_document_id = d.id
	where id_str = @id_str
RETURN 0