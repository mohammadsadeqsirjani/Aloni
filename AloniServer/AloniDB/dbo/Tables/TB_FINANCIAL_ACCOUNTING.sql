CREATE TABLE [dbo].[TB_FINANCIAL_ACCOUNTING]
(
	[id] BIGINT NOT NULL IDENTITY, 
    [fk_UsrFinancialAccount_id] BIGINT NOT NULL, 
    [regardDsc] NVARCHAR(500) NOT NULL, 
    [debit] MONEY NOT NULL DEFAULT 0, 
    [credit] MONEY NOT NULL DEFAULT 0, 
    [fk_order_orderId] BIGINT NULL, 
    [orderDtlRowId] INT NULL, 
    [fk_orderHdr_id] BIGINT NULL, 
    [fk_orderDtl_id] BIGINT NULL, 
    [saveDatetime] DATETIME NOT NULL DEFAULT getdate(), 
    [fk_usr_saveUserId] BIGINT NOT NULL, 
    [note] NVARCHAR(MAX) NULL, 
    [fk_typFinancialRegardType_id] INT NOT NULL, 
    [fk_paymentPortalTransactionLog_tranId] BIGINT NULL, 
    CONSTRAINT [PK_TB_FINANCIAL_ACCOUNTING] PRIMARY KEY ([id]), 
    CONSTRAINT [FK_TB_FINANCIAL_ACCOUNTING_TB_USR_FINANCIALACCOUNT] FOREIGN KEY ([fk_UsrFinancialAccount_id]) REFERENCES [TB_FINANCIAL_ACCOUNT]([id]), 
    CONSTRAINT [FK_TB_FINANCIAL_ACCOUNTING_TB_ORDER_HDR] FOREIGN KEY ([fk_orderHdr_id]) REFERENCES [TB_ORDER_HDR]([id]) ,
	CONSTRAINT [FK_TB_FINANCIAL_ACCOUNTING_TB_ORDER_DTL] FOREIGN KEY ([fk_orderDtl_id]) REFERENCES [TB_ORDER_DTL]([id]), 
    CONSTRAINT [FK_TB_FINANCIAL_ACCOUNTING_TB_USR] FOREIGN KEY ([fk_usr_saveUserId]) REFERENCES [TB_USR]([id]), 
    CONSTRAINT [FK_TB_FINANCIAL_ACCOUNTING_TB_TYP_FINANCIAL_REGARD_TYPE] FOREIGN KEY ([fk_typFinancialRegardType_id]) REFERENCES [TB_TYP_FINANCIAL_REGARD_TYPE]([id]), 
    CONSTRAINT [FK_TB_FINANCIAL_ACCOUNTING_TB_PAYMENTPORTAL_TRANSACTION_LOG] FOREIGN KEY ([fk_paymentPortalTransactionLog_tranId]) REFERENCES [TB_PAYMENTPORTAL_TRANSACTION_LOG]([id]), 
    CONSTRAINT [FK_TB_FINANCIAL_ACCOUNTING_TB_ORDER] FOREIGN KEY ([fk_order_orderId]) REFERENCES [TB_ORDER]([id]) 
)

GO

CREATE INDEX [IX_TB_FINANCIAL_ACCOUNTING_vfk_orderId] ON [dbo].[TB_FINANCIAL_ACCOUNTING] ([fk_order_orderId])

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول اطلاعات مربوط به  فعالیت های بانکی هر کاربری که از فروشگاه خربد میکند را ثبت میکنند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_FINANTIOL_ACCOUNTING';
