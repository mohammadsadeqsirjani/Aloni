CREATE TABLE [dbo].[TB_STORE_CUSTOMER_GROUP]
(
	[id] BIGINT NOT NULL PRIMARY KEY IDENTITY, 
    [fk_store_id] BIGINT NOT NULL, 
    [title] VARCHAR(50) NOT NULL, 
    [discountPercent] MONEY NOT NULL, 
    [isActive] BIT NOT NULL DEFAULT 1, 
    [saveDateTime] DATETIME NOT NULL DEFAULT getdate(), 
    [saveIp] VARCHAR(50) NULL, 
    [color] VARCHAR(15) NULL, 
    CONSTRAINT [FK_TB_STORE_CUSTOMER_GROUP_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [TB_STORE]([id])
)


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'گروه هایی که در هر فروشگاه برای مشتریان در نظر گرفته میشود را در این جدول ذخیره میکنیم', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_CUSTOMER_GROUP';
