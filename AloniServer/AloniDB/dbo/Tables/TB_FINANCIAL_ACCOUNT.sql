CREATE TABLE [dbo].[TB_FINANCIAL_ACCOUNT]
(
	[id] BIGINT NOT NULL IDENTITY , 
    [fk_typFinancialAccountType_id] SMALLINT NOT NULL,
    [fk_usr_userId] BIGINT NULL, 
	 [fk_store_id]  BIGINT         NULL,
    [fk_status_id] INT NOT NULL, 
    [title] NVARCHAR(500) NOT NULL, 
    [fk_currency_id] INT NULL, 
    CONSTRAINT [PK_TB_FINANCIAL_ACCOUNT] PRIMARY KEY ([id]), 
    CONSTRAINT [FK_TB_FINANCIAL_ACCOUNT_TB_USR] FOREIGN KEY ([fk_usr_userId]) REFERENCES [TB_USR]([id]), 
	    CONSTRAINT [FK_TB_FINANCIAL_ACCOUNT_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_FINANCIAL_ACCOUNT_TB_TYP_FINANCIAL_ACCOUNT_TYPE] FOREIGN KEY ([fk_typFinancialAccountType_id]) REFERENCES [TB_TYP_FINANCIAL_ACCOUNT_TYPE]([id]), 
    CONSTRAINT [FK_TB_FINANCIAL_ACCOUNT_TB_CURRENCY] FOREIGN KEY ([fk_currency_id]) REFERENCES [TB_CURRENCY]([id])
)

GO

CREATE UNIQUE INDEX [IX_TB_FINANCIAL_ACCOUNT_fk_usr_fk_accType] ON [dbo].[TB_FINANCIAL_ACCOUNT] ([fk_typFinancialAccountType_id],[fk_usr_userId]) where fk_usr_userId is not null
GO
CREATE UNIQUE INDEX [IX_TB_FINANCIAL_ACCOUNT_fk_store_fk_accType] ON [dbo].[TB_FINANCIAL_ACCOUNT] ([fk_typFinancialAccountType_id],[fk_store_id]) where fk_store_id is not null

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'نوع ارز حساب',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_FINANCIAL_ACCOUNT',
    @level2type = N'COLUMN',
    @level2name = N'fk_currency_id'

	GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول اطلاعات مربوط حساب های مالی هر فروشگاه ثبت میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_FINATIAL_ACCOUNT';