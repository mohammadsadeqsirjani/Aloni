CREATE TABLE [dbo].[TB_ITEM_TRANSLATIONS] (
    [id]             BIGINT         NOT NULL,
    [lan]            CHAR (2)       NOT NULL,
    [title]          NVARCHAR (50)  NULL,
    [ManufacturerCo] NVARCHAR (150) NULL,
    [technicalTitle] NVARCHAR (250) NULL,
    [review] TEXT NULL, 
    CONSTRAINT [PK_TB_ITEM_TRANSLATIONS] PRIMARY KEY CLUSTERED ([id] ASC, [lan] ASC),
    CONSTRAINT [FK_TB_ITEM_TRANSLATIONS_TB_ITEM] FOREIGN KEY ([id]) REFERENCES [dbo].[TB_ITEM] ([id]) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT [FK_TB_ITEM_TRANSLATIONS_TB_LANGUAGE] FOREIGN KEY ([lan]) REFERENCES [dbo].[TB_LANGUAGE] ([id])
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'نقد و بررسی',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ITEM_TRANSLATIONS',
    @level2type = N'COLUMN',
    @level2name = N'review'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'مشخصات فنی',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ITEM_TRANSLATIONS',
    @level2type = N'COLUMN',
    @level2name = N'technicalTitle'

	GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول اطلاعات مربوط به کالا ها به زبان های دیگر را داریم', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_ITEM_TRANSLATIONS';