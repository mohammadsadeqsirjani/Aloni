CREATE TABLE [dbo].[TB_TECHNICALINFO_ITEMGRP] (
    [pk_fk_itemGrp_id]       BIGINT NOT NULL,
    [pk_fk_technicalInfo_id] BIGINT NOT NULL,
    CONSTRAINT [PK_TB_TECHNICALINFO_ITEMGRP] PRIMARY KEY CLUSTERED ([pk_fk_itemGrp_id] ASC, [pk_fk_technicalInfo_id] ASC),
    CONSTRAINT [FK_TB_TECHNICALINFO_ITEMGRP_TB_TYP_ITEM_GRP] FOREIGN KEY ([pk_fk_itemGrp_id]) REFERENCES [dbo].[TB_TYP_ITEM_GRP] ([id]),
    CONSTRAINT [FK_TB_TECHNICALINFO_ITEMGRP_TB_TYP_TECHNICALINFO] FOREIGN KEY ([pk_fk_technicalInfo_id]) REFERENCES [dbo].[TB_TYP_TECHNICALINFO] ([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'مشخصات  فنی هر دسته یندی اختصاصی هر فروشگاه را شامل مبشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TECHNICALINFO_ITEMGRP';

