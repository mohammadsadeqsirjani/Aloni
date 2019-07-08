CREATE TABLE [dbo].[TB_ORDER_DTL] (
    [id]             BIGINT       IDENTITY (1, 1) NOT NULL,
    [fk_order_id] BIGINT NOT NULL, 
    [fk_orderHdr_id] BIGINT       NOT NULL,
	[rowId] INT NOT NULL, 
    [fk_store_id] BIGINT NOT NULL, 
    [fk_item_id]     BIGINT       NOT NULL,
    [vfk_store_item_color_id]    VARCHAR (20) NULL,
    [vfk_store_item_size_id] NVARCHAR(500) NULL, 
    [vfk_store_item_warranty] BIGINT NULL, 
    [qty]            MONEY          NOT NULL,
    [sent] MONEY NOT NULL DEFAULT 0, 
    [delivered] MONEY NOT NULL DEFAULT 0, 
    [isVoid] BIT NOT NULL DEFAULT 0, 
    [received] MONEY NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_TB_ORDER_DTL] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_ORDER_DTL_TB_ORDER_HDR] FOREIGN KEY ([fk_orderHdr_id]) REFERENCES [dbo].[TB_ORDER_HDR] ([id]),
    CONSTRAINT [FK_TB_ORDER_DTL_TB_STORE_ITEM_QTY] FOREIGN KEY ([fk_store_id],[fk_item_id]) REFERENCES [TB_STORE_ITEM_QTY]([pk_fk_store_id],[pk_fk_item_id]), 
    CONSTRAINT [FK_TB_ORDER_DTL_TB_ORDER] FOREIGN KEY ([fk_order_id]) REFERENCES [TB_ORDER]([id]) 
);

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شناسه',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL',
    @level2type = N'COLUMN',
    @level2name = N'id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شناسه سربرگ سند سفارش',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL',
    @level2type = N'COLUMN',
    @level2name = N'fk_orderHdr_id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شناسه فروشگاه',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL',
    @level2type = N'COLUMN',
    @level2name = N'fk_store_id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شناسه کالای مورد نظر',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL',
    @level2type = N'COLUMN',
    @level2name = N'fk_item_id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شناسه رنگ مد نظر کاربر',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL',
    @level2type = N'COLUMN',
    @level2name = N'vfk_store_item_color_id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شناسه سایز مد نظر کاربر',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL',
    @level2type = N'COLUMN',
    @level2name = N'vfk_store_item_size_id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شناسه گارانتی مد نظر کاربر',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL',
    @level2type = N'COLUMN',
    @level2name = N'vfk_store_item_warranty'
GO

GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'مقدار - مثبت و منفی',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL',
    @level2type = N'COLUMN',
    @level2name = N'qty'
GO

GO

GO



GO

GO

GO

GO

GO

GO

GO

GO

GO

GO

GO

GO

GO

GO

GO

GO

GO

GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'مقدار تحویل',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL',
    @level2type = N'COLUMN',
    @level2name = N'delivered'
GO

GO

GO

GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شماره ردیف سفارش',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL',
    @level2type = N'COLUMN',
    @level2name = N'rowId'
GO

CREATE UNIQUE INDEX [IX_TB_ORDER_DTL_fk_orderHdrid_rowId] ON [dbo].[TB_ORDER_DTL] ([fk_orderHdr_id],[rowId])

GO

GO

GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شناسه سفارش',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL',
    @level2type = N'COLUMN',
    @level2name = 'fk_order_id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'ابطال؟',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL',
    @level2type = N'COLUMN',
    @level2name = N'isVoid'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'مقدار ارسال',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL',
    @level2type = N'COLUMN',
    @level2name = N'sent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'مقدار دریافت',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_DTL',
    @level2type = N'COLUMN',
    @level2name = 'received'

	GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول اطلاعات مریوط به جزئیات سفارش ثبت میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_ORDER_DTL';