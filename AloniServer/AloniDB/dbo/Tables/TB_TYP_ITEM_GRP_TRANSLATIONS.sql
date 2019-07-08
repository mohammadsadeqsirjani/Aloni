CREATE TABLE [dbo].[TB_TYP_ITEM_GRP_TRANSLATIONS] (
    [id]    BIGINT        NOT NULL,
    [lan]   CHAR (2)      NOT NULL,
    [title] NVARCHAR (50) NULL,
    CONSTRAINT [PK_TB_ITEM_GRP_TRANSLATIONS] PRIMARY KEY CLUSTERED ([id] ASC, [lan] ASC),
    CONSTRAINT [FK_TB_ITEM_GRP_TRANSLATIONS_TB_LANGUAGE] FOREIGN KEY ([lan]) REFERENCES [dbo].[TB_LANGUAGE] ([id]),
    CONSTRAINT [FK_TB_ITEM_GRP_TRANSLATIONS_TB_TYP_ITEM_GRP] FOREIGN KEY ([id]) REFERENCES [dbo].[TB_TYP_ITEM_GRP] ([id]) ON UPDATE CASCADE ON DELETE CASCADE
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ترجمه جدول دسته بندی اختصاصی گروه کالا ها ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_ITEM_GRP_TRANSLATIONS';
