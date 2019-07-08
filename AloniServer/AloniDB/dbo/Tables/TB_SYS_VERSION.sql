CREATE TABLE [dbo].[TB_SYS_VERSION]
(
    [pk_osType] TINYINT NOT NULL, 
    [pk_fk_app_Id] TINYINT NOT NULL, 
    [pk_version] VARCHAR(60) NOT NULL, 
    [releasNote] TEXT NOT NULL, 
    [isCritical] BIT NOT NULL, 
    [note] VARCHAR(250) NULL, 
    [start] DATETIME NOT NULL DEFAULT getdate(), 
    [isActive] BIT NOT NULL DEFAULT 1, 
    [downloadLink] NVARCHAR(500) NULL, 
    CONSTRAINT [FK_TB_SYS_VERSION_TB_APP] FOREIGN KEY ([pk_fk_app_Id]) REFERENCES TB_APP(id), 
    CONSTRAINT [PK_TB_SYS_VERSION] PRIMARY KEY ([pk_osType], [pk_fk_app_Id], [pk_version]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Major.Minor.HotFix',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_SYS_VERSION',
    @level2type = N'COLUMN',
    @level2name = N'pk_version'

	
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'اخرین نسخه اپ در هر سیستم عاملی را در خود ذخیره میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_SYS_VERSION';