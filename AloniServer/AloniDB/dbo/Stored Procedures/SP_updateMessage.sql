CREATE PROCEDURE [dbo].[SP_updateMessage]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@ids as dbo.MessageType readonly
AS
set nocount on
begin try
 update TB_MESSAGE set seenDateTime = GETDATE() where id in (select msgId from @ids)
 set @rCode = 1;
end try
begin catch
set @rMsg = dbo.func_getSysMsg('Error_unExpected',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
set @rCode = 0
end catch
RETURN 0
