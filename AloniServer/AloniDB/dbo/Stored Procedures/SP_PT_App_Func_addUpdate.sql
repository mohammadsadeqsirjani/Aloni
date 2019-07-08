CREATE PROCEDURE [dbo].[SP_PT_App_Func_addUpdate]
	@clientLanguage AS CHAR(2)
	,@appId AS TINYINT
	,@clientIp AS VARCHAR(50)
	,@id AS VARCHAR(100)
	,@description AS VARCHAR(500)
	,@area AS VARCHAR(100)
	,@fk_app_id AS TINYINT
	,@entityId AS VARCHAR(100)
	,@rCode AS TINYINT OUT
	,@rMsg AS VARCHAR(max) OUT
AS
	if(@id is null or @description is null or @area is null  or @fk_app_id is null)
	begin
	set @rMsg = dbo.func_getSysMsg('emptyRequiredFields', OBJECT_NAME(@@PROCID), @clientLanguage, 'فیلد های الزامی نباید خالی باشد');
	goto fail;
	end

	declare @existAppFunc AS VARCHAR(100);
	select @existAppFunc = id from TB_APP_FUNC where id = @id

	if(@existAppFunc is not null)
	begin
	set @rMsg = dbo.func_getSysMsg('existRecords', OBJECT_NAME(@@PROCID), @clientLanguage, 'رکوردی با این شناسه قبلا ثبت شده است');
	goto fail;
	end


	if(@entityId is null)
     begin
	 insert into TB_APP_FUNC (id,description,area,fk_app_id)
	 values (@id,@description,@area,@fk_app_id)
	 end
	 else
	 begin
	 update TB_APP_FUNC
	 set  description = @description
		 ,fk_app_id = @fk_app_id
     where id = @id
	 end

success:

SET @rCode = 1;

--commit transaction T
--set @rMsg = dbo.func_getSysMsg('success',OBJECT_NAME(@@PROCID),@clientLanguage,'the validation code sent.');
RETURN 0;

fail:

SET @rCode = 0;

--rollback transaction T
RETURN 0;
