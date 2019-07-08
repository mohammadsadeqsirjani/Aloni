CREATE PROCEDURE [dbo].[SP_getCustomerByPhone]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@phone as varchar(50),
	@storeId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out
	
AS
	SET NOCOUNT ON
	if(dbo.func_GetUserStaffStore(@userId,@storeId) <> 11)
	begin
		set @rCode = 0 
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@procId),@clientLanguage,'access denied')
		return
	end	
	if(not exists(select mobile from TB_USR where mobile = @phone))
	begin
		set @rCode = 1 
		set @rMsg = dbo.func_getSysMsg('result',OBJECT_NAME(@@procId),@clientLanguage,'phone number not exists')
		return
	end
	set @rCode = 3
	select
		 u.id,fname + ' '+ISNULL(lname,'') name,mobile,d.completeLink,d.thumbcompeleteLink
    from
		 TB_USR U
		 left join TB_DOCUMENT_USR DU on u.id = DU.pk_fk_usr_id
		 left join TB_DOCUMENT D on DU.pk_fk_document_id = d.id
	where
		 mobile = @phone
RETURN 0

