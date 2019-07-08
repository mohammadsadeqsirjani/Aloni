CREATE TABLE [dbo].[TB_LOG_SMS]
(
	[id] BIGINT NOT NULL PRIMARY KEY IDENTITY, 
    [srcNo] VARCHAR(50) NULL, 
    [dstNo] VARCHAR(50) NOT NULL, 
    [msgBody] NVARCHAR(MAX) NOT NULL, 
    [trackingCode] VARCHAR(50) NULL, 
    [result] VARCHAR(MAX) NULL, 
    [sendTime] DATETIME NOT NULL DEFAULT getdate(), 
    [deliveryTime] DATETIME NULL, 
    [fk_usr_userId] BIGINT NULL, 
    [fk_smsPanel_id] INT NOT NULL, 
    CONSTRAINT [FK_TB_LOG_SMS_TB_USR] FOREIGN KEY ([fk_usr_userId]) REFERENCES [TB_USR]([id]), 
    CONSTRAINT [FK_TB_LOG_SMS_ToTB_SMSPANEL] FOREIGN KEY ([fk_smsPanel_id]) REFERENCES [TB_SMSPANEL]([id])
)
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'این جدول اطلاعات مربوط به پیامک های تاییدی که به سوی کاربر فرستاده میشود به صورت کامل ذخیره میشود ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_LOG_SMS';
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شماره مبدا ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_LOG_SMS',
    @level2type = N'COLUMN',
    @level2name = N'srcNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شماره کاربر',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_LOG_SMS',
    @level2type = N'COLUMN',
    @level2name = N'dstNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'پیام',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_LOG_SMS',
    @level2type = N'COLUMN',
    @level2name = N'msgBody'