CREATE TABLE [dbo].[TB_TERMS_AND_CONDITIONS_TRANSLATIONS]
(
    [pk_fk_app_id] TINYINT NOT NULL, 
    [pk_version] MONEY NOT NULL, 
    [pk_lan] CHAR(2) NOT NULL, 
    [title] VARCHAR(150) NOT NULL, 
    [description] TEXT NOT NULL, 
    CONSTRAINT [FK_TB_TERMS_AND_CONDITIONS_TRANSLATIONS_TB_LANGUAGE] FOREIGN KEY ([pk_lan]) REFERENCES [TB_LANGUAGE]([id]), 
    CONSTRAINT [PK_TB_TERMS_AND_CONDITIONS_TRANSLATIONS] PRIMARY KEY ([pk_fk_app_id], [pk_version], [pk_lan]) 
)

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ترجمه شرایط به زبان های دیگر', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TERMS_AND_CONDITIONS_TRANSLATIONS';
