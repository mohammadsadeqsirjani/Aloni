CREATE TABLE [dbo].[TB_STORE_SOCIALNETWORK] (
    [id]                   BIGINT         IDENTITY (1, 1) NOT NULL,
    [fk_store_id]          BIGINT         NOT NULL,
    [socialNetworkType]    NVARCHAR (50)  NOT NULL,
    [socialNetworkAccount] NVARCHAR (150) NULL,
    CONSTRAINT [PK_TB_STORE_SOCIALNETWORK] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_SOCIALNETWORK_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id])
);



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'شبکه های اجتماهی هر فروشگاه را شامل میشود ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_SOCIALNETWORK';