CREATE TABLE [dbo].[TB_EXPERTISE_ITEMGRP] (
    [pk_fk_expertise_id] INT    NOT NULL,
    [pk_fk_itemGrp_id]   BIGINT NOT NULL,
    CONSTRAINT [PK_TB_EXPERTISE_ITEMGRP] PRIMARY KEY CLUSTERED ([pk_fk_expertise_id] ASC, [pk_fk_itemGrp_id] ASC),
    CONSTRAINT [FK_TB_EXPERTISE_ITEMGRP_TB_TYP_ITEM_GRP] FOREIGN KEY ([pk_fk_itemGrp_id]) REFERENCES [dbo].[TB_TYP_ITEM_GRP] ([id]),
    CONSTRAINT [FK_TB_EXPERTISE_ITEMGRP_TB_TYP_STORE_EXPERTISE] FOREIGN KEY ([pk_fk_expertise_id]) REFERENCES [dbo].[TB_TYP_STORE_EXPERTISE] ([id])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول بر اساس دسته بندی فروشگاه ها که در جه زمبنه ای کار میکنند گروهای کالایی را نیز شامل میباشد', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_EXPERTISE_ITEMGRP';
