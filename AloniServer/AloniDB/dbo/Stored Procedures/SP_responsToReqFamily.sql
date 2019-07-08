CREATE PROCEDURE [dbo].[SP_responsToReqFamily]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@id as bigint,
	@accept as bit = 0,
	@deletion as bit = 0,
	@reqTitle as nvarchar(150) = NULL 
AS
	
	if(@deletion = 1)
	begin
	--if((select fk_usr_requester_usr_id from TB_USR_FAMILY where id = @id) <> @userId)
	--begin
	--	set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'You do not have permission to do so!'); 
	--	set @rCode = 0
	--	return 0
	--end
		if(not exists(select top 1 1 from TB_USR_FAMILY where id = @id))
		begin
			set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه معتبر نیست'); 
			set @rCode = 0
			return 0
		end
		update TB_USR_FAMILY set fk_status_id = 47,modifyDatetime = GETDATE() where id = @id
		set @rCode = 1
		set @rMsg =  dbo.func_getSysMsg('done',OBJECT_NAME(@@PROCID),@clientLanguage,'success!'); 
		return
	end
	if((select fk_usr_id from TB_USR_FAMILY where id = @id) <> @userId)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'شما مجاز به حذف نیستید'); 
		set @rCode = 0
		return 0
	end
	if(@reqTitle is null)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'عنوان نباید خالی باشد'); 
		set @rCode = 0
		return 0
	end
		update TB_USR_FAMILY set fk_status_id = case when @accept = 1 then 46 else 47 end,modifyDatetime = GETDATE(),reqTitle = @reqTitle where id = @id
		set @rCode = 1
		set @rMsg =  dbo.func_getSysMsg('done',OBJECT_NAME(@@PROCID),@clientLanguage,'success!'); 
RETURN 0