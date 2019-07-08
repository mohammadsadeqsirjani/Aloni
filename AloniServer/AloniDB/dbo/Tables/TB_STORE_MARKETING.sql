CREATE TABLE [dbo].[TB_STORE_MARKETING] (
    [id]              BIGINT         IDENTITY (1, 1) NOT NULL,
    [fk_store_id]     BIGINT         NOT NULL,
    [title]           VARCHAR (150)  NOT NULL,
    [minCommission]   DECIMAL (3, 2) NOT NULL,
    [maxCommission]   DECIMAL (3, 2) NOT NULL,
    [validityDate]    DATETIME       NOT NULL,
    [saveDatetime]    DATETIME       CONSTRAINT [DF_TB_STORE_MARKETING_saveDatetime] DEFAULT (getdate()) NOT NULL,
    [fk_save_user_id] BIGINT         NOT NULL,
    [fk_status_id]    INT            NOT NULL,
    CONSTRAINT [PK_TB_STORE_MARKETING] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_MARKETING_TB_STATUS] FOREIGN KEY ([fk_status_id]) REFERENCES [dbo].[TB_STATUS] ([id]),
    CONSTRAINT [FK_TB_STORE_MARKETING_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_STORE_MARKETING_TB_USR] FOREIGN KEY ([fk_save_user_id]) REFERENCES [dbo].[TB_USR] ([id])
);



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در چه فروشگاهی چه کسی با چه کمیسیونی مشغول بازاریابی است', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_MARKETING';



