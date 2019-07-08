CREATE PROCEDURE [dbo].[SP_changeStoreType]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@fk_Store_type_Id as int,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint
AS
	begin try
		--declare @fk_Store_type_Id as int
		--select @fk_Store_type_Id = fk_store_type_id from TB_STORE where id = @storeId
		update TB_STORE set fk_store_type_id = @fk_Store_type_Id --case when @fk_Store_type_Id = 1 then 2  else 1 end
		  where id = @storeId
		set @rCode = 1
		set @rMsg = 'success'
	end try
	begin catch
		set @rCode = 0 
		set @rMsg = dbo.func_getSysMsg('Error',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
		return
	end catch

RETURN 0
