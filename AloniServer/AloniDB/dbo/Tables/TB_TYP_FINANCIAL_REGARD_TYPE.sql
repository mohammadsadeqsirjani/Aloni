CREATE TABLE [dbo].[TB_TYP_FINANCIAL_REGARD_TYPE]
(
	[id] INT NOT NULL, 
    [title] VARCHAR(150) NOT NULL, 
    [fk_this_parentId] INT NULL, 
    CONSTRAINT [PK_TB_TYP_FINANCIAL_REGARD_TYPE] PRIMARY KEY ([id]), 
    CONSTRAINT [FK_TB_TYP_FINANCIAL_REGARD_TYPE_TB_TYP_FINANCIAL_REGARD_TYPE] FOREIGN KEY ([fk_this_parentId]) REFERENCES [TB_TYP_FINANCIAL_REGARD_TYPE]([id]) 
)

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'تمام پرداخت های انجام شده با عنوان پیام شان در این جدول ذخیره میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_FINANCIAL_REGARD_TYPE';
