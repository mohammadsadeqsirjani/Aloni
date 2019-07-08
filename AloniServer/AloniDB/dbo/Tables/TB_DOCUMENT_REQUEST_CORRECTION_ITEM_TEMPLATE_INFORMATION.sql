CREATE TABLE [dbo].[TB_DOCUMENT_REQUEST_CORRECTION_ITEM_TEMPLATE_INFORMATION] (
    [pk_fk_document_id]           UNIQUEIDENTIFIER NOT NULL,
    [pk_fk_request_correction_id] BIGINT           NOT NULL,
    CONSTRAINT [PK_TB_DOCUMENT_REQUEST_CORRECTION_ITEM_TEMPLATE_INFORMATION] PRIMARY KEY CLUSTERED ([pk_fk_document_id] ASC, [pk_fk_request_correction_id] ASC),
    CONSTRAINT [FK_TB_DOCUMENT_REQUEST_CORRECTION_ITEM_TEMPLATE_INFORMATION_TB_DOCUMENT] FOREIGN KEY ([pk_fk_document_id]) REFERENCES [dbo].[TB_DOCUMENT] ([id]),
    CONSTRAINT [FK_TB_DOCUMENT_REQUEST_CORRECTION_ITEM_TEMPLATE_INFORMATION_TB_REQUEST_CORRECTION_TEMPLATE_INFORMATION] FOREIGN KEY ([pk_fk_request_correction_id]) REFERENCES [dbo].[TB_REQUEST_CORRECTION_TEMPLATE_INFORMATION] ([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول اطلاعاتی در مورد ایراداتی  که در زمینه ی اطلاعات تصویری  وجود دارد را در خود ذخیره میکند, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_DOCUMENT_REQUEST_CORRECTION_ITEM_TEMPLATE_INFORMATION';


