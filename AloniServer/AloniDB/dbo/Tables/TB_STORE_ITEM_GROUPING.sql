CREATE TABLE [dbo].[TB_STORE_ITEM_GROUPING] (
    [pk_fk_store_id]    BIGINT NOT NULL,
    [pk_fk_item_id]     BIGINT NOT NULL,
    [pk_fk_grouping_id] BIGINT NOT NULL,
    CONSTRAINT [PK_TB_STORE_ITEM_GROUPING] PRIMARY KEY CLUSTERED ([pk_fk_store_id] ASC, [pk_fk_item_id] ASC, [pk_fk_grouping_id] ASC),
    CONSTRAINT [FK_TB_STORE_ITEM_GROUPING_TB_STORE_GROUPING] FOREIGN KEY ([pk_fk_grouping_id]) REFERENCES [dbo].[TB_STORE_GROUPING] ([id]),
    CONSTRAINT [FK_TB_STORE_ITEM_GROUPING_TB_STORE_ITEM_QTY] FOREIGN KEY ([pk_fk_store_id], [pk_fk_item_id]) REFERENCES [dbo].[TB_STORE_ITEM_QTY] ([pk_fk_store_id], [pk_fk_item_id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'دسته بندی دلخواه کالا در هر فروشگاه', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_ITEM_GROUPING';

