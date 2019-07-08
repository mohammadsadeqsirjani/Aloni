CREATE TABLE [dbo].[TB_STORE_ABOUT] (
    [id]             BIGINT        IDENTITY (1, 1) NOT NULL,
    [title]          VARCHAR (100) NOT NULL,
    [fk_language_id] CHAR (2)      NOT NULL,
    [description]    TEXT          NOT NULL,
    [fk_store_id]    BIGINT        NOT NULL,
    [saveDatetime]   DATETIME      CONSTRAINT [DF_TB_STORE_ABOUT_saveDatetime] DEFAULT (getdate()) NOT NULL,
    [fk_save_usr_id] BIGINT        NOT NULL,
    CONSTRAINT [PK_TB_STORE_ABOUT] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_ABOUT_TB_LANGUAGE] FOREIGN KEY ([fk_language_id]) REFERENCES [dbo].[TB_LANGUAGE] ([id]),
    CONSTRAINT [FK_TB_STORE_ABOUT_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_STORE_ABOUT_TB_USR] FOREIGN KEY ([fk_save_usr_id]) REFERENCES [dbo].[TB_USR] ([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'درباره مای هر فروشگاه که می تواند بیشتر از  یکی نیز باشد', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_ABOUT';





