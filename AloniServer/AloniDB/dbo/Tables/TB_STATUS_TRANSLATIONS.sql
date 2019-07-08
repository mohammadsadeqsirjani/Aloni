CREATE TABLE [dbo].[TB_STATUS_TRANSLATIONS] (
    [id]    INT           NOT NULL,
    [lan]   CHAR (2)      NOT NULL,
    [title] NVARCHAR (50) NULL,
    CONSTRAINT [PK_TB_STATUS_TRANSLATIONS] PRIMARY KEY CLUSTERED ([id] ASC, [lan] ASC),
    CONSTRAINT [FK_TB_STATUS_TRANSLATIONS_TB_LANGUAGE] FOREIGN KEY ([lan]) REFERENCES [dbo].[TB_LANGUAGE] ([id]),
    CONSTRAINT [FK_TB_STATUS_TRANSLATIONS_TB_STATUS] FOREIGN KEY ([id]) REFERENCES [dbo].[TB_STATUS] ([id]) ON UPDATE CASCADE ON DELETE CASCADE
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'وضعیت تمام حالات را در اپ مشخص میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STATUS_TRANSLATIONS';

