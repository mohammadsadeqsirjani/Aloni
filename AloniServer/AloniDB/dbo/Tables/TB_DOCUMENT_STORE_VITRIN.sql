CREATE TABLE [dbo].[TB_DOCUMENT_STORE_VITRIN] (
    [pk_fk_vitrin_id]   BIGINT           NOT NULL,
    [pk_fk_document_id] UNIQUEIDENTIFIER NOT NULL,
    [isPrime]           BIT              CONSTRAINT [DF_TB_DOCUMENT_VITRIN_isPrime] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TB_DOCUMENT_VITRIN] PRIMARY KEY CLUSTERED ([pk_fk_vitrin_id] ASC, [pk_fk_document_id] ASC),
    CONSTRAINT [FK_TB_DOCUMENT_VITRIN_TB_DOCUMENT] FOREIGN KEY ([pk_fk_document_id]) REFERENCES [dbo].[TB_DOCUMENT] ([id]),
    CONSTRAINT [FK_TB_DOCUMENT_VITRIN_TB_STORE_VITRIN] FOREIGN KEY ([pk_fk_vitrin_id]) REFERENCES [dbo].[TB_STORE_VITRIN] ([id])
);




GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20181027-093658]
    ON [dbo].[TB_DOCUMENT_STORE_VITRIN]([pk_fk_vitrin_id] ASC, [pk_fk_document_id] ASC, [isPrime] ASC);

	GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'اطلاعات تصویری مریوط به ویترین هر فروشگاه را شامل میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_DOCUMENT_STORE_VITRIN';
