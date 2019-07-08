CREATE TABLE [dbo].[TB_STORE_ITEM_OPINIONPOLL_COMMENTS] (
    [id]                   BIGINT           IDENTITY (1, 1) NOT NULL,
    [fk_usr_commentUserId] BIGINT           NOT NULL,
    [fk_opinionpoll_id]    BIGINT           NOT NULL,
    [comment]              VARCHAR (MAX)    NULL,
    [fk_document_doc1]     UNIQUEIDENTIFIER NULL,
    [fk_document_doc2]     UNIQUEIDENTIFIER NULL,
    [fk_document_doc3]     UNIQUEIDENTIFIER NULL,
    [fk_document_doc4]     UNIQUEIDENTIFIER NULL,
    [fk_document_doc5]     UNIQUEIDENTIFIER NULL,
    [saveDateTime]         DATETIME         DEFAULT (getdate()) NOT NULL,
    [saveIp]               VARCHAR (50)     NULL,
    [edited]               BIT              DEFAULT ((0)) NOT NULL,
    [fk_status_id]         INT              NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_ITEM_OPINIONPOLL_COMMENTS_TB_DOCUMENT_1] FOREIGN KEY ([fk_document_doc1]) REFERENCES [dbo].[TB_DOCUMENT] ([id]),
    CONSTRAINT [FK_TB_STORE_ITEM_OPINIONPOLL_COMMENTS_TB_DOCUMENT_2] FOREIGN KEY ([fk_document_doc2]) REFERENCES [dbo].[TB_DOCUMENT] ([id]),
    CONSTRAINT [FK_TB_STORE_ITEM_OPINIONPOLL_COMMENTS_TB_DOCUMENT_3] FOREIGN KEY ([fk_document_doc3]) REFERENCES [dbo].[TB_DOCUMENT] ([id]),
    CONSTRAINT [FK_TB_STORE_ITEM_OPINIONPOLL_COMMENTS_TB_DOCUMENT_4] FOREIGN KEY ([fk_document_doc4]) REFERENCES [dbo].[TB_DOCUMENT] ([id]),
    CONSTRAINT [FK_TB_STORE_ITEM_OPINIONPOLL_COMMENTS_TB_DOCUMENT_5] FOREIGN KEY ([fk_document_doc5]) REFERENCES [dbo].[TB_DOCUMENT] ([id]),
    CONSTRAINT [FK_TB_STORE_ITEM_OPINIONPOLL_COMMENTS_TB_STATUS] FOREIGN KEY ([fk_status_id]) REFERENCES [dbo].[TB_STATUS] ([id]),
    CONSTRAINT [FK_TB_STORE_ITEM_OPINIONPOLL_COMMENTS_TB_STORE_ITEM_OPINIONPOLL] FOREIGN KEY ([fk_opinionpoll_id]) REFERENCES [dbo].[TB_STORE_ITEM_OPINIONPOLL] ([id]),
    CONSTRAINT [FK_TB_STORE_ITEM_OPINIONPOLL_COMMENTS_TB_USR] FOREIGN KEY ([fk_usr_commentUserId]) REFERENCES [dbo].[TB_USR] ([id])
);



GO

CREATE UNIQUE INDEX [IX_TB_STORE_ITEM_OPINIONPOLL_COMMENTS_fk_user_commentUserId_fk_opinionpoll_id] ON [dbo].[TB_STORE_ITEM_OPINIONPOLL_COMMENTS] ([fk_usr_commentUserId],[fk_opinionpoll_id])

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'نظری که هر کاربر در این نظرسنچی فروشگاه ایجاد میشود در این جدول  ذخیره میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_ITEM_OPINIONPOLL_COMMENTS';

