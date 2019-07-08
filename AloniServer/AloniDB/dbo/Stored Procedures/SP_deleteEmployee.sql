CREATE PROCEDURE [dbo].[SP_deleteEmployee]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@id as bigint 
AS
	--if((select fk_staff_id from TB_USR_STAFF where fk_store_id = @storeId and fk_usr_id = @userId) <> 11 )
	--begin
	--	set @rCode = 0
	--	set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@PROCID),@clientLanguage,'you are not have permission for this action!'); 
	--	return
	--end
	
	begin try
		delete from TB_STORE_EMPLOYEE where id= @id
		set @rCode = 1
		set @rMsg = 'success'
	end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,ERROR_MESSAGE())
	end catch
RETURN 0