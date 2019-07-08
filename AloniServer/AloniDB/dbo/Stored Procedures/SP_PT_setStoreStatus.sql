-- =============================================
-- Author:		saeed m khorsand
-- Create date: 1396 10 03
-- Description:	return 4 table of store data
-- =============================================
CREATE PROCEDURE [dbo].[SP_PT_setStoreStatus]
	@clientLanguage as char(2) = null,
	@appId as tinyint = null,
	@clientIp as varchar(50) = null,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint ,
	@statusId as int
AS
BEGIN
	SET NOCOUNT ON;
	if(EXISTS(select 1 from TB_STORE WHERE id = @storeId AND (address IS NULL OR address_full IS NULL OR fk_city_id IS NULL OR fk_country_id IS NULL 
	                              OR title IS NULL OR fk_storePersonalityType_id IS NULL OR description IS NULL OR location IS NULL)) 
								  OR NOT EXISTS(select 1 from TB_STORE_ITEMGRP_PANEL_CATEGORY where pk_fk_store_id = @storeId) )
	begin
	set @rMsg = dbo.func_getSysMsg('error_invalid_message',OBJECT_NAME(@@PROCID),@clientLanguage,'وضعیت فروشگاه تغییر نیافت . برای تغییر وضعیت فروشگاه نام پنل ، شخصیت (حقوقی/حقیقی/سازمان)، دسته بندی پنل (سازمانی / شغلی)، درباره پنل ، کشور ، شهر ، آدرس دقیق و موقعیت مکانی پنل رو نقشه را مقدار دهی نمائید .'); 
	goto fail;
	end
	update TB_STORE
	set fk_status_id = @statusId
	where id = @storeId


	SET @rCode = 1;
    SET @rMsg = 'success.';
    RETURN 0;

    fail:
    SET @rCode = 0;

RETURN 0;
END