CREATE TABLE [dbo].[TB_SYS_PUSHNOTIFICATION]
(
	[id] VARCHAR(50) NOT NULL PRIMARY KEY, 
    [fk_appFunc_id] VARCHAR(100) NOT NULL,
    [heading] VARCHAR(MAX) NULL, 
    [content] VARCHAR(MAX) NOT NULL, 
    [section] VARCHAR(50) NULL, 
    [action] VARCHAR(50) NULL, 
    CONSTRAINT [FK_TB_SYS_PUSHNOTIFICATION_TB_APP_FUNC] FOREIGN KEY ([fk_appFunc_id]) REFERENCES [TB_APP_FUNC]([id])
)


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'اعلان های موجود  اپ را در خود ذخیره میکند این امکان وجود دارد که این اعلان ها توسط پرتال مدیریتی اصلی آلونی قابل تغییر  و مدیریت می باشند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_SYS_PUSHNOTIFICATION';