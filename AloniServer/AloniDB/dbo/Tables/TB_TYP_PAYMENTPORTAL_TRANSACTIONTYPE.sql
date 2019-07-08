CREATE TABLE [dbo].[TB_TYP_PAYMENTPORTAL_TRANSACTIONTYPE]
(
	[id] INT NOT NULL PRIMARY KEY, 
    [title] VARCHAR(50) NULL
)

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'دراین جدول حالت خرید از طریق اپ را مشخص میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_PAYMENTPORTAL_TRANSACTIONTYPE';
