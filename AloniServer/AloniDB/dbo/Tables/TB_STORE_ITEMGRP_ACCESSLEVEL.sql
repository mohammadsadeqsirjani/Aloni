CREATE TABLE [dbo].[TB_STORE_ITEMGRP_ACCESSLEVEL] (
    [id]            INT    IDENTITY (1, 1) NOT NULL,
    [fk_store_id]   BIGINT NOT NULL,
    [fk_itemGrp_id] BIGINT NOT NULL,
    CONSTRAINT [PK_TB_STORE_ITEMGRP_ACCESSLEVEL] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_ITEMGRP_ACCESSLEVEL_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_STORE_ITEMGRP_ACCESSLEVEL_TB_TYP_ITEM_GRP] FOREIGN KEY ([fk_itemGrp_id]) REFERENCES [dbo].[TB_TYP_ITEM_GRP] ([id])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'مشخص میکند در هر فروشگاهی چه دسته بندی اختصاصی موجود است  و کدام دسته بندی در حال حاضر  قابل دسترسی میباشند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_ITEMGRP_ACCESSLEVEL';
