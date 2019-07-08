CREATE TABLE [dbo].[TB_STORE_DELIVERYTYPES] (
    [id]                   BIGINT            IDENTITY (1, 1) NOT NULL,
    [fk_store_id]          BIGINT            NOT NULL,
    [title]                NVARCHAR (100)    NOT NULL,
    [cost]                 MONEY             NOT NULL,
    [includeCostOnInvoice] BIT               DEFAULT ((1)) NOT NULL,
    [storeLocation]        [sys].[geography] NOT NULL,
    [radius]               INT               NOT NULL,
    [minOrderCost]         MONEY             NOT NULL,
    [isActive]             BIT               DEFAULT ((1)) NOT NULL,
    [isDeleted]            BIT               DEFAULT ((0)) NOT NULL,
    [fk_deliveryMethod_id] SMALLINT          NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_DELIVERYTYPES_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_STORE_DELIVERYTYPES_TB_TYP_DELIVERY_METHOD] FOREIGN KEY ([fk_deliveryMethod_id]) REFERENCES [dbo].[TB_TYP_DELIVERY_METHOD] ([id])
);



GO

CREATE UNIQUE INDEX [IX_TB_STORE_DELIVERYTYPES_storeId_Title] ON [dbo].[TB_STORE_DELIVERYTYPES] ([fk_store_id],[title])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'تخفیف دارد یا ندارد',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE_DELIVERYTYPES',
    @level2type = N'COLUMN',
    @level2name = N'includeCostOnInvoice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'حداقل مقدار تخفیف',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE_DELIVERYTYPES',
    @level2type = N'COLUMN',
    @level2name = N'minOrderCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'بررسی شعاع تحویل سفارش',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE_DELIVERYTYPES',
    @level2type = N'COLUMN',
    @level2name = N'radius'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'نوع فرایند تخحویل سفارش',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE_DELIVERYTYPES',
    @level2type = N'COLUMN',
    @level2name = N'fk_deliveryMethod_id'

	
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'شیوه ارسال مرسوله را در خود ذخیره میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_DELIVERYTYPES';

