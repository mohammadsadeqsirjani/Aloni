CREATE TABLE [dbo].[TB_SYS_PUSHNOTIFICATION_TRANSLATIONS]
(
	[id] VARCHAR(50) NOT NULL , 
    [lan] CHAR(2) NOT NULL, 
    [heading] VARCHAR(MAX) NULL, 
    [content] VARCHAR(MAX) NULL, 
    CONSTRAINT [PK_TB_SYS_PUSHNOTIFICATION_TRANSLATIONS] PRIMARY KEY ([id], [lan]), 
    CONSTRAINT [FK_TB_SYS_PUSHNOTIFICATION_TRANSLATIONS_TB_SYS_PUSHNOTIFICATION] FOREIGN KEY ([id]) REFERENCES [TB_SYS_PUSHNOTIFICATION]([id]) on delete cascade on update cascade, 
    CONSTRAINT [FK_TB_SYS_PUSHNOTIFICATION_TRANSLATIONS_TB_LANGUAGE] FOREIGN KEY ([lan]) REFERENCES [TB_LANGUAGE]([id]) on delete cascade on update cascade
)

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'اعلان های موجود در اپ به زبان های موجود در دیتابیس', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_SYS_PUSHNOTIFICATION_TRANSLATIONS';