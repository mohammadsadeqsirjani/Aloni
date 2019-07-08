CREATE TABLE [dbo].[TB_STAFF_TRANSLATIONS] (
    [id]    SMALLINT      NOT NULL,
    [lan]   CHAR (2)      NOT NULL,
    [title] NVARCHAR (50) NULL,
    CONSTRAINT [PK_TB_STAFF_TRANSLATIONS] PRIMARY KEY CLUSTERED ([id] ASC, [lan] ASC),
    CONSTRAINT [FK_TB_STAFF_TRANSLATIONS_TB_LANGUAGE] FOREIGN KEY ([lan]) REFERENCES [dbo].[TB_LANGUAGE] ([id]),
    CONSTRAINT [FK_TB_STAFF_TRANSLATIONS_TB_STAFF] FOREIGN KEY ([id]) REFERENCES [dbo].[TB_STAFF] ([id]) ON UPDATE CASCADE ON DELETE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'جدول رتبه بندی کارکنان', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STAFF_TRANSLATIONS';

