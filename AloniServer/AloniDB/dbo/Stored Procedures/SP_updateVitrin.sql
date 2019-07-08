CREATE PROCEDURE [dbo].[SP_updateVitrin]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@itemId as bigint ,
	@storeId as bigint,
	@itemGrpId as bigint,
	@title as nvarchar(100),
	@dsc as nvarchar(max),
	@documents as [dbo].[DocInfoItemType] readonly,
	@id as bigint,
	@type as smallint,
	@isHighlight as bit


AS
	if(@storeId is null)
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('invalid store',OBJECT_NAME(@@PROCID),@clientLanguage,'store id is invalid')
		return
	end
	if(LTRIM(RTRIM(@title)) is null)
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('invalid title',OBJECT_NAME(@@PROCID),@clientLanguage,'title is invalid')
		return
	end
	if(@itemId is null and @itemGrpId is null)
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('invalid data',OBJECT_NAME(@@PROCID),@clientLanguage,'item or itemGrp must be value')
		return
	end
	if(not exists(select d.id
		from 
			TB_DOCUMENT_ITEM DI inner join TB_DOCUMENT d on DI.pk_fk_document_id = d.id and d.isDeleted <> 1 
		where di.pk_fk_item_id = @itemId
		) AND (select fk_document_id from TB_TYP_ITEM_GRP where id = @itemGrpId) is null AND (select COUNT(id) from @documents) = 0)
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('invalid data',OBJECT_NAME(@@PROCID),@clientLanguage,'اختصاص تصویر به ویترین الزامی است')
		return
	end
	begin transaction T
	begin try
		delete from TB_DOCUMENT_STORE_VITRIN where pk_fk_vitrin_id = @id 
		update TB_STORE_VITRIN set fk_usr_id = @userId,fk_store_id=@storeId,fk_itemGrp_id=case when @itemGrpId = 0 then NULL else @itemGrpId end,fk_item_id= case when @itemId = 0 then NULL else @itemId end,title=@title,description=@dsc,[type] = @type,isHighlight = @isHighlight where id = @id
		if(exists(select 1 from @documents))
		begin
		insert into TB_DOCUMENT_STORE_VITRIN(pk_fk_document_id,isPrime,pk_fk_vitrin_id) select top 5 id,isDefault,@id from @documents
		end
		set @rCode = 1
		set @rMsg = 'success'
		commit transaction T
		return
	end try 
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
		rollback transaction T
		return
	end catch
RETURN 0
