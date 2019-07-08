CREATE TABLE [dbo].[TB_TYP_UNIT_TRANSLATIONS] (
    [id]    INT           NOT NULL,
    [lan]   CHAR (2)      NOT NULL,
    [title] NVARCHAR (50) NULL,
    CONSTRAINT [PK_TB_TYP_UNIT_TRANSLATIONS] PRIMARY KEY CLUSTERED ([id] ASC, [lan] ASC),
    CONSTRAINT [FK_TB_TYP_UNIT_TRANSLATIONS_TB_LANGUAGE] FOREIGN KEY ([lan]) REFERENCES [dbo].[TB_LANGUAGE] ([id]),
    CONSTRAINT [FK_TB_TYP_UNIT_TRANSLATIONS_TB_TYP_UNIT] FOREIGN KEY ([id]) REFERENCES [dbo].[TB_TYP_UNIT] ([id]) ON UPDATE CASCADE ON DELETE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'';




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شناسه واحد های اندازه گیری ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_TYP_UNIT_TRANSLATIONS',
    @level2type = N'COLUMN',
    @level2name = N'id'

	
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ترجمه واحد های اندازه گیری در این جدول ذخیره میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_UNIT_TRANSLATIONS';

