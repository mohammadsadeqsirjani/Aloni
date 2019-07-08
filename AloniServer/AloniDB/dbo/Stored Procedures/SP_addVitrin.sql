CREATE PROCEDURE [dbo].[SP_addVitrin]
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
	@isHighlight as bit,
	@type as smallint,

	@id as bigint out
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
	if(exists(select id from TB_STORE_VITRIN where fk_store_id = @storeId and fk_item_id = @itemId and isDeleted <> 1))
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('invalid data',OBJECT_NAME(@@PROCID),@clientLanguage,'این کالا از قبل در ویترین فروشگاه موجود است')
		return
	end
	begin transaction T
	begin try
		insert into TB_STORE_VITRIN(fk_usr_id,fk_store_id,fk_itemGrp_id,fk_item_id,title,description,saveDatetime,[type],isHighlight)
									values(@userId,@storeId,case when @itemGrpId = 0 then NULL else @itemGrpId end,case when @itemId = 0 then NULL else @itemId end,@title,@dsc,GETDATE(),@type,@isHighlight)
		set @id = SCOPE_IDENTITY();
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
