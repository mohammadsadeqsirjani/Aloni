CREATE TABLE [dbo].[TB_CONVERSATION] (
    [id]                                    BIGINT IDENTITY (1, 1) NOT NULL,
    [fk_from]                               BIGINT NOT NULL,
    [fk_to]                                 BIGINT NOT NULL,
    [conversationWithStore]                 BIT    CONSTRAINT [DF_TB_CONVERSATION_messageAsStore] DEFAULT ((0)) NOT NULL,
    [conversationWithPortal]                BIT    NULL,
    [fk_conversationAbout_ItemId]           BIGINT NULL,
    [fk_conversationAbout_ItemEvaluationId] BIGINT NULL,
    [fk_conversationAbout_opinionPollId]    BIGINT NULL,
    CONSTRAINT [PK_TB_CONVERSATION] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_CONVERSATION_TB_ITEM] FOREIGN KEY ([fk_conversationAbout_ItemId]) REFERENCES [dbo].[TB_ITEM] ([id]),
    CONSTRAINT [FK_TB_CONVERSATION_TB_STORE_ITEM_EVALUATION] FOREIGN KEY ([fk_conversationAbout_ItemEvaluationId]) REFERENCES [dbo].[TB_STORE_ITEM_EVALUATION] ([id]),
    CONSTRAINT [FK_TB_CONVERSATION_TB_STORE_ITEM_OPINIONPOLL] FOREIGN KEY ([fk_conversationAbout_opinionPollId]) REFERENCES [dbo].[TB_STORE_ITEM_OPINIONPOLL_COMMENTS] ([id])
);

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description',@value=N'در این جدول تمام اطلاعات مربوط به پیام های رد و بدل شده در دل اپ را شامل میشود با این تفاوت که تنها مشخص  میکند که از چه طریقی این اطلاعات ثبت شده است را شامل میشود' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TB_CONVERSATION'










