CREATE TABLE [dbo].[TB_ORDER_HDR] (
    [id]              BIGINT NOT NULL IDENTITY,
    [fk_order_orderId] BIGINT NOT NULL, 
    [fk_docType_id] SMALLINT NOT NULL, 
    [saveDateTime]    DATETIME NOT NULL DEFAULT getdate(),
    [fk_usrSession_id] BIGINT NOT NULL, 
    [saveIp] VARCHAR(255) NULL, 
    [fk_deliveryTypes_id] BIGINT NULL, 
    [onlinePaymentId] VARCHAR(50) NULL, 
    [fk_paymentPortal_id] INT NULL, 
    [isVoid] BIT NOT NULL DEFAULT 0, 
    [fk_address_id] BIGINT NULL, 
    [fk_staff_operatorStaffId] SMALLINT NULL, 
    CONSTRAINT [FK_TB_ORDER_HDR_TB_STORE_DELIVERYTYPES] FOREIGN KEY ([fk_deliveryTypes_id]) REFERENCES [TB_STORE_DELIVERYTYPES]([id]), 
    CONSTRAINT [FK_TB_ORDER_HDR_TB_USR_SESSION_SAVESESSIONID] FOREIGN KEY ([fk_usrSession_id]) REFERENCES [TB_USR_SESSION]([id]), 
    CONSTRAINT [PK_TB_ORDER_HDR] PRIMARY KEY ([id]), 
    CONSTRAINT [FK_TB_ORDER_HDR_TB_TYP_ORDER_DOC_TYPE] FOREIGN KEY ([fk_docType_id]) REFERENCES [TB_TYP_ORDER_DOC_TYPE]([id]), 
    CONSTRAINT [FK_TB_ORDER_HDR_TB_PAYMENTPORTAL] FOREIGN KEY ([fk_paymentPortal_id]) REFERENCES [TB_PAYMENTPORTAL]([id]), 
    CONSTRAINT [FK_TB_ORDER_HDR_TB_ORDER] FOREIGN KEY ([fk_order_orderId]) REFERENCES [TB_ORDER]([id]), 
    CONSTRAINT [FK_TB_ORDER_HDR_TB_ORDER_ADDRESS] FOREIGN KEY ([fk_address_id]) REFERENCES [TB_ORDER_ADDRESS]([id])


);

GO

--CREATE UNIQUE INDEX [IX_TB_ORDER_HDR_OrderID_DocRow] ON [dbo].[TB_ORDER_HDR] ([orderId],[docRow])

GO

GO

GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N' در ایجاد سند خرید با 1 پر شود. با ثبت نهایی سفارش نیز همان 1 میماند.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_HDR',
    @level2type = N'COLUMN',
    @level2name = N'fk_docType_id'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'آدرس آی پی ایجاد کننده سند',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_HDR',
    @level2type = N'COLUMN',
    @level2name = N'saveIp'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شناسه نوع ارسال مرسولات',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_HDR',
    @level2type = N'COLUMN',
    @level2name = N'fk_deliveryTypes_id'
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
    @value = N'شناسه جلسه دستگاه ثبت کننده سند',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_HDR',
    @level2type = N'COLUMN',
    @level2name = N'fk_usrSession_id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'زمان ثبت',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_HDR',
    @level2type = N'COLUMN',
    @level2name = N'saveDateTime'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شناسه سفارش',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_HDR',
    @level2type = N'COLUMN',
    @level2name = 'fk_order_orderId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شناسه سربرگ سفارش',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_HDR',
    @level2type = N'COLUMN',
    @level2name = N'id'
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
    @value = N'شناسه پرداخت آنلاین',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_HDR',
    @level2type = N'COLUMN',
    @level2name = N'onlinePaymentId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شناسه درگاه پرداخت مورد استفاده',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_HDR',
    @level2type = N'COLUMN',
    @level2name = N'fk_paymentPortal_id'
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
    @value = N'ابطال شده است',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_HDR',
    @level2type = N'COLUMN',
    @level2name = N'isVoid'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شناسه آدرس',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_HDR',
    @level2type = N'COLUMN',
    @level2name = N'fk_address_id'
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شناسه سمت کاربر عامل (ثبت کننده) سند',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_HDR',
    @level2type = N'COLUMN',
    @level2name = N'fk_staff_operatorStaffId'