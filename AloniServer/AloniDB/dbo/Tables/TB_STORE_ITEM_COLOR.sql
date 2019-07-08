CREATE TABLE [dbo].[TB_STORE_ITEM_COLOR]
(
	[pk_fk_store_id] BIGINT NOT NULL , 
    [pk_fk_item_id] BIGINT NOT NULL, 
    [fk_color_id] VARCHAR(50) NOT NULL, 
    [isActive] BIT NOT NULL DEFAULT 1, 
    [colorCost] MONEY NOT NULL DEFAULT 0, 
    CONSTRAINT [FK_TB_STORE_ITEM_COLOR_TB_STORE_ITEM_QTY] FOREIGN KEY ([pk_fk_store_id],[pk_fk_item_id]) REFERENCES [TB_STORE_ITEM_QTY]([pk_fk_store_id],[pk_fk_item_id]), 
    CONSTRAINT [PK_TB_STORE_ITEM_COLOR] PRIMARY KEY ([pk_fk_store_id], [pk_fk_item_id], [fk_color_id])
)


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'رنگهای  کالاهای موجود در هر فروشگاه', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_ITEM_COLOR';

