CREATE TABLE [dbo].[TB_ITEM_TECHNICALINFO_TRANSLATIONS] (
    [itemId]          BIGINT         NOT NULL,
    [technicalInfoId] BIGINT         NOT NULL,
    [lan]             CHAR (2)       NOT NULL,
    [strValue]        NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_TB_ITEM_TECHNICALINFO_TRANSLATIONS] PRIMARY KEY CLUSTERED ([itemId] ASC, [technicalInfoId] ASC, [lan] ASC),
    CONSTRAINT [FK_TB_ITEM_TECHNICALINFO_TRANSLATIONS_TB_ITEM_TECHNICALINFO] FOREIGN KEY ([itemId], [technicalInfoId]) REFERENCES [dbo].[TB_ITEM_TECHNICALINFO] ([pk_fk_item_id], [pk_fk_technicalInfo_id])  ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT [FK_TB_ITEM_TECHNICALINFO_TRANSLATIONS_TB_LANGUAGE] FOREIGN KEY ([lan]) REFERENCES [dbo].[TB_LANGUAGE] ([id])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول اطلاعات مربوط به حدول مشخصات فنی هر  کالا ترجمه میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TECHNICALINFOINFO_TRANSLATIONS';