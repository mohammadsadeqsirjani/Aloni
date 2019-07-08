CREATE TABLE [dbo].[TB_USR_SESSION] (
    [id]               BIGINT       IDENTITY (1, 1) NOT NULL,
    [fk_usr_id]        BIGINT       NOT NULL,
    [fk_app_id]        TINYINT      NOT NULL,
    [token]            BINARY (64)  NULL,
    [deviceInfo]       VARCHAR (50) NULL,
    [lastActivityTime] DATETIME     NULL,
    [otpCode] CHAR(5) NULL, 
    [fk_status_id] INT NOT NULL, 
    [loginIp] VARCHAR(50) NULL, 
    [currentIp] VARCHAR(50) NULL, 
    [deviceId] VARCHAR(150) NULL, 
    [deviceId_appDefined] VARCHAR(150) NULL, 
    [osType] TINYINT NULL, 
    [password] BINARY(64) NULL, 
    [salt] CHAR(10) NULL, 
    [loc] [sys].[geography] NULL, 
    [loc_updTime] DATETIME NULL, 
    [appVersion] VARCHAR(60) NULL, 
    [pushNotiId] VARCHAR(250) NULL, 
    [tcVersion] MONEY NULL, 
    [fk_language_id] CHAR(2) NULL, 
    [saveDateTime] DATETIME NULL DEFAULT getdate(), 
    [pushNotiProvider] TINYINT NULL, 
    CONSTRAINT [PK_TB_USR_SESSION] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_USR_SESSION_TB_APP] FOREIGN KEY ([fk_app_id]) REFERENCES [dbo].[TB_APP] ([id]),
    CONSTRAINT [FK_TB_USR_SESSION_TB_USR] FOREIGN KEY ([fk_usr_id]) REFERENCES [dbo].[TB_USR] ([id]), 
    CONSTRAINT [FK_TB_USR_SESSION_TB_STATUS] FOREIGN KEY ([fk_status_id]) REFERENCES [dbo].[TB_STATUS]([id]), 
    CONSTRAINT [FK_TB_USR_SESSION_TB_TERMS_AND_CONDITIONS] FOREIGN KEY ([fk_app_id],[tcVersion]) REFERENCES [TB_TERMS_AND_CONDITIONS]([pk_fk_app_id],[pk_version]), 
    --CONSTRAINT [FK_TB_USR_SESSION_TB_SYS_VERSION] FOREIGN KEY ([osType],[fk_app_id],[appVersion]) REFERENCES [TB_SYS_VERSION]([pk_osType],[pk_fk_app_Id],[pk_version]), 
    CONSTRAINT [FK_TB_USR_SESSION_TB_LANGUAGE] FOREIGN KEY ([fk_language_id]) REFERENCES [TB_LANGUAGE]([id]), 
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 : android , 2 : ios , 3 :portal',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_USR_SESSION',
    @level2type = N'COLUMN',
    @level2name = N'osType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'کد ورژن قوانین و مقررات پذیرفته شده',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_USR_SESSION',
    @level2type = N'COLUMN',
    @level2name = N'tcVersion'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'کد ورژن جاری اپ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_USR_SESSION',
    @level2type = N'COLUMN',
    @level2name = N'appVersion'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'push noti provider - 1 : GCM , 2 : FCM , 3 : ONESIGNAL',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_USR_SESSION',
    @level2type = N'COLUMN',
    @level2name = N'pushNotiProvider'

	GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول اطلاعات مربوط به کاربر که از کدام وسیله به حساب کاربری خود دسترسی داشته است را ثبت میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_USR_SESSION';