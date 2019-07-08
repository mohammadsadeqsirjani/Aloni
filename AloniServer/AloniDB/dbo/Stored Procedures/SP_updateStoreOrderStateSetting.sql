CREATE PROCEDURE [dbo].[SP_updateStoreOrderStateSetting]
	
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
    @canOrderWhenClose as bit
AS
	SET NOCOUNT ON
	BEGIN TRY
		UPDATE TB_STORE SET canOrderWhenClose = @canOrderWhenClose WHERE ID = @storeId
		set @rMsg = dbo.func_getSysMsg('done',OBJECT_NAME(@@PROCID),@clientLanguage,'success');
		SET @rCode = 1
	END TRY
	BEGIN CATCH
		set @rMsg = dbo.func_getSysMsg('ERRORE',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
		set @rCode = 0
	END CATCH
RETURN 0