CREATE TABLE [dbo].[TB_STORE_PHONE] (
    [id]          BIGINT        IDENTITY (1, 1) NOT NULL,
    [fk_store_id] BIGINT        NOT NULL,
    [phone]       VARCHAR (50)  NOT NULL,
    [caption]     NVARCHAR (50) NULL,
    [isActive]    BIT           CONSTRAINT [DF_TB_STORE_PHONE_isActive] DEFAULT ((1)) NOT NULL,
    [isDefault]   BIT           NOT NULL,
    CONSTRAINT [PK_TB_STORE_PHONE] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_PHONE_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id])
);


GO

CREATE UNIQUE INDEX [IX_TB_STORE_PHONE_fk_store_id_isDefault] ON [dbo].[TB_STORE_PHONE] ([fk_store_id],[isDefault]) where [isDefault] = 1

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'تلفنهای هر فروشگاه را شامل میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_PHONE';