CREATE PROCEDURE [dbo].[SP_updateUserLocation]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@lat as float,
	@lng as float,
	@sessionId as bigint
AS
	if(@lat <= 0 or @lng <= 0)
	begin
		set @rMsg =  dbo.func_getSysMsg('invalid location',OBJECT_NAME(@@PROCID),@clientLanguage,'invalid location!');
		set @rCode = 0
		return
	end

	update TB_USR_SESSION
	set 
	loc = geography::Point(@lat, @lng, 4326),
	loc_updTime = GETDATE()
	where id = @sessionId
	set @rCode = 1;
	set @rMsg =  dbo.func_getSysMsg('ok',OBJECT_NAME(@@PROCID),@clientLanguage,'success!');
RETURN 0
