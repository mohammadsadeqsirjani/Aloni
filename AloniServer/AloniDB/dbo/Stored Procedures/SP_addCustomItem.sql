CREATE PROCEDURE [dbo].[SP_addCustomItem]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@itemId as bigint out,
	@storeId as bigint,
	@itemTitle as varchar(50),
	@technicalItem as varchar(250),
    @itemGroup as bigint,
    @barcode as varchar(150),
    @localBarcode as varchar(150),
    @dontShowingStoreItems as bit,
    @deliveriable as bit,
	@sex as bit = null,
	@fk_state as int = null,
	@fk_city_id as int = null,
	@village as varchar(50) = null,
	@unitName as varchar(150) = null,
	@dontShowUniqBarcode as bit = null,
	@displayMode as bit = 0,
	@fk_ObjectGrpId as bigint = null,
	@itemType as smallint = 1,
	@fk_status_itemId as int = 20,
	@storeCustomCategory as [dbo].[LongIdTitleType] readonly,
	@lat as float = null,
	@lng as float = null,
	@address as nvarchar(250) = null,
	@findJustBarcode as bit = null,
	@commentCntPerUser as int = null,
	@commentCntPerDayPerUser as int = null,
	@fk_education_id as smallint = NULL,
	@isLocked as bit = 0
    AS
	set nocount on
	begin transaction T
		
		
		set @fk_education_id = case when @fk_education_id = 0 then NULL else @fk_education_id END
		declare @uniqBarcode as nvarchar(max)
	    if @itemType = 0 or @itemType is null
			set @itemType = (select [type] from TB_TYP_ITEM_GRP where id = @itemGroup)
	
		if(@isLocked = 1 and dbo.func_GetUserStaffStore(@userId,@storeId) <> 11)
		begin
			set @rMsg = dbo.func_getSysMsg('invalidLockItem',OBJECT_NAME(@@PROCID),@clientLanguage, 'شما مجاز به قفل کردن آیتم نیستید')
			goto faild
		end
		if(@barcode is not null and @barcode <> '0' and exists(select top 1 1 from TB_ITEM where barcode = @barcode) and @itemType = 1)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid title',OBJECT_NAME(@@PROCID),@clientLanguage, 'بارکد رسمی تکراری است')
			goto faild
		end
		if(LTRIM(RTRIM(@itemTitle)) is null)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid title',OBJECT_NAME(@@PROCID),@clientLanguage, 'وارد کردن عنوان  الزامی است.')
			goto faild
		end
		
		if(@itemGroup is null or @itemGroup = 0)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid itemGrp',OBJECT_NAME(@@PROCID),@clientLanguage, 'گروه مشخص نشده است')
			goto faild
		end
		-- valid discount Per Purchese Numeric and discount PerPurchese Percently
		--if(LTRIM(RTRIM(@barcode)) is null and @itemType = 1)
		--begin
		--	set @rMsg = dbo.func_getSysMsg('invalid barcode',OBJECT_NAME(@@PROCID),@clientLanguage, 'وارد کردن بارکد الزامی است')
		--	goto faild
		--end
		if(exists(select barcode from TB_ITEM I inner join TB_STORE_ITEM_QTY siq on i.id = siq.pk_fk_item_id where i.barcode = @barcode and siq.pk_fk_store_id = @storeId and i.fk_status_id = 15) and @itemType = 1)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid itemGrp',OBJECT_NAME(@@PROCID),@clientLanguage, ' بارکد مشابه در پنل ثبت شده است.')
			goto faild
		end
		if(exists(select top 1 * from TB_ITEM where title = @itemTitle and fk_savestore_id = @storeId and itemType = @itemType))
		begin
			set @rMsg = dbo.func_getSysMsg('titleIsExists',OBJECT_NAME(@@PROCID),@clientLanguage, '  این عنوان از قبل در پنل موجود است')
			goto faild
		end
		begin try
				insert into TB_ITEM(title,technicalTitle,saveDateTime,isTemplate,fk_usr_saveUser,fk_unit_id,fk_status_id,fk_savestore_id,fk_itemGrp_id,fk_country_Manufacturer,barcode,sex,fk_state_id,fk_city_id,village,unitName,displayMode,fk_objectGrp_id,modifyDateTime,itemType,findJustBarcode,fk_education_id,isLocked)
							values(@itemTitle,@technicalItem,GETDATE(),0,@userId,1,@fk_status_itemId,@storeId,@itemGroup,1,@barcode,@sex,@fk_state,@fk_city_id,@village,@unitName,@displayMode,@fk_ObjectGrpId,GETDATE(),@itemType,@findJustBarcode,@fk_education_id,@isLocked)
				set @itemId = SCOPE_IDENTITY()
				set @uniqBarcode = dbo.func_getUniqueBarcodeItem(@itemId)
		-- insert into store_item
				insert into TB_STORE_ITEM_QTY(pk_fk_store_id,pk_fk_item_id,cancellationPenaltyPercent,fk_status_id,hasDelivery,includedTax,isNotForSelling,prepaymentPercent,price,qty,localBarcode,doNotShowUniqueBarcode,[location],[address],commentCntPerUser,commentCntPerDayPerUser)
							values(@storeId,@itemId,0,15,@deliveriable,0,case when @displayMode = 1 then 1 else 0 end,0,0,0,@localBarcode,@dontShowUniqBarcode,case when @lat is not null and @lat > 0 and @lng is not null and @lng > 0 then geography::Point(@lat,@lng,4326) else NULL end,@address,@commentCntPerUser,@commentCntPerDayPerUser)
	
				insert into TB_USR_LOG(fk_event_id,fk_item_id,fk_store_id,fk_dst_user_id) select 2,@itemId,@storeId,pk_fk_usr_cstmrId from TB_STORE_CUSTOMER where pk_fk_store_id = @storeId and fk_status_id = 32
				if(@barcode is null)
				begin
					update TB_ITEM set barcode = @uniqBarcode,uniqueBarcode = @uniqBarcode where id = @itemId
				end
				else
				begin
					update TB_ITEM set uniqueBarcode = @uniqBarcode where id = @itemId
				end
				insert into TB_STORE_CUSTOMCATEGORY_ITEM
				select sccs.id,@itemId from @storeCustomCategory as sccs 
						join TB_STORE_CUSTOM_CATEGORY as scc on sccs.id = scc.id and scc.fk_store_id = @storeId


				commit transaction T
				set @rCode = 1
				return 
		end try
		begin catch
				set @rMsg = dbo.func_getSysMsg('Error',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
				goto faild
		end catch
		faild:
				rollback transaction T
				set @rCode = 0
				return 0
	
	
RETURN 0
