CREATE PROCEDURE [dbo].[SP_changeSecondLanguageSetting]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
    @title as varchar(250),
	@dsc as varchar(250),
	@manager as varchar(50),
	@address as varchar(100)
AS
	SET NOCOUNT ON
	BEGIN TRY
		UPDATE TB_STORE SET second_lan_title = @title,second_lan_about = @dsc,second_lan_manager = @manager , second_lan_address = @address WHERE ID = @storeId
		set @rMsg = dbo.func_getSysMsg('done',OBJECT_NAME(@@PROCID),@clientLanguage,'success');
		SET @rCode = 1
	END TRY
	BEGIN CATCH
		set @rMsg = dbo.func_getSysMsg('ERRORE',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
		set @rCode = 0
	END CATCH
RETURN 0
