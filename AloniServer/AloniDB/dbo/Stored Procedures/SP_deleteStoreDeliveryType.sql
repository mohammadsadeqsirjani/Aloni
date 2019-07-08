CREATE PROCEDURE [dbo].[SP_deleteStoreDeliveryType]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@id as bigint 
AS
	begin try
	update TB_STORE_DELIVERYTYPES set isDeleted = 1 where id = @id
	if(@@ROWCOUNT > 0)
	begin
		set @rCode = 1
		set @rMsg = 'success'
	end
	end try
	begin catch
	set @rCode = 0
	set @rMsg = ERROR_MESSAGE()
	end catch
RETURN 0