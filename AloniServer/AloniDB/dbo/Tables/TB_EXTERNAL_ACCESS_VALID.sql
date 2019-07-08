CREATE TABLE [dbo].[TB_EXTERNAL_ACCESS_VALID] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [fk_store_id] BIGINT        NOT NULL,
    [clientIp]    VARCHAR (150) NOT NULL,
    CONSTRAINT [PK_TB_EXTERNAL_ACCESS_VALID] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_EXTERNAL_ACCESS_VALID_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول دسترسی های خارجی مجاز ثبت میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_EXTERNAL_ACCESS_VALID';

GO
