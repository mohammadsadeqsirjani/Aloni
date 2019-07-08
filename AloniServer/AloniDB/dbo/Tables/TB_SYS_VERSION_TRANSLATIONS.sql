CREATE TABLE [dbo].[TB_SYS_VERSION_TRANSLATIONS]
(
	[pk_osType] TINYINT NOT NULL, 
    [pk_fk_app_Id] TINYINT NOT NULL, 
    [pk_version] VARCHAR(60) NOT NULL, 
    [pk_lan] CHAR(2) NOT NULL, 
    [releasNote] TEXT NOT NULL, 
    CONSTRAINT [PK_TB_SYS_VERSION_TRANSLATIONS] PRIMARY KEY ([pk_osType], [pk_fk_app_Id], [pk_version], [pk_lan]), 
    CONSTRAINT [FK_TB_SYS_VERSION_TRANSLATIONS_TB_SYS_VERSION] FOREIGN KEY ([pk_osType],[pk_fk_app_Id],[pk_version]) REFERENCES [TB_SYS_VERSION]([pk_osType],[pk_fk_app_Id],[pk_version]) on delete cascade on update cascade, 
    CONSTRAINT [FK_TB_SYS_VERSION_TRANSLATIONS_TB_LANGUAGE] FOREIGN KEY ([pk_lan]) REFERENCES [TB_LANGUAGE]([id]), 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Major.Minor.HotFix',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_SYS_VERSION_TRANSLATIONS',
    @level2type = N'COLUMN',
    @level2name = N'pk_version'

	
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N' اخرین نسخه هر اپ را با هر سیستم عاملی در خود ذخیره میکندvel0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'';