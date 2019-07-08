CREATE TABLE [dbo].[TB_EVENT_TRANSLATION] (
    [id]    INT           NOT NULL,
    [lan]   CHAR (2)      NOT NULL,
    [title] VARCHAR (250) NOT NULL,
    CONSTRAINT [PK_TB_EVENT_TRANSLATION] PRIMARY KEY CLUSTERED ([id] ASC, [lan] ASC),
    CONSTRAINT [FK_TB_EVENT_TRANSLATION_TB_EVENT_TRANSLATION] FOREIGN KEY ([id], [lan]) REFERENCES [dbo].[TB_EVENT_TRANSLATION] ([id], [lan]),
    CONSTRAINT [FK_TB_EVENT_TRANSLATION_TB_LANGUAGE] FOREIGN KEY ([id]) REFERENCES [dbo].[TB_EVENT] ([id])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ترجمه جدول رویداد هارا در خود جای داده است', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'';



