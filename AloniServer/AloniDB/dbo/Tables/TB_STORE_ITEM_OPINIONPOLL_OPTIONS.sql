CREATE TABLE [dbo].[TB_STORE_ITEM_OPINIONPOLL_OPTIONS]
(
	[id] BIGINT NOT NULL PRIMARY KEY IDENTITY, 
    [title] VARCHAR(MAX) NOT NULL, 
    [fk_opinionpoll_id] BIGINT NOT NULL, 
    [isActive] BIT NOT NULL DEFAULT 0, 
    [orderingNo] INT NULL, 
	[cntOpinions]  AS ([dbo].[func_getCntOfOpinionsOfOption](id)),
    [avgOpinions] AS ([dbo].[func_getAvgOfOpinionsOfOption](id)),
    CONSTRAINT [FK_TB_STORE_ITEM_OPINIONPOLL_OPTIONS_TB_STORE_ITEM_OPINIONPOLL] FOREIGN KEY ([fk_opinionpoll_id]) REFERENCES [TB_STORE_ITEM_OPINIONPOLL]([id])
)



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'این جدول امکان مدیریت نطرهای ثیت شده از جانب کاربران را فراهم میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_ITEM_OPINIONPOLL_OPTIONS';

