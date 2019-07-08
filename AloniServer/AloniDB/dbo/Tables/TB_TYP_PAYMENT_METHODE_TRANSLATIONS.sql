CREATE TABLE [dbo].[TB_TYP_PAYMENT_METHODE_TRANSLATIONS]
(
	[id] TINYINT NOT NULL PRIMARY KEY, 
    [lan] CHAR(2) NOT NULL,
    [title] VARCHAR(50) NOT NULL, 
    CONSTRAINT [FK_TB_TYP_PAYMENT_METHODE_TRANSLATIONS_TB_TYP_PAYMENT_METHODE] FOREIGN KEY ([id]) REFERENCES [TB_TYP_PAYMENT_METHODE]([id]) on update cascade on delete cascade, 
    CONSTRAINT [FK_TB_TYP_PAYMENT_METHODE_TRANSLATIONS_TB_LANGUAGE] FOREIGN KEY ([lan]) REFERENCES [TB_LANGUAGE]([id])
)


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ترجمه راه های پرداخت بهای کالا می باشد ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_PAYMENT_METHODE_TRANSLATIONS';
