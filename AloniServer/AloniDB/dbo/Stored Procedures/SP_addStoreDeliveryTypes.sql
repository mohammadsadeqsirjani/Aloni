CREATE PROCEDURE [dbo].[SP_addStoreDeliveryTypes]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@title as nvarchar(100),
    @cost as  money,
    @effectiveDeliveryCostOnInvoce as bit,
    @maxSupportedDistancForDelivery as int ,
    @minPriceForActiveDeliveryType as money ,
	@isActive as bit ,
	@id as bigint out 
AS
	begin try
		
		declare @storeLoc geography = (select [location] from TB_STORE where id = @storeId)
		if(@title is null or @cost is null or @effectiveDeliveryCostOnInvoce is null or @minPriceForActiveDeliveryType is null or @maxSupportedDistancForDelivery is null)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid data',OBJECT_NAME(@@PROCID),@clientLanguage,'Null data is not valid!'); 
			set @rCode = 0
			return 0
		end
		if(not exists(select id from TB_STORE where id = @storeId))
		begin
			set @rMsg = dbo.func_getSysMsg('invalid store',OBJECT_NAME(@@PROCID),@clientLanguage,'store not exist!'); 
			set @rCode = 0
			return 0
		end
		if(@storeLoc is null )
		begin
			set @rMsg = dbo.func_getSysMsg('invalid storeLocation',OBJECT_NAME(@@PROCID),@clientLanguage,'storeLocation not set!'); 
			set @rCode = 0
			return 0
		end
		if(exists(select id from TB_STORE_DELIVERYTYPES where fk_store_id = @storeId and title = @title))
		begin
			update TB_STORE_DELIVERYTYPES set isDeleted = 0,isActive = @isActive where  fk_store_id = @storeId and title = @title
			set @rMsg = 'success'
			set @rCode = 1
			set @id =(select id from TB_STORE_DELIVERYTYPES where fk_store_id = @storeId and title = @title)
			return
		end
		insert into TB_STORE_DELIVERYTYPES(fk_store_id,cost,includeCostOnInvoice,minOrderCost,radius,storeLocation,title,isActive)
					values( @storeId,@cost,@effectiveDeliveryCostOnInvoce,@minPriceForActiveDeliveryType,@maxSupportedDistancForDelivery,@storeLoc,@title,1)

		set @rMsg = 'success'
		set @rCode = 1
		set @id = SCOPE_IDENTITY()
	end try
	begin catch
		set @rMsg = dbo.func_getSysMsg('invalid title',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
		set @rCode = 0
	end catch

RETURN 0
