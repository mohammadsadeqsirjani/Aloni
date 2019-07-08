CREATE TABLE [dbo].[TB_STORE_WARRANTY] (
    [id]          BIGINT        IDENTITY (1, 1) NOT NULL,
    [fk_store_id] BIGINT        NOT NULL,
    [title]       NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_TB_STORE_WARRANTY] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_WARRANTY_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'چه فروشگاه هایی شامل گارانتی میشوند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_WARRANTY';