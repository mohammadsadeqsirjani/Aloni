-- =============================================
-- Author:		saeed m khorsand
-- Create date: 1396 10 03
-- Description:	change user status
-- =============================================
CREATE PROCEDURE [dbo].[SP_PT_setUserStatus]
	@clientLanguage as char(2) = null,
	@appId as tinyint = null,
	@clientIp as varchar(50) = null,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@fk_user_id as bigint ,
	@fk_status_id as int
AS
BEGIN
	SET NOCOUNT ON;

	IF @fk_status_id not in (1,2)
		set @rCode = 0
	ELSE
		BEGIN

		update TB_USR
		set fk_status_id = @fk_status_id
		where id = @fk_user_id

		set @rCode = 1;
		END

END