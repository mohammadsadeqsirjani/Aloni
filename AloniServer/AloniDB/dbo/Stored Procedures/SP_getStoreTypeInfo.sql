CREATE PROCEDURE [dbo].[SP_getStoreTypeInfo]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = 0,
	@search as nvarchar(100)=null,
	@parent as varchar(20) = null ,
	@userId as bigint,
	@storeId as bigint
AS
	set nocount on;
	select
			onlyCustomersAreAbleToSeeItems moshahedeKalaFaghatTavasotMoshtarian,
			customerJoinNeedsConfirm  niazBeTaeedBarayeOzviatMoshtarian,
			case when fk_store_type_id = 1 then 0 else 1 END namayeshPanelFaghatBeMoshtarianOzv,
			onlyCustomersAreAbleToSetOrder sabtSefareshFaghatTavasotMoshtarian,
			ordersNeedConfimBeforePayment elzamTasvieFactorBeFactor
	from TB_STORE
		where 
			id= @storeId
RETURN 0
