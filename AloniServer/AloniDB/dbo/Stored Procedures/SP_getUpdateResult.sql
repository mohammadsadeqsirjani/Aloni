CREATE PROCEDURE [dbo].[SP_getUpdateResult]
	 @clientLanguage AS CHAR(2)
	,@appId AS TINYINT
	,@clientIp AS VARCHAR(50)
	,@userId AS BIGINT
	,@pageNo AS INT = 0
	,@search AS NVARCHAR(100) = NULL
	,@parent AS VARCHAR(20) = NULL,
	 @storeId as bigint
	
AS
BEGIN
	SET NOCOUNT ON;
	declare @tb_name nvarchar(150) = 'TB_TEMP_Update_'+cast(@storeId as nvarchar(50))
	declare @SQLString nvarchar(250) = N'select * from  '+ quotename(@tb_name)
	EXEC sp_executesql @SQLString
	set @SQLString = N'drop table '+ quotename(@tb_name)
	EXEC sp_executesql @SQLString
	
END