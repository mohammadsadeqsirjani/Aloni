CREATE PROCEDURE [dbo].[SP_updateStoreDeliveryTypes]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@title as nvarchar(100),
    @cost as  money,
    @effectiveDeliveryCostOnInvoce as bit,
    @maxSupportedDistancForDelivery as int ,
    @minPriceForActiveDeliveryType as money ,
	@isActive as bit ,
	@id as bigint 
AS
	begin try
			if(@title is null or @cost is null or @effectiveDeliveryCostOnInvoce is null or @minPriceForActiveDeliveryType is null or @maxSupportedDistancForDelivery is null)
			begin
				set @rMsg = dbo.func_getSysMsg('invalid data',OBJECT_NAME(@@PROCID),@clientLanguage,'Null data is not valid!'); 
				set @rCode = 0
				return 0
			end
			update TB_STORE_DELIVERYTYPES set
			 includeCostOnInvoice = @effectiveDeliveryCostOnInvoce,	  
			 minOrderCost = @minPriceForActiveDeliveryType ,			  
			 cost = @cost ,					  
			 title = @title,
			 radius = @maxSupportedDistancForDelivery,
			 isActive =ISNULL(@isActive,1)
			 where  id = @id	
			 set @rCode = 1
			 set @rMsg = 'success'		  
	end try	
	begin catch
		set @rMsg = dbo.func_getSysMsg('invalid title',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
		set @rCode = 0
	
	end catch
RETURN 0
