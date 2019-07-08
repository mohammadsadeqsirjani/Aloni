CREATE TABLE [dbo].[TB_ORDER_HDR_BASE]
(
	[id] BIGINT NOT NULL PRIMARY KEY IDENTITY, 
    [orderId] BIGINT NOT NULL, 
    [fk_orderHdr_id] BIGINT NOT NULL, 
    [delivery_amount] MONEY NOT NULL, 
    [delivery_includeCostOnInvoice] BIT NULL, 
    [delivery_storeLocation] [sys].[geography] NULL, 
    [delivery_radius] INT NULL, 
    [delivery_minOrderCost] MONEY NULL, 
    CONSTRAINT [FK_TB_ORDER_HDR_BASE_TB_ORDER_HDR] FOREIGN KEY ([fk_orderHdr_id]) REFERENCES [TB_ORDER_HDR]([id])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N' هزینه ارسال - به عنوان حفظ سابقه ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_HDR_BASE',
    @level2type = N'COLUMN',
    @level2name = 'delivery_amount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'هزینه ارسال بر روی فاکتور لحاظ شود؟ از جدول ارسال مرسولات به عنوان حفظ سابقه',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_HDR_BASE',
    @level2type = N'COLUMN',
    @level2name = 'delivery_includeCostOnInvoice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'به عنوان حفظ سابقه - موقعیت مرکز انبار',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_HDR_BASE',
    @level2type = N'COLUMN',
    @level2name = 'delivery_storeLocation'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'به عنوان حفظ سابقه - شعاع پوشش روش ارسال مرسوله از موقعیت انبار',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_HDR_BASE',
    @level2type = N'COLUMN',
    @level2name = 'delivery_radius'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'به عنوان حفظ سابقه - حداقل مبلغ سفارش به منظور ارسال مرسوله با روش انتخابی',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_HDR_BASE',
    @level2type = N'COLUMN',
    @level2name = 'delivery_minOrderCost'
GO
