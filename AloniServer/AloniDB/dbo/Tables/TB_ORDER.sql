CREATE TABLE [dbo].[TB_ORDER]
(
	[id] BIGINT NOT NULL PRIMARY KEY IDENTITY, 
    [id_str] VARCHAR(36) NOT NULL, 
    [fk_usr_customerId] BIGINT NOT NULL, 
    [fk_store_storeId] BIGINT NOT NULL, 
    [fk_status_statusId] INT NOT NULL, 
    [saveDateTime] DATETIME NOT NULL DEFAULT getdate(), 
    [fk_userSession_saveUserSessionId] BIGINT NOT NULL, 
    [saveUserIpAddress] VARCHAR(50) NULL, 
    [isSecurePayment] BIT NOT NULL, 
    [isTwoStepPayment] BIT NULL, 
    [fk_usr_reviewerUserId] BIGINT NULL, 
    [fk_paymentMethode_id] TINYINT NULL, 
    [customerMsg] TEXT NULL, 
    [reviewDateTime] DATETIME NULL, 
    [lastDeliveryDateTime] DATETIME NULL, 
    [submitDateTime] DATETIME NULL, 
    CONSTRAINT [FK_TB_ORDER_TB_USR_CSTMR] FOREIGN KEY ([fk_usr_customerId]) REFERENCES [TB_USR]([id]), 
    CONSTRAINT [FK_TB_ORDER_TB_STORE] FOREIGN KEY ([fk_store_storeId]) REFERENCES [TB_STORE]([id]), 
    CONSTRAINT [FK_TB_ORDER_TB_STATUS_ORDERSTATUS] FOREIGN KEY ([fk_status_statusId]) REFERENCES [TB_STATUS]([id]), 
    CONSTRAINT [FK_TB_ORDER_TB_USR_REVIEWER] FOREIGN KEY ([fk_usr_reviewerUserId]) REFERENCES [TB_USR]([id]), 
    CONSTRAINT [FK_TB_ORDER_TB_TYP_PAYMENT_METHODE] FOREIGN KEY ([fk_paymentMethode_id]) REFERENCES [TB_TYP_PAYMENT_METHODE]([id]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'در زمان ایجاد سفارش متناسب با وضعیت سرتیفیکیت فروشگاه مشخص می شود و در زمان ثبت / قطعی شدن سبد خرید مجددا بررسی میشود و در صورتی که سرتیفیکیت پرداخت امن وجود نداشت خطا داده می شود',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER',
    @level2type = N'COLUMN',
    @level2name = N'isSecurePayment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'پرداخت دو مرحله ای است',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER',
    @level2type = N'COLUMN',
    @level2name = 'isTwoStepPayment'
GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شناسه نمایشی',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER',
    @level2type = N'COLUMN',
    @level2name = 'id_str'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'کاربر بررسی کننده سفارش',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER',
    @level2type = N'COLUMN',
    @level2name = N'fk_usr_reviewerUserId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'روش پرداخت انتخابی خریدار',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER',
    @level2type = N'COLUMN',
    @level2name = N'fk_paymentMethode_id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'پیام مشتری',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER',
    @level2type = N'COLUMN',
    @level2name = N'customerMsg'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'زمان بررسی سفارش',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER',
    @level2type = N'COLUMN',
    @level2name = N'reviewDateTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'زمان آخرین تحویل',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER',
    @level2type = N'COLUMN',
    @level2name = N'lastDeliveryDateTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'زمان تایید نهایی سفارش توسط مشتری',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER',
    @level2type = N'COLUMN',
    @level2name = N'submitDateTime'