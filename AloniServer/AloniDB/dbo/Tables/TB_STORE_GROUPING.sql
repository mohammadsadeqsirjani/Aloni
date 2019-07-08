CREATE TABLE [dbo].[TB_STORE_GROUPING] (
    [id]                      BIGINT        IDENTITY (1, 1) NOT NULL,
    [title]                   NVARCHAR (50) NOT NULL,
    [orderNo]                 INT           NULL,
    [fk_storeGrouping_parent] BIGINT        NULL,
    [fk_store_id]             BIGINT        NOT NULL,
    [fk_status_id]            INT           NOT NULL,
    CONSTRAINT [PK_TB_STORE_GROUPING] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_GROUPING_TB_STATUS] FOREIGN KEY ([fk_status_id]) REFERENCES [dbo].[TB_STATUS] ([id]),
    CONSTRAINT [FK_TB_STORE_GROUPING_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_STORE_GROUPING_TB_STORE_GROUPING] FOREIGN KEY ([fk_storeGrouping_parent]) REFERENCES [dbo].[TB_STORE_GROUPING] ([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'دسته بندی های اختصاصی هر فروشگاه ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_GROUOING';

