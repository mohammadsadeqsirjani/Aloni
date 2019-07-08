CREATE TABLE [dbo].[TB_MESSAGE] (
    [id]                         BIGINT   IDENTITY (1, 1) NOT NULL,
    [message]                    TEXT     NOT NULL,
    [fk_usr_destUserId]          BIGINT   NULL,
    [fk_store_destStoreId]       BIGINT   NULL,
    [fk_usr_senderUser]          BIGINT   NULL,
    [saveDateTime]               DATETIME CONSTRAINT [DF_TB_MESSAGE_saveDateTime] DEFAULT (getdate()) NOT NULL,
    [seenDateTime]               DATETIME NULL,
    [deleted]                    BIT      CONSTRAINT [DF_TB_MESSAGE_deleted] DEFAULT ((0)) NOT NULL,
    [fk_staff_destStaffId]       SMALLINT NULL,
    [fk_store_senderStoreId]     BIGINT   NULL,
    [fk_staff_senderStaffId]     SMALLINT NULL,
    [fk_orderHdr_RelatedOrderId] BIGINT   NULL,
    [displayAsTicket]            BIT      CONSTRAINT [DF__TB_MESSAG__displ__2FA4FD58] DEFAULT ((0)) NOT NULL,
    [messageAsStore]             BIT      CONSTRAINT [DF_TB_MESSAGE_messageAsStore] DEFAULT ((0)) NOT NULL,
    [fk_conversation_id]         BIGINT   NULL,
    CONSTRAINT [PK_TB_MESSAGE] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_MESSAGE_TB_CONVERSATION] FOREIGN KEY ([fk_conversation_id]) REFERENCES [dbo].[TB_CONVERSATION] ([id]),
    CONSTRAINT [FK_TB_MESSAGE_TB_STAFF] FOREIGN KEY ([fk_staff_destStaffId]) REFERENCES [dbo].[TB_STAFF] ([id]),
    CONSTRAINT [FK_TB_MESSAGE_TB_STAFF1] FOREIGN KEY ([fk_staff_senderStaffId]) REFERENCES [dbo].[TB_STAFF] ([id]),
    CONSTRAINT [FK_TB_MESSAGE_TB_STORE] FOREIGN KEY ([fk_store_destStoreId]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_MESSAGE_TB_STORE1] FOREIGN KEY ([fk_store_senderStoreId]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_MESSAGE_TB_USR] FOREIGN KEY ([fk_usr_destUserId]) REFERENCES [dbo].[TB_USR] ([id]),
    CONSTRAINT [FK_TB_MESSAGE_TB_USR1] FOREIGN KEY ([fk_usr_senderUser]) REFERENCES [dbo].[TB_USR] ([id])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول پیام هایی که در یک فروشگاه بین افراد انجام میشود را با محتوایشان راثبت میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_MESSAGE';





GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'درگاه ثبت پیام و کاربری گه پیام داده است در این جدول ذخیره میشود ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_MESSAGE',
    @level2type = N'COLUMN',
    @level2name = N'fk_conversation_id'