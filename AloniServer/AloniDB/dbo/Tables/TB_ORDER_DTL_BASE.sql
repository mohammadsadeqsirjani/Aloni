CREATE TABLE [dbo].TB_ORDER_DTL_BASE
(
	[id] BIGINT NOT NULL PRIMARY KEY IDENTITY, 
    [orderId] BIGINT NOT NULL, 
    [rowId] INT NOT NULL, 
    [canBePurchasedWithoutWarranty] BIT NULL, 
    [cost_warranty] MONEY NULL, 
    [warrantyDays] INT NULL, 
    [cost_oneUnit_withoutDiscount] MONEY NULL, 
    [discount_minCnt] MONEY NULL, 
    [discount_percent] MONEY NULL, 
    [taxRate] MONEY NULL, 
    [item_includedTax] BIT NULL, 
    [store_calculateTax] BIT NULL, 
    [prepaymentPercent] MONEY NULL, 
    [cancellationPenaltyPercent] MONEY NULL, 
    [validityTimeOfOrder] INT NULL, 
    [store_taxIncludedInPrices] BIT NULL, 
    [store_promo_discount_percent] MONEY NULL, 
    [store_promo_dsc] VARCHAR(MAX) NULL, 
    [cost_color] MONEY NULL, 
    [cost_size] MONEY NULL 
)

GO

CREATE UNIQUE INDEX [IX_TB_ORDER_DTL_BASE_orderId_rowId] ON [dbo].TB_ORDER_DTL_BASE ([orderId],[rowId])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'$به عنوان حفظ سابقه » در زمان ثبت سند ، امکان فروش بدون گارانتی وجود داشته است یا خیر.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL_BASE',
    @level2type = N'COLUMN',
    @level2name = N'canBePurchasedWithoutWarranty'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'$به عنوان حفظ سابقه » هزینه گارانتی انتخابی_E',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL_BASE',
    @level2type = N'COLUMN',
    @level2name = N'cost_warranty'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'$به عنوان حفظ سابقه » تعداد روز گارانتی',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL_BASE',
    @level2type = N'COLUMN',
    @level2name = N'warrantyDays'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'$به عنوان حفظ سابقه » قیمت واقعی یک واحد کالا (بدون تخفیف)_B',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL_BASE',
    @level2type = N'COLUMN',
    @level2name = N'cost_oneUnit_withoutDiscount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'$به عنوان حفظ سابقه » حداقل مقدار به منظور اعمال درصد تخفیف_D',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL_BASE',
    @level2type = N'COLUMN',
    @level2name = N'discount_minCnt'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'$به عنوان حفظ سابقه » درصد تخفیف_C',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL_BASE',
    @level2type = N'COLUMN',
    @level2name = N'discount_percent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'$درصد مالیات بر ارزش افزوده فروشگاه_F',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL_BASE',
    @level2type = N'COLUMN',
    @level2name = N'taxRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'$کالا شامل مالیات می باشد یا خیر - جدول کالای فروشگاه_T',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL_BASE',
    @level2type = N'COLUMN',
    @level2name = N'item_includedTax'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'$تنظیمات فروشگاه_مالیات بر ارزش افزوده در فاکتور محاسبه شوند یا خیر - جدول فروشگاه_H',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL_BASE',
    @level2type = N'COLUMN',
    @level2name = N'store_calculateTax'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'$درصد پیش پرداخت کالا_S',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL_BASE',
    @level2type = N'COLUMN',
    @level2name = N'prepaymentPercent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'$درصد جریمه کنسلی از مبلغ پیش پرداخت_V',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL_BASE',
    @level2type = N'COLUMN',
    @level2name = N'cancellationPenaltyPercent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'$مدت زمان اعتبار سفارش (ساعت) می تواند نال باشد - از جدول STORE_ITEM_QTY - به منظور حفظ سابقه',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL_BASE',
    @level2type = N'COLUMN',
    @level2name = N'validityTimeOfOrder'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'$تنظیمات فروشگاه _ مالیات در قیمت ها لحاظ شده است_G',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL_BASE',
    @level2type = N'COLUMN',
    @level2name = N'store_taxIncludedInPrices'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'پروموشن_درصد تخفیف پیش فرض فروشگاه بر روی تمامی کالا ها',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL_BASE',
    @level2type = N'COLUMN',
    @level2name = 'store_promo_discount_percent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'پروموشن_توضیحات تخفیف پیش فرض فروشگاه بر روی تمامی کالا ها',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL_BASE',
    @level2type = N'COLUMN',
    @level2name = 'store_promo_dsc'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'$به عنوان حفظ سابقه - هزینه رنگ انتخابی',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL_BASE',
    @level2type = N'COLUMN',
    @level2name = N'cost_color'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'$به عنوان حفظ سابقه - هزینه سایز انتخابی',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL_BASE',
    @level2type = N'COLUMN',
    @level2name = N'cost_size'