CREATE PROCEDURE [dbo].[SP_addStoreGrouping]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storegroupingId as bigint out,
	@title as nvarchar(50),
	@parentStoreGroupingId as bigint,
	@storeId as bigint
AS
	SET NOCOUNT ON
	if(@title is null)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid title',OBJECT_NAME(@@PROCID),@clientLanguage,'title required!'); 
		set @rCode = 0
		return
	end
	if(@storeId is null)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid store',OBJECT_NAME(@@PROCID),@clientLanguage,'store required!'); 
		set @rCode = 0
		return
	end
	if((select count(id) from TB_STORE where id = @storeId) = 0)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid store',OBJECT_NAME(@@PROCID),@clientLanguage,'store invalid!'); 
		set @rCode = 0
		return
	end
	begin try
		insert into TB_STORE_GROUPING(title,fk_storeGrouping_parent,fk_store_id,fk_status_id) values(@title,@parentStoreGroupingId,@storeId,21)
		set @storegroupingId = SCOPE_IDENTITY()
		set @rCode = 1
		
	end try
	begin catch
		set @rMsg = dbo.func_getSysMsg('Error',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
		set @rCode = 0
	end catch
RETURN 0
