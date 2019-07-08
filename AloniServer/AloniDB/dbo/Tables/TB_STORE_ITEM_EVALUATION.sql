CREATE TABLE [dbo].[TB_STORE_ITEM_EVALUATION] (
    [id]               BIGINT       IDENTITY (1, 1) NOT NULL,
    [fk_store_id]      BIGINT       NOT NULL,
    [fk_item_id]       BIGINT       NULL,
    [fk_usr_id]        BIGINT       NOT NULL,
    [comment]          TEXT         NULL,
    [rate]             MONEY        NULL,
    [saveDateTime]     DATETIME     DEFAULT (getdate()) NULL,
    [saveIp]           VARCHAR (50) NULL,
    [fk_status_id]     INT          NULL,
    [confirmDate]      DATETIME     NULL,
    [fk_confirmUsr_id] BIGINT       NULL,
    CONSTRAINT [PK_TB_STORE_ITEM_EVALUATION] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_ITEM_EVALUATION_TB_ITEM] FOREIGN KEY ([fk_item_id]) REFERENCES [dbo].[TB_ITEM] ([id]),
    CONSTRAINT [FK_TB_STORE_ITEM_EVALUATION_TB_STATUS] FOREIGN KEY ([fk_status_id]) REFERENCES [dbo].[TB_STATUS] ([id]),
    CONSTRAINT [FK_TB_STORE_ITEM_EVALUATION_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_STORE_ITEM_EVALUATION_TB_USR] FOREIGN KEY ([fk_usr_id]) REFERENCES [dbo].[TB_USR] ([id]),
    CONSTRAINT [FK_TB_STORE_ITEM_EVALUATION_TB_USR1] FOREIGN KEY ([fk_confirmUsr_id]) REFERENCES [dbo].[TB_USR] ([id])
);



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'نظرسنجی مربوط به هر کالا در هر فروشگاه', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_ITEM_EVALUATION';






GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'امتیاز',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE_ITEM_EVALUATION',
    @level2type = N'COLUMN',
    @level2name = N'rate'