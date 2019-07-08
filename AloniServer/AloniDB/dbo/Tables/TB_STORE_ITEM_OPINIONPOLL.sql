CREATE TABLE [dbo].[TB_STORE_ITEM_OPINIONPOLL]
(
	[id] BIGINT NOT NULL PRIMARY KEY IDENTITY, 
    [fk_store_id] BIGINT NOT NULL, 
    [fk_item_id] BIGINT NOT NULL, 
    [isActive] BIT NOT NULL DEFAULT 1, 
    [title] VARCHAR(MAX) NOT NULL, 
    [resultIsPublic] BIT NOT NULL DEFAULT 0, 
    [fk_document_picId] UNIQUEIDENTIFIER NULL, 
    [startDateTime] DATETIME NOT NULL, 
    [endDateTime] DATETIME NOT NULL, 
    [publish] INT NOT NULL DEFAULT 0, 
    [itemGrpTitle] VARCHAR(150) NULL, 
    [saveDateTime] DATETIME NOT NULL DEFAULT getDate(), 
    [saveIp] VARCHAR(50) NULL, 
    [fk_userSession_saveUserSessionId] BIGINT NOT NULL, 
    [fk_this_templateOpId] BIGINT NULL, 
    [publishDateTime] DATETIME NULL, 
    CONSTRAINT [FK_TB_STORE_ITEM_OPINIONPOLL_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [TB_STORE]([id]), 
    CONSTRAINT [FK_TB_STORE_ITEM_OPINIONPOLL_TB_ITEM] FOREIGN KEY ([fk_item_id]) REFERENCES [TB_ITEM]([id]), 
    CONSTRAINT [FK_TB_STORE_ITEM_OPINIONPOLL_TB_DOCUMENT] FOREIGN KEY ([fk_document_picId]) REFERENCES [TB_DOCUMENT]([id]), 
    CONSTRAINT [FK_TB_STORE_ITEM_OPINIONPOLL_TB_USR_SESSION] FOREIGN KEY ([fk_userSession_saveUserSessionId]) REFERENCES [TB_USR_SESSION]([id]), 
    CONSTRAINT [FK_TB_STORE_ITEM_OPINIONPOLL_TB_STORE_ITEM_OPINIONPOLL] FOREIGN KEY ([fk_this_templateOpId]) REFERENCES [TB_STORE_ITEM_OPINIONPOLL]([id])
)

GO

GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'انتشار شود؟',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE_ITEM_OPINIONPOLL',
    @level2type = N'COLUMN',
    @level2name = N'publish'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'عنوان نظر سنجی',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE_ITEM_OPINIONPOLL',
    @level2type = N'COLUMN',
    @level2name = N'title'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'تصویر شاخص نظرسنجی - در صورت نال بودن ، تصویر پیشفرض کالای فروشگاه برگزار کننده قرار میگیرد',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE_ITEM_OPINIONPOLL',
    @level2type = N'COLUMN',
    @level2name = N'fk_document_picId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'عنوان گروه کالا - در صورت نال بودن ، عنوان گروه کالای کالا نمایش داده می شود.',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE_ITEM_OPINIONPOLL',
    @level2type = N'COLUMN',
    @level2name = N'itemGrpTitle'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'زمان اولین انتشار',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE_ITEM_OPINIONPOLL',
    @level2type = N'COLUMN',
    @level2name = N'publishDateTime'

	
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'نظرسنجی هایی که هر فروشگاه در مورد  کالا های مورد نظر خود میگذارد', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_ITEM_OPINIONPOLL';

