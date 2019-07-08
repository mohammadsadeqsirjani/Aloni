CREATE PROCEDURE [dbo].[SP_getInvitationText]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	--@rCode as smallint out,
	@rMsg as nvarchar(500) out
	
AS
	SET NOCOUNT ON
	set @rMsg = (SELECT body FROM TB_SYSTEMMESSAGE WHERE msgKey = 'message_invatationText' and lan = @clientLanguage)
	
RETURN 0
