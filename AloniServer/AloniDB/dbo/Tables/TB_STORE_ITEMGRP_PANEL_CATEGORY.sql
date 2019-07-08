CREATE TABLE [dbo].[TB_STORE_ITEMGRP_PANEL_CATEGORY]
(
	[pk_fk_store_id] BIGINT NOT NULL , 
    [pk_fk_itemGrp_id] BIGINT NOT NULL, 
    PRIMARY KEY ([pk_fk_store_id], [pk_fk_itemGrp_id]), 
    CONSTRAINT [FK_TB_STORE_ITEMGRP_PANEL_CATEGORY_TB_STORE] FOREIGN KEY ([pk_fk_store_id]) REFERENCES [TB_STORE]([id]),
	CONSTRAINT [FK_TB_STORE_ITEMGRP_PANEL_CATEGORY_TB_TYP_ITEM_GRP] FOREIGN KEY ([pk_fk_itemGrp_id]) REFERENCES [TB_TYP_ITEM_GRP]([id]),
)

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'مشخص میکند در پنل کاربری هر فروگاه چه دسته بندی های اختصاصی فعال هستند ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_ITEMGRP_PANEL_CATEGORY';

