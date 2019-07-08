CREATE PROCEDURE [dbo].[SP_CrashReport]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@lockId as bigint,
	@dsc as nvarchar(350),
	@storeId as bigint
AS
	set nocount on
	update TB_Store_Convert_File_Log set isCompleted = 0 ,dsc = @dsc where id = @lockId
	declare @sql as nvarchar(400) = N'drop table TB_TEMP_@storeId'
	exec sp_executesql @sql,N'@storeId bigint',@storeId = @storeId
	set @rCode = 1
	set @rMsg = 'success'
RETURN 0
