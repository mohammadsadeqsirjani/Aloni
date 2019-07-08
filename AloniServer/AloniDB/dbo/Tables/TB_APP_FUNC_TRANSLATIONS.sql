CREATE TABLE [dbo].[TB_APP_FUNC_TRANSLATIONS] (
    [id]          VARCHAR (100)  NOT NULL,
    [lan]         CHAR (2)       NOT NULL,
    [description] NVARCHAR (500) NULL,
    CONSTRAINT [PK_TB_APP_FUNC_TRANSLATIONS] PRIMARY KEY CLUSTERED ([id] ASC, [lan] ASC),
    CONSTRAINT [FK_TB_APP_FUNC_TRANSLATIONS_TB_APP_FUNC] FOREIGN KEY ([id]) REFERENCES [dbo].[TB_APP_FUNC] ([id]) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT [FK_TB_APP_FUNC_TRANSLATIONS_TB_LANGUAGE] FOREIGN KEY ([lan]) REFERENCES [dbo].[TB_LANGUAGE] ([id])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'زبان انتخابی اپ هنگام ثبت نام',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_APP_FUNC_TRANSLATIONS',
    @level2type = N'COLUMN',
    @level2name = N'description'