CREATE TABLE [dbo].[TB_DOCUMENT_STORE] (
    [pk_fk_document_id] UNIQUEIDENTIFIER NOT NULL,
    [pk_fk_store_id]    BIGINT           NOT NULL,
    [isDefault]         BIT              CONSTRAINT [DF_TB_DOCUMENT_STORE_isDefault] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TB_DOCUMENT_STORE] PRIMARY KEY CLUSTERED ([pk_fk_document_id] ASC, [pk_fk_store_id] ASC),
    CONSTRAINT [FK_TB_DOCUMENT_STORE_TB_DOCUMENT] FOREIGN KEY ([pk_fk_document_id]) REFERENCES [dbo].[TB_DOCUMENT] ([id]),
    CONSTRAINT [FK_TB_DOCUMENT_STORE_TB_STORE] FOREIGN KEY ([pk_fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id])
);




GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20181027-092702]
    ON [dbo].[TB_DOCUMENT_STORE]([pk_fk_document_id] ASC, [pk_fk_store_id] ASC, [isDefault] ASC);


	GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'اطلاعان تصویری تمام فروشگتاه را  در خود ذخیره میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_DOCUMENT_STORE';



