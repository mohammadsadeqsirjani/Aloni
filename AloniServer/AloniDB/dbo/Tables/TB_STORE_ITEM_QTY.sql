CREATE TABLE [dbo].[TB_STORE_ITEM_QTY] (
    [pk_fk_store_id]                BIGINT            NOT NULL,
    [pk_fk_item_id]                 BIGINT            NOT NULL,
    [qty]                           MONEY             CONSTRAINT [DF_TB_STORE_ITEM_QTY_qty] DEFAULT ((0)) NOT NULL,
    [orderPoint]                    MONEY             NULL,
    [inventoryControl]              BIT               CONSTRAINT [DF_TB_STORE_ITEM_QTY_inventoryControl] DEFAULT ((1)) NOT NULL,
    [price]                         MONEY             CONSTRAINT [DF_TB_STORE_ITEM_QTY_price] DEFAULT ((0)) NOT NULL,
    [fk_country_Manufacturer]       INT               NULL,
    [ManufacturerCo]                NVARCHAR (250)    NULL,
    [localBarcode]                  VARCHAR (150)     NULL,
    [fk_status_id]                  INT               NOT NULL,
    [hasDelivery]                   BIT               CONSTRAINT [DF_TB_STORE_ITEM_QTY_hasDelivery] DEFAULT ((0)) NOT NULL,
    [isNotForSelling]               BIT               CONSTRAINT [DF_TB_STORE_ITEM_QTY_isNotForSelling] DEFAULT ((0)) NOT NULL,
    [discount_minCnt]               INT               NULL,
    [discount_percent]              MONEY             NULL,
    [includedTax]                   BIT               CONSTRAINT [DF_TB_STORE_ITEM_QTY_includedTax] DEFAULT ((1)) NOT NULL,
    [prepaymentPercent]             MONEY             CONSTRAINT [DF_TB_STORE_ITEM_QTY_prepaymentPercent] DEFAULT ((0)) NOT NULL,
    [cancellationPenaltyPercent]    MONEY             CONSTRAINT [DF_TB_STORE_ITEM_QTY_cancellationPenaltyPercent] DEFAULT ((0)) NOT NULL,
    [validityTimeOfOrder]           INT               NULL,
    [importerCo]                    NVARCHAR (50)     NULL,
    [hasWarranty]                   BIT               DEFAULT ((0)) NOT NULL,
    [canBePurchasedWithoutWarranty] BIT               DEFAULT ((1)) NOT NULL,
    [dontShowinginStoreItem]        BIT               CONSTRAINT [DF_TB_STORE_ITEM_QTY_dontShowinginStoreItem] DEFAULT ((0)) NOT NULL,
    [saveDateTime]                  DATETIME          CONSTRAINT [DF_TB_STORE_ITEM_QTY_saveDateTime] DEFAULT (getdate()) NOT NULL,
    [uniqueBarcode]                 NVARCHAR (50)     NULL,
    [doNotShowUniqueBarcode]        BIT               CONSTRAINT [DF_TB_STORE_ITEM_QTY_doNotShowUniqueBarcode] DEFAULT ((0)) NULL,
    [fk_status_shiftStatus]         INT               NULL,
    [location]                      [sys].[geography] NULL,
    [address]                       NVARCHAR (250)    NULL,
    [commentCntPerUser]             INT               NULL,
    [commentCntPerDayPerUser]       INT               NULL,
    [canBeSalesNegative] BIT NULL, 
    CONSTRAINT [PK_TB_STORE_ITEM_QTY] PRIMARY KEY CLUSTERED ([pk_fk_store_id] ASC, [pk_fk_item_id] ASC),
    CONSTRAINT [FK_TB_STORE_ITEM_QTY_TB_COUNTRY] FOREIGN KEY ([fk_country_Manufacturer]) REFERENCES [dbo].[TB_COUNTRY] ([id]),
    CONSTRAINT [FK_TB_STORE_ITEM_QTY_TB_ITEM] FOREIGN KEY ([pk_fk_item_id]) REFERENCES [dbo].[TB_ITEM] ([id]),
    CONSTRAINT [FK_TB_STORE_ITEM_QTY_TB_STATUS] FOREIGN KEY ([fk_status_id]) REFERENCES [dbo].[TB_STATUS] ([id]),
    CONSTRAINT [FK_TB_STORE_ITEM_QTY_TB_STATUS_shifStatus] FOREIGN KEY ([fk_status_shiftStatus]) REFERENCES [dbo].[TB_STATUS] ([id]),
    CONSTRAINT [FK_TB_STORE_ITEM_QTY_TB_STORE] FOREIGN KEY ([pk_fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول تعداد هر کالا به همراه اطلاعات دیگری از کالا را در هر فروشگاه را شامل میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_ITEM_QTY';




















GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'موجودی کنترل شود؟ جهت دریافت سفارش', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_ITEM_QTY', @level2type = N'COLUMN', @level2name = N'inventoryControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'مقدار جدول item را اورراید میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_ITEM_QTY', @level2type = N'COLUMN', @level2name = N'ManufacturerCo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'مقدار جدول item را اورراید میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_ITEM_QTY', @level2type = N'COLUMN', @level2name = N'fk_country_Manufacturer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'مدت اعتبار سفارش', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_ITEM_QTY', @level2type = N'COLUMN', @level2name = N'validityTimeOfOrder';


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'بدون گارانتی قابل خرید است؟',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE_ITEM_QTY',
    @level2type = N'COLUMN',
    @level2name = N'canBePurchasedWithoutWarranty'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'وضعیت شیفت (حضور یا عدم حضور اشخاص)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE_ITEM_QTY',
    @level2type = N'COLUMN',
    @level2name = N'fk_status_shiftStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'موقعیت کالا',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE_ITEM_QTY',
    @level2type = N'COLUMN',
    @level2name = N'location'
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20181216-142703]
    ON [dbo].[TB_STORE_ITEM_QTY]([pk_fk_store_id] ASC, [pk_fk_item_id] ASC, [price] ASC);

