CREATE PROCEDURE [dbo].[SP_addItemsByItemGrp]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@StoreGroupingId as [dbo].[LongType] readonly,
	@storeId as bigint
AS
	SET NOCOUNT ON
	
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
		
		insert into TB_STORE_ITEM_QTY(pk_fk_store_id,pk_fk_item_id,fk_status_id)
		select @storeId,I.id,I.fk_status_id
		from TB_ITEM I with(nolock)
		inner join
		TB_TYP_ITEM_GRP tyg  with(nolock) on I.fk_itemGrp_id = tyg.id and tyg.id in (select id from @StoreGroupingId) and i.id not in (select pk_fk_item_id from TB_STORE_ITEM_QTY where pk_fk_store_id = @storeId)
		where isTemplate = 1 and i.fk_status_id = 15
		set @rCode = 1
		set @rMsg = 'success'
		
	end try
	begin catch
		set @rMsg = dbo.func_getSysMsg('Error',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
		set @rCode = 0
	end catch
RETURN 0