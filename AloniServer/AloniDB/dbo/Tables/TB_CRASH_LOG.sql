CREATE TABLE [dbo].[TB_CRASH_LOG] (
    [id]        BIGINT         IDENTITY (1, 1) NOT NULL,
    [errorCode] INT            NOT NULL,
    [source]    NVARCHAR (500) NULL,
    [message]   NVARCHAR (500) NULL,
    [app]       SMALLINT       CONSTRAINT [DF_TB_CRASH_LOG_app] DEFAULT ((1)) NOT NULL,
    [datetime_] DATETIME       CONSTRAINT [DF_TB_CRASH_LOG_datetime_] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_TB_CRASH_LOG] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 win app
2 android
3 ios
4 portal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_CRASH_LOG';

