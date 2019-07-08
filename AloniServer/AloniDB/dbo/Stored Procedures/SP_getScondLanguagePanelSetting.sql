CREATE PROCEDURE [dbo].[SP_getScondLanguagePanelSetting]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@pageNo as int,
	@search as nvarchar(100) = NULL,
	@parent as varchar(20) = null,
	@storeId as bigint
AS
	SET NOCOUNT ON
	SELECT
		second_lan_about,
		second_lan_address,
		second_lan_manager,
		second_lan_title

	from TB_STORE where id = @storeId
RETURN 0
