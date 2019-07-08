CREATE TABLE [dbo].[TB_USR] (
    [id]                 BIGINT        IDENTITY (10000, 1) NOT NULL,
    [fname]              VARCHAR (50)  NOT NULL,
    [lname]              VARCHAR (50)  NULL,
    [mobile]             VARCHAR (50)  NOT NULL,
    [fk_country_id]      INT           NOT NULL,
    [fk_language_id]     CHAR (2)      NOT NULL,
    [saveTime]           DATETIME      DEFAULT (getdate()) NOT NULL,
    [saveIp]             VARCHAR (50)  NULL,
    [fk_introducer]      BIGINT        NULL,
    [id_str]             VARCHAR (10)  DEFAULT ([dbo].[func_RandomString]((10),(0))) NOT NULL,
    [fk_status_id]       INT           NOT NULL,
    [fk_cityId]          INT           NULL,
    [email]              VARCHAR (100) NULL,
    [reportingIsBlocked] BIT           NULL,
    CONSTRAINT [PK_TB_USR] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_USR_TB_CITY] FOREIGN KEY ([fk_cityId]) REFERENCES [dbo].[TB_CITY] ([id]),
    CONSTRAINT [FK_TB_USR_TB_COUNTRY] FOREIGN KEY ([fk_country_id]) REFERENCES [dbo].[TB_COUNTRY] ([id]),
    CONSTRAINT [FK_TB_USR_TB_LANGUAGE] FOREIGN KEY ([fk_language_id]) REFERENCES [dbo].[TB_LANGUAGE] ([id]),
    CONSTRAINT [FK_TB_USR_TB_STATUS] FOREIGN KEY ([fk_status_id]) REFERENCES [dbo].[TB_STATUS] ([id]),
    CONSTRAINT [FK_TB_USR_TB_USR] FOREIGN KEY ([fk_introducer]) REFERENCES [dbo].[TB_USR] ([id])
);










GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TB_USR_mobileUNQ]
    ON [dbo].[TB_USR]([mobile] ASC);






GO

CREATE UNIQUE INDEX [IX_TB_USR_id_str] ON [dbo].[TB_USR] ([id_str])

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'برای کاربرانی که توسط پورتال بلاک شده اند و قادر به ریپورت کردن پنل ها نیستند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_USR', @level2type = N'COLUMN', @level2name = N'reportingIsBlocked';


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'معرف در صورت وجود',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_USR',
    @level2type = N'COLUMN',
    @level2name = N'fk_introducer'

	
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'کاربران پس از ثبت نام در این جدول اطلاعاتشان ثبت میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_USR';

