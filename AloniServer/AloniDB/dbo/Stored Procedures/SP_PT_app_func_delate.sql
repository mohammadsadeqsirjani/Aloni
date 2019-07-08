CREATE PROCEDURE [dbo].[SP_PT_app_func_delate]
	@clientLanguage AS CHAR(2)
	,@appId AS TINYINT
	,@clientIp AS VARCHAR(50)
	,@id AS VARCHAR(100)
	,@rCode AS TINYINT OUT
	,@rMsg AS VARCHAR(max) OUT
AS
	declare @useInTable AS  VARCHAR(100) = null;
select @useInTable = fk_func_id from TB_APP_FUNC_USR WHERE fk_func_id = @id

if(@id is null)
begin
	set @rMsg = dbo.func_getSysMsg('emptyId', OBJECT_NAME(@@PROCID), @clientLanguage, 'شناسه نمی تواند خالی باشد');
	goto fail;
	end

if(@useInTable is not null)
	begin
	set @rMsg = dbo.func_getSysMsg('cantDeleteRecord', OBJECT_NAME(@@PROCID), @clientLanguage, 'امکان حذف رکورد وجود ندارد');
	goto fail;
	end

	delete from TB_APP_FUNC_USR where id = @id

	success:

SET @rCode = 1;

--commit transaction T
--set @rMsg = dbo.func_getSysMsg('success',OBJECT_NAME(@@PROCID),@clientLanguage,'the validation code sent.');
RETURN 0;

fail:

SET @rCode = 0;

--rollback transaction T
RETURN 0;
