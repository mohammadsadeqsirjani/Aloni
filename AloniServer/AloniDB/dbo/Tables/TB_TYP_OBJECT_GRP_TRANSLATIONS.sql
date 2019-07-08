CREATE TABLE [dbo].[TB_TYP_OBJECT_GRP_TRANSLATIONS] (
    [id]    BIGINT         NOT NULL,
    [lan]   CHAR (2)       NOT NULL,
    [title] NVARCHAR (150) NOT NULL,
    CONSTRAINT [PK_TB_TYP_OBJECT_GRP_TRANSLATIONS] PRIMARY KEY CLUSTERED ([id] ASC, [lan] ASC),
    CONSTRAINT [FK_TB_TYP_OBJECT_GRP_TRANSLATIONS_TB_TYP_Object_Grp] FOREIGN KEY ([id]) REFERENCES [dbo].[TB_TYP_OBJECT_GRP] ([id])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ترجمه جدول دسته بندی زیر گروه های فروسگاه ها', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_OBJECT_GRP_TRANSLATIONS';
