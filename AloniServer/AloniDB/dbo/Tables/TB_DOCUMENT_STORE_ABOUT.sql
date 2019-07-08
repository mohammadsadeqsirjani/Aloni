CREATE TABLE [dbo].[TB_DOCUMENT_STORE_ABOUT] (
    [pk_fk_store_about_id] BIGINT           NOT NULL,
    [pk_fk_document_id]    UNIQUEIDENTIFIER NOT NULL,
    [isDefault]            BIT              CONSTRAINT [DF_TB_DOCUMENT_STORE_ABOUT_isDefault] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TB_DOCUMENT_STORE_ABOUT] PRIMARY KEY CLUSTERED ([pk_fk_store_about_id] ASC, [pk_fk_document_id] ASC),
    CONSTRAINT [FK_TB_DOCUMENT_STORE_ABOUT_TB_DOCUMENT] FOREIGN KEY ([pk_fk_document_id]) REFERENCES [dbo].[TB_DOCUMENT] ([id]),
    CONSTRAINT [FK_TB_DOCUMENT_STORE_ABOUT_TB_STORE_ABOUT] FOREIGN KEY ([pk_fk_store_about_id]) REFERENCES [dbo].[TB_STORE_ABOUT] ([id])
);



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'اطلاعات مربوط به تصویر درباره ما هر فروشگاه رت شامل میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_DOCUMRNT_STORE_ABOUT';