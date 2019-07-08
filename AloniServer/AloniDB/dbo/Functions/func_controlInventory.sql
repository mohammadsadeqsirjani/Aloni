-- =============================================
-- Author:		Saman Ziamolki
-- Create date: 2019/01/27
-- Description:	خروجی این تابع مشخص می کند که برای یک فروشگاه و کالا آیا نیازی به کنترل موجودی هست یا خیر. مورد استفاده در روال سفارش
-- =============================================
CREATE FUNCTION [dbo].[func_controlInventory]
(
	@storeId bigint,
	@itemId bigint
)
RETURNS bit
AS
BEGIN
	declare @rs as bit;

	select @rs = siq.canBeSalesNegative from TB_STORE_ITEM_QTY as siq with(nolock)
	where siq.pk_fk_store_id = @storeId and siq.pk_fk_item_id = @itemId;

	if(@rs is not null)
		return ~@rs;

	select @rs = s.canBeSalesNegative from TB_STORE as s with(nolock)
	where s.id = @storeId;
	return ~isnull(@rs,0);
END
