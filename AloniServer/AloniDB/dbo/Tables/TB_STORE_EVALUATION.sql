CREATE TABLE [dbo].[TB_STORE_EVALUATION] (
    [id]           BIGINT       IDENTITY (1, 1) NOT NULL,
    [fk_store_id]  BIGINT       NOT NULL,
    [fk_usr_id]    BIGINT       NOT NULL,
    [rate]         FLOAT (53)   CONSTRAINT [DF__TB_STORE_E__rate__4C9641C1] DEFAULT ((0)) NOT NULL,
    [comment]      TEXT         NULL,
    [saveIp]       VARCHAR (50) NOT NULL,
    [saveDateTime] DATETIME     CONSTRAINT [DF__TB_STORE___saveD__4D8A65FA] DEFAULT (getdate()) NOT NULL,
    [sumPurchese]  MONEY        CONSTRAINT [DF__TB_STORE___sumPu__4E7E8A33] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__TB_STORE__3213E83FDDAC12BF] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_EVALUATION_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_STORE_EVALUATION_TB_USR] FOREIGN KEY ([fk_usr_id]) REFERENCES [dbo].[TB_USR] ([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'نظرسنجی کالا', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_EVALUATION';







GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'متن  نظرسنجی',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE_EVALUATION',
    @level2type = N'COLUMN',
    @level2name = N'comment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'امتیاز کالا',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE_EVALUATION',
    @level2type = N'COLUMN',
    @level2name = N'rate'