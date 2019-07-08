CREATE PROCEDURE [dbo].[SP_updateCustomItem]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@itemId as bigint,
	@storeId as bigint,
	@hasWaranty as bit,
    @purcheseWithoutWaranty as bit,
	@itemTitle as varchar(50) = NULL,
	@technicalItem as varchar(250) = NULL,
    @itemGroup as bigint = NULL,
    @barcode as varchar(150) = NULL,
    @localBarcode as varchar(150) = NULL,
    @dontShowingStoreItems as bit = NULL,
    @deliveriable as bit = NULL,
	@unitId as int = NULL,
    @quantity as money = NULL,
    @orderPoint as money = NULL,
    @prepaymentPercentage as int = NULL,
    @penaltyCancellationPercentage as int = NULL,
    @price as money = NULL,
    @periodicValidDayOrder as int = NULL,
    @discountPerPurcheseNumeric as int = NULL,
    @discountPerPurchesePercently as float = NULL,
    @notForSellingItem as bit = NULL,
    @includesTax as bit = NULL,
	@countryId as int = NULL,
    @manufacturerCo as varchar(150) = NULL,
    @importerCo as varchar(50) = NULL,
	@sex as bit = null,
	@fk_state as int = null,
	@fk_city_id as int = null,
	@village as varchar(50) = null,
	@unitName as varchar(150) = null,
	@dontShowUniqBarcode as bit = null,
	@review as text,
	@displayMode as bit = NULL,
	@color as [dbo].[ColorItemType] readonly,
	@size as [dbo].[SizeInfoItemType] readonly,
	@itemType as smallint = 1,
	@storeCustomCategory as [dbo].[LongIdTitleType] readonly,
	@lat as float = null,
	@lng as float = null,
	@address as nvarchar(250) = null,
	@findJustBarcode as bit = null,
	@commentCntPerDayPerUser as int = NULL,
	@commetnCntPerUser as int = NULL,
	@fk_education_id as smallint = NULL,
	@fk_status_itemId as int = NULL,
	@isLocked as bit = NULL
AS
	begin transaction T
		
		set @fk_education_id = case when @fk_education_id = 0 or @fk_education_id is null then NULL else @fk_education_id END
		declare @itemType1 as smallint = (select [type] from TB_TYP_ITEM_GRP as ig join TB_ITEM as i on i.fk_itemGrp_id = ig.id where i.id = @itemId)
		declare @displayMode1 as bit = (select displaymode from TB_ITEM where id = @itemId);
		DECLARE @storeAccessLevel AS TINYINT
		SELECT @storeAccessLevel = accessLevel FROM TB_STORE WHERE id = @storeId
		-- valid barcode
		declare @isTemplate as bit = (select isTemplate from TB_ITEM where id = @itemId)
		-- valid penalty Cancellation Percentage
		if(@penaltyCancellationPercentage > 50)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid data',OBJECT_NAME(@@PROCID),@ClientLanguage, 'penalty Cancellation Percentage larger than 50!')
			goto faild
		end
		-- valid discount Per Purchese Numeric and discount PerPurchese Percently
		if((@discountPerPurcheseNumeric is not null and @discountPerPurchesePercently is null) or (@discountPerPurcheseNumeric is null and @discountPerPurchesePercently is not null))
		begin
			set @rMsg = dbo.func_getSysMsg('invalid data',OBJECT_NAME(@@PROCID),@ClientLanguage, 'both valid discount Per Purchese Numeric and discount PerPurchese Percently, must be set!')
			goto faild
		end
		-- valid color
	    if(@isLocked = 1 and dbo.func_GetUserStaffStore(@userId,@storeId) <> 11)
		begin
			set @rMsg = dbo.func_getSysMsg('invalidLockItem',OBJECT_NAME(@@PROCID),@clientLanguage, 'شما مجاز به قفل کردن آیتم نیستید')
			goto faild
		end
	
		-- valid manufacturerCO
		--if(@manufacturerCo is null)
		--begin
		--	set @rMsg = dbo.func_getSysMsg('invalid data',OBJECT_NAME(@@PROCID),@ClientLanguage, 'The manufacturerCo must be set!')
		--	goto faild
		--end
		---- valid country id 
		--if(@countryId is null or @countryId = 0)
		--begin
		--	set @rMsg = dbo.func_getSysMsg('invalid data',OBJECT_NAME(@@PROCID),@ClientLanguage, 'The countryId must be set!')
		--	goto faild
		--end
		-- valid waranty 
		--if(@hasWaranty is not null and @hasWaranty = 1)
		--begin
		--	if((select count(*) from @waranty) = 0)
		--	begin
		--		set @rMsg = dbo.func_getSysMsg('invalid data',OBJECT_NAME(@@PROCID),@ClientLanguage, 'item has includes waranty but not defined any waranty for this!')
		--		goto faild
		--	end
		--end
		-- valid count piture
		--declare @countPicture int = (select COUNT(id) from @DocInfoItem)
		--if(@countPicture < 1 or @countPicture > 10)
		--begin
		--	set @rMsg = dbo.func_getSysMsg('invalid data',OBJECT_NAME(@@PROCID),@ClientLanguage, 'picture count must be 1 to 10!')
		--	goto faild
		--end
		    declare @template as bit = (select isTemplate from TB_ITEM where id = @itemId)
			declare @saveStoreId as bigint = (select fk_savestore_id from TB_ITEM  where id = @itemId)
			begin try
				if((@template = 0 or (@template = 1 and @storeAccessLevel = 1) or (@template = 1 and @storeAccessLevel = 2 and exists(select top 1 1  from TB_ITEM where id = @itemId and fk_itemGrp_id in(select fk_itemGrp_id from TB_STORE_ITEMGRP_ACCESSLEVEL where fk_store_id = @storeId)))  and (@saveStoreId = @storeId or @itemType1 <> 1 or  @displayMode1 = 1)))
				begin
				-- update Item
						UPDATE TB_ITEM
						SET 
							title =ISNULL(@itemTitle,title),
							technicalTitle =ISNULL(@technicalItem,technicalTitle) ,
							modifyDateTime = GETDATE(),
							manufacturerCo =ISNULL(@manufacturerCo,manufacturerCo) ,
							importerCo =ISNULL(@importerCo,importerCo),
							fk_usr_saveUser = @userId,
							fk_unit_id =ISNULL(@unitId,fk_unit_id),
							fk_itemGrp_id =ISNULL(@itemGroup,fk_itemGrp_id),
							fk_country_Manufacturer =case when @countryId > 0 then @countryId else  fk_country_Manufacturer end,
							barcode =case when @isTemplate = 1 then barcode else  ISNULL(@barcode,barcode) END,
							review =ISNULL(@review,review) ,
							sex =ISNULL(@sex,sex),
							unitName =ISNULL(@unitname,unitName),
							findJustBarcode =ISNULL(@findJustBarcode,findJustBarcode),
							fk_state_id =case when @fk_state > 0 then @fk_state else fk_state_id end,
							fk_city_id =case when @fk_city_id > 0 then @fk_city_id else fk_city_id end,
							village =ISNULL(@village,village) ,
							fk_education_id = ISNULL(@fk_education_id,fk_education_id),
							fk_status_id = ISNULL(@fk_status_itemId,fk_status_id),
							isLocked = case when @template = 0 and @saveStoreId = @storeId then ISNULL(@isLocked,isLocked) ELSE isLocked END
						WHERE 
							id = @itemId
				
				-- update store_item
						UPDATE TB_STORE_ITEM_QTY
						SET 
							discount_minCnt =ISNULL(@discountPerPurcheseNumeric,discount_minCnt),
							discount_percent = (case when @discountPerPurchesePercently > 1 then @discountPerPurchesePercently / 100 else ISNULL(@discountPerPurchesePercently,discount_percent)  end),
							cancellationPenaltyPercent =ISNULL(@penaltyCancellationPercentage,cancellationPenaltyPercent),
							fk_country_Manufacturer =case when @countryId > 0 then @countryId else fk_country_Manufacturer end,
							hasDelivery =ISNULL(@deliveriable,hasDelivery),
							importerCo =ISNULL(@importerCo,importerCo),
							includedTax =ISNULL(@includesTax,includedTax),
							isNotForSelling =ISNULL(@notForSellingItem,isNotForSelling),
							localBarcode =ISNULL(@localBarcode,localBarcode) ,
							ManufacturerCo =ISNULL(@manufacturerCo,ManufacturerCo) ,
							orderPoint =ISNULL(@orderPoint,orderPoint) ,
							prepaymentPercent =ISNULL(@prepaymentPercentage,prepaymentPercent),
							price =ISNULL(@price,price),
							qty =ISNULL(@quantity,qty),
							validityTimeOfOrder =ISNULL(@periodicValidDayOrder,validityTimeOfOrder) ,
							dontShowinginStoreItem =ISNULL(@dontShowingStoreItems,dontShowinginStoreItem),
							doNotShowUniqueBarcode =ISNULL(@dontShowUniqBarcode,doNotShowUniqueBarcode) ,
							[location] = case when @lat is not null and @lat > 0 and @lng is not null and @lng > 0 then geography::Point(@lat,@lng,4326) else [location] end,
							[address] =ISNULL(@address,[address]) ,
							hasWarranty =ISNULL(@hasWaranty,hasWarranty),
							canBePurchasedWithoutWarranty =ISNULL(@purcheseWithoutWaranty,canBePurchasedWithoutWarranty),
							commentCntPerDayPerUser = ISNULL(@commentCntPerDayPerUser,commentCntPerDayPerUser),
							commentCntPerUser = ISNULL(@commetnCntPerUser,commentCntPerUser)
						WHERE 
							pk_fk_store_id = @storeId 
							AND
							pk_fk_item_id = @itemId
				end
				else
				begin -- item isTemplate = true
						
				-- update store_item
						UPDATE TB_ITEM
						SET 
							sex =ISNULL(@sex,sex) ,
							fk_state_id =case when @fk_state > 0 then @fk_state end,
							fk_city_id =case when @fk_city_id > 0 then @fk_city_id end,
							village =ISNULL(@village,village),
							displayMode =ISNULL(@displayMode,displayMode) ,
							findJustBarcode =ISNULL(@findJustBarcode,findJustBarcode) ,
							unitName =ISNULL(@unitname,unitName) ,
							modifyDateTime = GETDATE(),
							fk_status_id = ISNULL(@fk_status_itemId,fk_status_id)
						WHERE 
							id = @itemId

						UPDATE TB_STORE_ITEM_QTY
						SET 
							discount_minCnt =ISNULL(@discountPerPurcheseNumeric,discount_minCnt),
							discount_percent = (case when @discountPerPurchesePercently > 1 then @discountPerPurchesePercently / 100 else ISNULL(@discountPerPurchesePercently,discount_percent)  end),
							cancellationPenaltyPercent =ISNULL(@penaltyCancellationPercentage,cancellationPenaltyPercent),
							fk_country_Manufacturer =case when @countryId > 0 then @countryId else fk_country_Manufacturer end,
							hasDelivery =ISNULL(@deliveriable,hasDelivery),
							importerCo =ISNULL(@importerCo,importerCo),
							includedTax =ISNULL(@includesTax,includedTax),
							isNotForSelling =ISNULL(@notForSellingItem,isNotForSelling),
							localBarcode =ISNULL(@localBarcode,localBarcode) ,
							ManufacturerCo =ISNULL(@manufacturerCo,ManufacturerCo) ,
							orderPoint =ISNULL(@orderPoint,orderPoint) ,
							prepaymentPercent =ISNULL(@prepaymentPercentage,prepaymentPercent),
							price =ISNULL(@price,price),
							qty =ISNULL(@quantity,qty),
							validityTimeOfOrder =ISNULL(@periodicValidDayOrder,validityTimeOfOrder) ,
							dontShowinginStoreItem =ISNULL(@dontShowingStoreItems,dontShowinginStoreItem),
							doNotShowUniqueBarcode =ISNULL(@dontShowUniqBarcode,doNotShowUniqueBarcode) ,
							[location] = case when @lat is not null and @lat > 0 and @lng is not null and @lng > 0 then geography::Point(@lat,@lng,4326) else [location] end,
							[address] =ISNULL(@address,[address]) ,
							hasWarranty =ISNULL(@hasWaranty,hasWarranty),
							canBePurchasedWithoutWarranty =ISNULL(@purcheseWithoutWaranty,canBePurchasedWithoutWarranty),
							commentCntPerDayPerUser = ISNULL(@commentCntPerDayPerUser,commentCntPerDayPerUser),
							commentCntPerUser = ISNULL(@commetnCntPerUser,commentCntPerUser)
						WHERE 
							pk_fk_store_id = @storeId 
							AND
							pk_fk_item_id = @itemId

				end -- end else
		---- insert into store waranti
		--		if(@hasWaranty = 1)
		--		begin
		--			-- delete waranties of store 
		--			delete from TB_STORE_WARRANTY where fk_store_id = @storeId
		--			declare @warantiCount int = (select count(WarantyCo) from @waranty)
		--			declare @i int= 0;
		--			while(@i < @warantiCount)
		--			begin
		--				insert into TB_STORE_WARRANTY(fk_store_id,title) select @storeId,WarantyCo from @waranty where id = @i
		--				declare @fkStoreWarantiId bigint = SCOPE_IDENTITY()
		--				insert into TB_STORE_ITEM_WARRANTY(pk_fk_store_id,pk_fk_item_id,pk_fk_storeWarranty_id,warrantyCost,warrantyDays)
		--							select @storeId,@itemId,@fkStoreWarantiId,warrantyCost,warrantyDays from @waranty where id = @i
		--				set @i+=1
		--			end -- wnd while
		--		end
		---- insert into tb document Item

		--		insert into TB_DOCUMENT_ITEM(pk_fk_document_id,pk_fk_item_id,isDefault) select id,@itemId,isDefault from @DocInfoItem

		---- insert into technical info
		--		delete from TB_ITEM_TECHNICALINFO where pk_fk_item_id = @itemId and pk_fk_technicalInfo_id in (select technicalInfoId from @TechnicalInfoItem)
		--		insert into TB_ITEM_TECHNICALINFO(pk_fk_item_id,pk_fk_technicalInfo_id,strValue,fk_technicalInfoValues_tblValue) select @itemId,technicalInfoId,strValue,technicalTableValueId from @TechnicalInfoItem
		-- insert color
				delete from TB_STORE_ITEM_COLOR where pk_fk_item_id = @itemId and pk_fk_store_id = @storeId
				insert into TB_STORE_ITEM_COLOR(pk_fk_item_id,pk_fk_store_id,fk_color_id,isActive,colorCost) select @itemId,@storeId,color,isActive,colorCost from @color
		-- insert size
				delete from TB_STORE_ITEM_SIZE where pk_fk_item_id = @itemId and pk_fk_store_id = @storeId
				insert into TB_STORE_ITEM_SIZE(pk_fk_item_id,pk_fk_store_id,pk_sizeInfo,isActive,sizeCost) select @itemId,@storeId,sizeInfo,isActive,sizeCost from @size

	    --insert custom category
		        delete scci
				 from TB_STORE_CUSTOMCATEGORY_ITEM as scci
				inner join TB_STORE_CUSTOM_CATEGORY as scc on scci.pk_fk_custom_category_id = scc.id
				 where scci.pk_fk_item_id = @itemId and scc.fk_store_id = @storeId

		        insert into TB_STORE_CUSTOMCATEGORY_ITEM
				select sccs.id,@itemId 
				from @storeCustomCategory as sccs 
				join TB_STORE_CUSTOM_CATEGORY as scc on sccs.id = scc.id and scc.fk_store_id = @storeId-- and scc.isActive = 1


				commit transaction T
				set @rCode = 1

				return 
		end try
		begin catch
				set @rMsg = dbo.func_getSysMsg('Error',OBJECT_NAME(@@PROCID),@ClientLanguage,ERROR_MESSAGE())
				goto faild
		end catch
		faild:
				rollback transaction T
				set @rCode = 0
				return 0
	
RETURN 0

