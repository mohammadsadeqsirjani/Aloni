CREATE TABLE [dbo].[TB_STORE_CERTIFICATE] (
    [id]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [fk_store_id]  BIGINT        NOT NULL,
    [title]        VARCHAR (250) NOT NULL,
    [dsc]          VARCHAR (250) NULL,
    [fk_status_id] INT           NULL,
    CONSTRAINT [PK_TB_STORE_CERTIFICATE] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_CERTIFICATE_TB_STATUS] FOREIGN KEY ([fk_status_id]) REFERENCES [dbo].[TB_STATUS] ([id]),
    CONSTRAINT [FK_TB_STORE_CERTIFICATE_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'مجوز های لازم هر فروشگاه را شامل میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_CERTIFICATE';


