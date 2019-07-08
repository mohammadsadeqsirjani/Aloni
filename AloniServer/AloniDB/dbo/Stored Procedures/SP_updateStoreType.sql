CREATE PROCEDURE [dbo].[SP_updateStoreType]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId bigint,
	@elzamTasvieFactorBeFactor as bit,
	@sabtSefareshFaghatTavasotMoshtarian as bit,
	@moshahedeKalaFaghatTavasotMoshtarian as bit,
	@namayeshPanelFaghatBeMoshtarianOzv as bit,
	@niazBeTaeedBarayeOzviatMoshtarian as bit
AS
	begin try
		update TB_STORE
		set
			onlyCustomersAreAbleToSeeItems = @moshahedeKalaFaghatTavasotMoshtarian,
			customerJoinNeedsConfirm = @niazBeTaeedBarayeOzviatMoshtarian,
			fk_store_type_id = case when @namayeshPanelFaghatBeMoshtarianOzv = 1 then 2 else 1 END,
			onlyCustomersAreAbleToSetOrder = @sabtSefareshFaghatTavasotMoshtarian,
			ordersNeedConfimBeforePayment = @elzamTasvieFactorBeFactor
		where 
			id= @storeId
		set @rCode = 1
		set @rMsg = 'success'

	end try
		
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
	end catch
RETURN 0
