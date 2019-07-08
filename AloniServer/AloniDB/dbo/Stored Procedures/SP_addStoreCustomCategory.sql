CREATE PROCEDURE [dbo].[SP_addStoreCustomCategory]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@title as varchar(150),
	@storeId as bigint,
	@customcategoryId as bigint out,
	@isActive as bit,
	@type as smallint
AS
	begin try
		if(LTRIM(rtrim(@title)) is null)
		begin
			set @rCode = 0
			set @rMsg = dbo.func_getSysMsg('invalid_title',OBJECT_NAME(@@procId),@clientLanguage,'عنوان دسته بندی سفارشی وارد نشده است')
			return
		end
		if(not exists(select id from TB_STORE where id = @storeId) or @storeId is null)
		begin
			set @rCode = 0
			set @rMsg = dbo.func_getSysMsg('invalid_store',OBJECT_NAME(@@procId),@clientLanguage,'شناسه فروشگاه غیرمجاز است')
			return
		end
		if(@customcategoryId > 0)
		begin
			if((select fk_store_id from TB_STORE_CUSTOM_CATEGORY where id = @customcategoryId) != @storeId)
			begin
				set @rCode = 0
				set @rMsg = dbo.func_getSysMsg('invalid_action',OBJECT_NAME(@@procId),@clientLanguage,'این دسته بندی به فروشگاه شما تعلق ندارد')
				return
			end
			if(exists(select pk_fk_custom_category_id from TB_STORE_CUSTOMCATEGORY_ITEM where pk_fk_custom_category_id = @customcategoryId))
			begin
				if( @type is not null and @type > 0)
				begin
					if(@type not in(select tyg.[type] from TB_TYP_ITEM_GRP tyg inner join TB_ITEM I on i.fk_itemGrp_id = tyg.id where I.id in (select pk_fk_item_id from TB_STORE_CUSTOMCATEGORY_ITEM where pk_fk_custom_category_id = @customcategoryId)))
					begin
						set @rCode = 0
						set @rMsg = dbo.func_getSysMsg('invalid_action',OBJECT_NAME(@@procId),@clientLanguage,'نوع دسته بندی با اقلام تعریف شده در دسته بندی هم خوانی ندارد')
						return
					end
				end
			end
			update TB_STORE_CUSTOM_CATEGORY set title = @title,isActive = @isActive,[type] =case when @type is not null and @type > 0 then @type else [type] end where id = @customcategoryId
			--delete from TB_STORE_CUSTOMCATEGORY_ITEM where pk_fk_custom_category_id = @customcategoryId
			--insert into TB_STORE_CUSTOMCATEGORY_ITEM(pk_fk_custom_category_id,pk_fk_item_id) select @customcategoryId,id from @itemList where id in (select pk_fk_item_id from TB_STORE_ITEM_QTY where pk_fk_store_id = @storeId)
			set @rCode = 1
			set @rMsg = 'success'
			return
		end
		else
		begin
			insert into TB_STORE_CUSTOM_CATEGORY(title,fk_store_id,[type]) values(@title,@storeId,@type)
			set @customcategoryId = SCOPE_IDENTITY();
			--if((select count(id) from @itemList where id in (select pk_fk_item_id from TB_STORE_ITEM_QTY where pk_fk_store_id = @storeId)) > 0)
			--begin
			--	insert into TB_STORE_CUSTOMCATEGORY_ITEM(pk_fk_custom_category_id,pk_fk_item_id) select @customcategoryId,id from @itemList where id in (select pk_fk_item_id from TB_STORE_ITEM_QTY where pk_fk_store_id = @storeId)
				set @rCode = 1
				set @rMsg = 'success'
				
			--end
		end
	end try
	begin catch
		set @rCode = 0
		set @rMsg = ERROR_MESSAGE()
	end catch
RETURN 0
