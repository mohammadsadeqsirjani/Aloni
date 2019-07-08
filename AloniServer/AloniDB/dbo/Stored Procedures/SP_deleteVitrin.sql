CREATE PROCEDURE [dbo].[SP_deleteVitrin]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@id as bigint 
AS
	if((select fk_store_id from TB_STORE_VITRIN where id = @id) <> @storeId)
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('invalid request',OBJECT_NAME(@@PROCID),@clientLanguage,'you have not permission!')
		return
	end
	update TB_STORE_VITRIN set isDeleted = 1 where id = @id
	set @rCode = 1
	set @rMsg = 'success'
		
RETURN 0