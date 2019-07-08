CREATE TABLE [dbo].[TB_USR_LOG] (
    [id]             BIGINT   IDENTITY (1, 1) NOT NULL,
    [fk_event_id]    INT      NOT NULL,
    [fk_store_id]    BIGINT   NULL,
    [fk_item_id]     BIGINT   NULL,
    [saveDateTime]   DATETIME CONSTRAINT [DF_TB_LOG_saveDateTime] DEFAULT (getdate()) NOT NULL,
    [fk_sent_usr_id] BIGINT   NULL,
    [fk_dst_user_id] BIGINT   NULL,
    CONSTRAINT [PK_TB_LOG] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_USR_LOG_TB_EVENT] FOREIGN KEY ([fk_event_id]) REFERENCES [dbo].[TB_EVENT] ([id]),
    CONSTRAINT [FK_TB_USR_LOG_TB_ITEM] FOREIGN KEY ([fk_item_id]) REFERENCES [dbo].[TB_ITEM] ([id]),
    CONSTRAINT [FK_TB_USR_LOG_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_USR_LOG_TB_USR] FOREIGN KEY ([fk_sent_usr_id]) REFERENCES [dbo].[TB_USR] ([id]),
    CONSTRAINT [FK_TB_USR_LOG_TB_USR1] FOREIGN KEY ([fk_dst_user_id]) REFERENCES [dbo].[TB_USR] ([id])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول اطلاعات مریوط به ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'';

