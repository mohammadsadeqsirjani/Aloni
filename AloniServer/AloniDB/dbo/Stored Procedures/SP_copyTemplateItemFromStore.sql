CREATE PROCEDURE [dbo].[SP_copyTemplateItemFromStore]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@sourceStoreId as bigint,
	@destStoreId as bigint 
AS
	begin try
		begin transaction T
		insert into TB_STORE_ITEM_QTY(pk_fk_store_id, pk_fk_item_id, qty, orderPoint, inventoryControl, price, fk_country_Manufacturer, ManufacturerCo, localBarcode, fk_status_id, hasDelivery, isNotForSelling, discount_minCnt, discount_percent, includedTax, prepaymentPercent, cancellationPenaltyPercent, validityTimeOfOrder, importerCo, hasWarranty, canBePurchasedWithoutWarranty, dontShowinginStoreItem, saveDateTime, uniqueBarcode, doNotShowUniqueBarcode, fk_status_shiftStatus, location, address, commentCntPerUser, commentCntPerDayPerUser, canBeSalesNegative)		
			   select
					@destStoreId,i.id,0,siq.orderPoint,siq.inventoryControl,0,siq.fk_country_Manufacturer,siq.ManufacturerCo,NULL,15,siq.hasDelivery,siq.isNotForSelling,0,0,siq.includedTax,0,0,siq.validityTimeOfOrder,siq.importerCo,siq.hasWarranty,siq.canBePurchasedWithoutWarranty,siq.dontShowinginStoreItem,GETDATE(),NULL,siq.doNotShowUniqueBarcode,siq.fk_status_shiftStatus,NULL,NULL,siq.commentCntPerUser,siq.commentCntPerDayPerUser,0
			   from
			   TB_ITEM I With(nolock)
			   inner join TB_STORE_ITEM_QTY siq with(nolock) on i.id = siq.pk_fk_item_id
			   where
				i.fk_savestore_id = @sourceStoreId and i.isTemplate = 1 and i.fk_status_id = 15 and i.itemType = 1
		set @rCode = 1
		set @rMsg = 'success'
	
		commit transaction T
	end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,ERROR_MESSAGE())
		rollback transaction T
	end catch
RETURN 0