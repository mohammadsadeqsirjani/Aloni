CREATE TABLE [dbo].[TB_DOCUMENT_STORE_CERTIFICATE] (
    [pk_fk_store_certificate_id] BIGINT           NOT NULL,
    [pk_fk_document_id]          UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_TB_DOCUMENT_STORE_CERTIFICATE] PRIMARY KEY CLUSTERED ([pk_fk_store_certificate_id] ASC, [pk_fk_document_id] ASC),
    CONSTRAINT [FK_TB_DOCUMENT_STORE_CERTIFICATE_TB_DOCUMENT] FOREIGN KEY ([pk_fk_document_id]) REFERENCES [dbo].[TB_DOCUMENT] ([id]),
    CONSTRAINT [FK_TB_DOCUMENT_STORE_CERTIFICATE_TB_STORE_CERTIFICATE] FOREIGN KEY ([pk_fk_store_certificate_id]) REFERENCES [dbo].[TB_STORE_CERTIFICATE] ([id])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'اطلاعات تصویری مریوط به مجوز های یک فروشگاه را در بر دارد', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_DOCUMENT_STORE_CERTIFICATE';