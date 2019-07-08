CREATE TABLE [dbo].[TB_TYP_FINANCIAL_REGARD_TYPE_TRANSLATIONS]
(
	[id] INT NOT NULL, 
    [lan] CHAR(2) NOT NULL, 
    [title] NVARCHAR(50) NOT NULL, 
    CONSTRAINT [PK_TB_TYP_FINANCIAL_REGARD_TYPE_TRANSLATIONS] PRIMARY KEY ([id], [lan]), 
    CONSTRAINT [FK_TB_TYP_FINANCIAL_REGARD_TYPE_TRANSLATIONS_TB_LANGUAGE] FOREIGN KEY ([lan]) REFERENCES [TB_LANGUAGE]([id]), 
    CONSTRAINT [FK_TB_TYP_FINANCIAL_REGARD_TYPE_TRANSLATIONS_TB_TYP_FINANCIAL_REGARD_TYPE] FOREIGN KEY ([id]) REFERENCES [TB_TYP_FINANCIAL_REGARD_TYPE]([id]) on update cascade on delete cascade 
)

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'تمام پرداخت های انجام شده با عنوان پیام شان در این جدول ذخیره میشود    ترجمه تمام چرداخت ها', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_FINANCIAL_REGARD_TYPE_TRANSLATIONS';
