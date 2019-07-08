CREATE TABLE [dbo].[TB_CURRENCY_TRANSLATIONS]
(
	[id] INT NOT NULL , 
    [lan] CHAR(2) NOT NULL, 
    [title] VARCHAR(50) NOT NULL, 
    CONSTRAINT [FK_TB_CURRENCY_TRANSLATIONS_TB_CURRENCY] FOREIGN KEY ([id]) REFERENCES [TB_CURRENCY]([id]) on delete cascade on update cascade, 
    CONSTRAINT [FK_TB_CURRENCY_TRANSLATIONS_TB_LANGUAGE] FOREIGN KEY ([lan]) REFERENCES [TB_LANGUAGE]([id]) on delete cascade on update cascade, 
    CONSTRAINT [PK_TB_CURRENCY_TRANSLATIONS] PRIMARY KEY ([id], [lan])
)

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول ترجمه جدول واحد پولها ذخیره میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_CURRENCY_TRANSLATIONS';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول ترجمه جدول واحد پولها ذخیره میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_CURRENCY_TRANSLATIONS';

