CREATE PROCEDURE [dbo].[SP_addItemToCategory]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@catId as bigint,
	@itemList as dbo.LongType readonly,
	@itemGrpList as dbo.LongType readonly
AS
	begin try
	if(not exists(select id from TB_STORE_CUSTOM_CATEGORY where id = @catId))
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,'شناسه دسته بندی یافت نشد')
		return
	end
	if((select count(id) from @itemGrpList) > 0)
	begin
		insert into TB_STORE_CUSTOMCATEGORY_ITEM(pk_fk_custom_category_id,pk_fk_item_id) select @catId, i.id
		from 
			TB_ITEM I inner join TB_STORE_ITEM_QTY SIQ on i.id = SIQ.pk_fk_item_id
			inner join TB_STORE_CUSTOM_CATEGORY C on SIQ.pk_fk_store_id = c.fk_store_id and c.id = @catId
			where i.fk_itemGrp_id in (select id from @itemGrpList where type = (select [type] from TB_STORE_CUSTOM_CATEGORY where id= @catId)) and i.fk_status_id = 15 and i.id not in(select pk_fk_item_id from TB_STORE_CUSTOMCATEGORY_ITEM where pk_fk_custom_category_id = @catId)
	end
	else
	begin
		
			insert into TB_STORE_CUSTOMCATEGORY_ITEM(pk_fk_custom_category_id,pk_fk_item_id) select @catId, i.id from @itemList I inner join TB_ITEM II on i.id = II.id  where i.id not in (select pk_fk_item_id from TB_STORE_CUSTOMCATEGORY_ITEM where pk_fk_custom_category_id = @catId) and II.itemType =(select [type] from TB_STORE_CUSTOM_CATEGORY where id = @catId)
		
	end
		if(@@ROWCOUNT > 0)
		begin		
			set @rCode = 1
			set @rMsg = 'success'
		end
		else
		begin
			set @rCode = 0
			set @rMsg = 'کالاهای مدنظر شما قبلا ثبت شده است و یا کالایی با شرایط اضافه شدن به دسته بندی در گروه های انتخابی شما وجود ندارد'
		end
	end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,'با پشتیبانی تماس بگیرید')
	end catch
RETURN 0

