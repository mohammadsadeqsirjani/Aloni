CREATE PROCEDURE [dbo].[SP_reportCrashBug]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@errorCode as int,
	@source as nvarchar(500),
	@message as nvarchar(500),
	@app as varchar(15)
	
AS
	insert into tb_crash_log values(@errorCode,@source,@message,@app,getdate())
	set @rCode = 1
RETURN 0
