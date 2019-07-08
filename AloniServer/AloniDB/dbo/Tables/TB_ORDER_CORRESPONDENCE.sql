CREATE TABLE [dbo].[TB_ORDER_CORRESPONDENCE]
(
	[id] BIGINT NOT NULL PRIMARY KEY IDENTITY, 
    [fk_order_orderId] BIGINT NOT NULL,
    [fk_usr_senderUserId] BIGINT NOT NULL, 
    [fk_usr_Session_senderSessionId] BIGINT NOT NULL,
    [message] TEXT NOT NULL, 
    [saveDateTime] DATETIME NOT NULL DEFAULT getdate(), 
    [saveIp] VARCHAR(20) NULL, 
    [isTicket] BIT NOT NULL, 
    [isDeleted] BIT NOT NULL DEFAULT 0, 
    [fk_staff_senderStaffId] SMALLINT NULL, 
    [controlDateTime] DATETIME NULL, 
    CONSTRAINT [FK_TB_ORDER_CORRESPONDENCE_TB_ORDER] FOREIGN KEY ([fk_order_orderId]) REFERENCES [TB_ORDER]([id]), 
    CONSTRAINT [FK_TB_ORDER_CORRESPONDENCE_TB_USR] FOREIGN KEY ([fk_usr_senderUserId]) REFERENCES [TB_USR]([id]), 
    CONSTRAINT [FK_TB_ORDER_CORRESPONDENCE_TB_USR_SESSION] FOREIGN KEY ([fk_usr_Session_senderSessionId]) REFERENCES [TB_USR_SESSION]([id]), 
    CONSTRAINT [FK_TB_ORDER_CORRESPONDENCE_TB_STAFF] FOREIGN KEY ([fk_staff_senderStaffId]) REFERENCES [TB_STAFF]([id])
)

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول اطلاعات مربوط به تحوبل مرسوله ثبت میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_ORDER_CORRESPONDENCE';
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'سفارش دهنده',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_CORRESPONDENCE',
    @level2type = N'COLUMN',
    @level2name = N'fk_usr_senderUserId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'کد سفارش',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_CORRESPONDENCE',
    @level2type = N'COLUMN',
    @level2name = N'fk_order_orderId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'مامور تحویل کالا',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_CORRESPONDENCE',
    @level2type = N'COLUMN',
    @level2name = N'fk_staff_senderStaffId'