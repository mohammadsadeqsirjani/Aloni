CREATE TABLE [dbo].[TB_GLOBALSETTINGS] (
    [pk_name]                 VARCHAR (50)  NOT NULL,
    [pk_area]                 VARCHAR (50)  NOT NULL,
    [value]                   VARCHAR (MAX) NULL,
    [lastModifyTime]          DATETIME      NULL,
    [fk_usr_lastModifyUserId] BIGINT        NULL,
    CONSTRAINT [PK_TB_GLOBALSETTINGS] PRIMARY KEY CLUSTERED ([pk_name] ASC, [pk_area] ASC),
    CONSTRAINT [FK_TB_GLOBALSETTINGS_TB_USR] FOREIGN KEY ([fk_usr_lastModifyUserId]) REFERENCES [dbo].[TB_USR] ([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول اطلاعات مربوط به تنظیمات سراسری ذخیره میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_GLOBALSETTINGS';
