CREATE TABLE [dbo].[TB_DOCUMENT_ITEM] (
    [pk_fk_document_id] UNIQUEIDENTIFIER NOT NULL,
    [pk_fk_item_id]     BIGINT           NOT NULL,
    [isDefault]         BIT              CONSTRAINT [DF_TB_DOCUMENT_ITEM_isDefault] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TB_DOCUMENT_ITEM] PRIMARY KEY CLUSTERED ([pk_fk_document_id] ASC, [pk_fk_item_id] ASC),
    CONSTRAINT [FK_TB_DOCUMENT_ITEM_TB_DOCUMENT] FOREIGN KEY ([pk_fk_document_id]) REFERENCES [dbo].[TB_DOCUMENT] ([id]),
    CONSTRAINT [FK_TB_DOCUMENT_ITEM_TB_ITEM] FOREIGN KEY ([pk_fk_item_id]) REFERENCES [dbo].[TB_ITEM] ([id])
);


GO

CREATE UNIQUE INDEX [IX_TB_DOCUMENT_ITEM_OnlyOneDefaultAllowed] ON [dbo].[TB_DOCUMENT_ITEM] ([pk_fk_document_id],[pk_fk_item_id],[isDefault]) where [isDefault] = 1

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'این جدول یک جدول میانی است که اطلاعان مربوط به تصویری تمام کالا ها را در خود جای داده است ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_DOCUMENT_ITEM';

