CREATE PROCEDURE [dbo].[SP_usrSession_updatePushNotiClientToken]
     @clientLanguage AS CHAR(2)
	,@clientIp AS VARCHAR(50)
	,@appId as tinyint
	,@userId as bigint
	,@sessionId AS BIGINT
	,@pushNotiId varchar(250)
	,@provider tinyint = null

	,@rCode AS TINYINT OUT
	,@rMsg AS NVARCHAR(max) OUT
AS




update TB_USR_SESSION
set pushNotiId = @pushNotiId,
pushNotiProvider = @provider
where id = @sessionId;





success:

SET @rCode = 1;
SET @rMsg = 'success.';

RETURN 0;

fail:

--ROLLBACK TRAN t1;

SET @rCode = 0;

RETURN 0;
