CREATE PROCEDURE [dbo].[SP_updateItemPriceQty]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
    @barcode as varchar(150),
	@unitId as int,
    @quantity as money,
    @orderPoint as money,
    @prepaymentPercentage as int,
    @penaltyCancellationPercentage as int,
    @price as money,
    @periodicValidDayOrder as int,
    @discountPerPurcheseNumeric as int,
    @discountPerPurchesePercently as float,
    @notForSellingItem as bit,
    @includesTax as bit,
	@storeId as bigint
AS
	begin transaction T
		
		-- valid barcode
		if(@barcode is null)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid barcode',OBJECT_NAME(@@PROCID),@ClientLanguage, 'بارکد وارد نشده است')
			goto faild
		end
		-- valid penalty Cancellation Percentage
		if(@penaltyCancellationPercentage > 50)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid data',OBJECT_NAME(@@PROCID),@ClientLanguage, 'درصد جریمه کنسلی غیرمجاز است')
			goto faild
		end
		-- valid discount Per Purchese Numeric and discount PerPurchese Percently
		if(@discountPerPurchesePercently  > 100)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid data',OBJECT_NAME(@@PROCID),@ClientLanguage, 'درصد تخفیف بر پایه خرید غیرمجاز است')
			goto faild
		end
			begin try
					
					if(exists(select id from TB_ITEM where barcode = @barcode))
					begin
						declare @itemId as bigint =(select id from TB_ITEM where barcode = @barcode)
				-- update store_item
						update TB_ITEM
						set 
						 fk_unit_id = @unitId,
						 modifyDateTime = GETDATE(),
						 fk_usr_saveUser = @userId
						where id = @itemId

						update TB_STORE_ITEM_QTY
						set 
							discount_percent = (case when @discountPerPurchesePercently > 1 then @discountPerPurchesePercently / 100 else @discountPerPurchesePercently end),
							cancellationPenaltyPercent = @penaltyCancellationPercentage,
							includedTax = @includesTax,
						    isNotForSelling = @notForSellingItem,
							orderPoint = @orderPoint,
							prepaymentPercent = @prepaymentPercentage,
							price = @price,
							qty = @quantity,
							validityTimeOfOrder = @periodicValidDayOrder
						    
						WHERE
						    pk_fk_store_id = @storeId 
							and
						    pk_fk_item_id = @itemId


							commit transaction T
							
								set @rCode = 1
								set @rMsg = 'success'
							
							return
				END 
				else
				begin
					set @rCode = 0
					set @rMsg = 'کالایی با بارکد ' + @barcode + ' یافت نشد'
					return
				END

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

