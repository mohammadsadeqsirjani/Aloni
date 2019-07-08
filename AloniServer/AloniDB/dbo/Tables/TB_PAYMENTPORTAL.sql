CREATE TABLE [dbo].[TB_PAYMENTPORTAL]
(
	[id] INT NOT NULL PRIMARY KEY, 
    [fk_country_id] INT NOT NULL, 
    [url] VARCHAR(255) NOT NULL, 
    [isDefault] BIT NOT NULL DEFAULT 0, 
    [minimumAmount] MONEY NOT NULL, 
    [fk_financialAccount_destFinancialAccountId] BIGINT NOT NULL, 
    CONSTRAINT [FK_TB_PAYMENTPORTAL_TB_COUNTRY] FOREIGN KEY ([fk_country_id]) REFERENCES [TB_COUNTRY]([id])
)

GO

CREATE UNIQUE INDEX [IX_TB_PAYMENTPORTAL_fk_country_id_isDefault_UNQ] ON [dbo].[TB_PAYMENTPORTAL] ([fk_country_id],[isDefault]) where [isDefault] =1


	GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N' ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_PAYMENTPORTAL';