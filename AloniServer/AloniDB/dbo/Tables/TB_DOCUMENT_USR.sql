CREATE TABLE [dbo].[TB_DOCUMENT_USR] (
    [pk_fk_document_id] UNIQUEIDENTIFIER NOT NULL,
    [pk_fk_usr_id]      BIGINT           NOT NULL,
    [isDefault]         BIT              CONSTRAINT [DF_TB_DOCUMENT_USR_isDefault] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TB_DOCUMENT_USR] PRIMARY KEY CLUSTERED ([pk_fk_document_id] ASC, [pk_fk_usr_id] ASC),
    CONSTRAINT [FK_TB_DOCUMENT_USR_TB_DOCUMENT] FOREIGN KEY ([pk_fk_document_id]) REFERENCES [dbo].[TB_DOCUMENT] ([id]),
    CONSTRAINT [FK_TB_DOCUMENT_USR_TB_USR] FOREIGN KEY ([pk_fk_usr_id]) REFERENCES [dbo].[TB_USR] ([id])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'جدول میانی مربوط به اطلاعات تصویری کاربران می باشد', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_DOCUMENT_USR';

