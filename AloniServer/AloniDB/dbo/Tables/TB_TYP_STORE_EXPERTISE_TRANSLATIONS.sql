﻿CREATE TABLE [dbo].[TB_TYP_STORE_EXPERTISE_TRANSLATIONS] (
    [id]    INT           NOT NULL,
    [lan]   CHAR (2)      NOT NULL,
    [title] NVARCHAR (50) NULL,
    CONSTRAINT [PK_TB_TYP_STORE_EXPERTISE_TRANSLATIONS] PRIMARY KEY CLUSTERED ([id] ASC, [lan] ASC),
    CONSTRAINT [FK_TB_TYP_STORE_EXPERTISE_TRANSLATIONS_TB_LANGUAGE] FOREIGN KEY ([lan]) REFERENCES [dbo].[TB_LANGUAGE] ([id]),
    CONSTRAINT [FK_TB_TYP_STORE_EXPERTISE_TRANSLATIONS_TB_TYP_STORE_EXPERTISE] FOREIGN KEY ([id]) REFERENCES [dbo].[TB_TYP_STORE_EXPERTISE] ([id]) ON UPDATE CASCADE ON DELETE CASCADE
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ترجمه دسته بندی کالاها', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_STORE_EXPERTISE_TRANSLATIONS';
