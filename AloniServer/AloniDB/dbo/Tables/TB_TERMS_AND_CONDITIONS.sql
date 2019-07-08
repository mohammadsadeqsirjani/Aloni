CREATE TABLE [dbo].[TB_TERMS_AND_CONDITIONS]
(
    [pk_fk_app_id] TINYINT NOT NULL, 
    [pk_version] MONEY NOT NULL, 
    [title] VARCHAR(50) NOT NULL, 
    [description] TEXT NOT NULL, 
    [saveDateTime] DATETIME NOT NULL DEFAULT getdate(), 
    [saveIp] VARCHAR(36) NULL, 
    [fk_usr_saveUser] BIGINT NULL , 
    [isActive] BIT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_TB_TERMS_AND_CONDITIONS_TB_USR] FOREIGN KEY ([fk_usr_saveUser]) REFERENCES [TB_USR]([id]), 
    CONSTRAINT [FK_TB_TERMS_AND_CONDITIONS_TB_APP] FOREIGN KEY ([pk_fk_app_id]) REFERENCES [TB_APP]([id]), 
    CONSTRAINT [PK_TB_TERMS_AND_CONDITIONS] PRIMARY KEY ([pk_fk_app_id], [pk_version])
)

GO

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'جدول شراایط و ضوابط قوانین  و مادههای موجود برای استفاده از اپ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TERMS_AND_CONDITIONS';