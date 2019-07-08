CREATE PROCEDURE [dbo].[SP_addCustomItemLevel2]
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
  @unitId as int,
  @quantity as money,
  @orderPoint as money,
  @prepaymentPercentage as int,
  @penaltyCancellationPercentage as int,
  @price as money,
  @periodicValidDayOrder as int,
  @discountPerPurcheseNumeric as int,
  @discountPerPurchesePercently as int,
  @notForSellingItem as bit,
  @includesTax as bit,
  @countryId as int,
  @manufacturerCo as varchar(150),
  @importerCo as varchar(50),
  --@waranty as [dbo].[WarantyType] readonly,
  @color as [dbo].[ColorItemType] readonly,
  @size as [dbo].[SizeInfoItemType] readonly,
  @review as text,
  @lat as float = null,
  @lng as float = null,
  @address as nvarchar(250) = null
    
AS
	set nocount on
	begin transaction T
	
		-- valid penalty Cancellation Percentage
		if(@penaltyCancellationPercentage > 50)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid_percent',OBJECT_NAME(@@PROCID),@ClientLanguage, 'penalty Cancellation Percentage larger than 50!')
			goto faild
		end
		-- valid discount Per Purchese Numeric and discount PerPurchese Percently
		if((@discountPerPurcheseNumeric is not null and @discountPerPurchesePercently is null) or (@discountPerPurcheseNumeric is null and @discountPerPurchesePercently is not null))
		begin
			set @rMsg = dbo.func_getSysMsg('invalid_disCountPercent',OBJECT_NAME(@@PROCID),@ClientLanguage, 'both valid discount Per Purchese Numeric and discount PerPurchese Percently, must be set!')
			goto faild
		end
		if(@penaltyCancellationPercentage is not null and @prepaymentPercentage is null)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid_prePaymentPercent',OBJECT_NAME(@@PROCID),@ClientLanguage, 'pre payment percentage depends on penalty cancellation percentage!')
			goto faild
		end
		-- valid manufacturerCO
		if(@manufacturerCo is null)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid data',OBJECT_NAME(@@PROCID),@ClientLanguage, 'The manufacturerCo must be set!')
			goto faild
		end
		-- valid country id 
		if(@countryId is null or @countryId = 0)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid data',OBJECT_NAME(@@PROCID),@ClientLanguage, 'The countryId must be set!')
			goto faild
		end
		-- valid color
		if(not exists(select id from TB_COLOR where id in( (select color from @color))))
		begin
			set @rMsg = dbo.func_getSysMsg('invalid color',OBJECT_NAME(@@PROCID),@ClientLanguage, 'color invalid!')
			goto faild
		end
		-- valid waranty 
		--if(@hasWaranty is not null and @hasWaranty = 1)
		--begin
		--	if((select count(*) from @waranty) = 0)
		--	begin
		--		set @rMsg = dbo.func_getSysMsg('invalid data',OBJECT_NAME(@@PROCID),@ClientLanguage, 'item has includes waranty but not defined any waranty for this!')
		--		goto faild
		--	end
		--end
		
		
		begin try
		declare @displayMode bit= (select displayMode from tb_item where id = @itemId) 
		-- update Item
				update TB_ITEM set manufacturerCo = @manufacturerCo,importerCo = @importerCo ,fk_unit_id = @unitId,fk_country_Manufacturer = @countryId,review = @review,modifyDateTime = GETDATE(),fk_modify_usr_id = @userId
				where id = @itemId
							
				
		-- update store_item
				update TB_STORE_ITEM_QTY set discount_minCnt = @discountPerPurcheseNumeric,discount_percent = @discountPerPurchesePercently,cancellationPenaltyPercent = @penaltyCancellationPercentage,fk_country_Manufacturer = @countryId,importerCo = @importerCo,
				includedTax = @includesTax,isNotForSelling =case when @displayMode = 1 then 1 else @notForSellingItem end,ManufacturerCo = @manufacturerCo,orderPoint = @orderPoint,
				prepaymentPercent = @prepaymentPercentage,price = @price,qty = @quantity,validityTimeOfOrder = @periodicValidDayOrder,[location] = case when @lat is not null and @lat > 0 and @lng is not null and @lng > 0 then geography::Point(@lat,@lng,4326) end,[address] = @address
				where pk_fk_store_id = @storeId and pk_fk_item_id = @itemId
						
		---- insert into store waranti
		--		if(@hasWaranty = 1)
		--		begin
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
		

		
		-- insert color
				insert into TB_STORE_ITEM_COLOR(pk_fk_item_id,pk_fk_store_id,fk_color_id,isActive,colorCost) select @itemId,@storeId,color,isActive,colorCost from @color
		-- insert size
				insert into TB_STORE_ITEM_SIZE(pk_fk_item_id,pk_fk_store_id,pk_sizeInfo,isActive,sizeCost) select @itemId,@storeId,sizeInfo,isActive,sizeCost from @size
				commit transaction T
				set @rCode = 1
				set @rMsg = 'success'
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