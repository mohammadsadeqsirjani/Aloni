CREATE TABLE [dbo].[TB_TYP_STORE_TYPE_TRANSLATIONS] (
    [id]    INT           NOT NULL,
    [lan]   CHAR (2)      NOT NULL,
    [title] NVARCHAR (50) NULL,
    CONSTRAINT [PK_TB_STORE_TYPE_TRANSLATIONS] PRIMARY KEY CLUSTERED ([id] ASC, [lan] ASC),
    CONSTRAINT [FK_TB_STORE_TYPE_TRANSLATIONS_TB_LANGUAGE] FOREIGN KEY ([lan]) REFERENCES [dbo].[TB_LANGUAGE] ([id]),
    CONSTRAINT [FK_TB_STORE_TYPE_TRANSLATIONS_TB_TYP_STORE_TYPE] FOREIGN KEY ([id]) REFERENCES [dbo].[TB_TYP_STORE_TYPE] ([id]) ON UPDATE CASCADE ON DELETE CASCADE
);



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'دسته بندی فروشگاه را مشخص میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_STORE_TYPE_TRANSLATIONS';


