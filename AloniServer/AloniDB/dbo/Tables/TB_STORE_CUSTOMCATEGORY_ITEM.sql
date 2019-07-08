CREATE TABLE [dbo].[TB_STORE_CUSTOMCATEGORY_ITEM] (
    [pk_fk_custom_category_id] BIGINT NOT NULL,
    [pk_fk_item_id]            BIGINT NOT NULL,
    CONSTRAINT [PK_TB_STORE_CUSTOMCATEGORY_ITEM] PRIMARY KEY CLUSTERED ([pk_fk_custom_category_id] ASC, [pk_fk_item_id] ASC),
    CONSTRAINT [FK_TB_STORE_CUSTOMCATEGORY_ITEM_TB_ITEM] FOREIGN KEY ([pk_fk_item_id]) REFERENCES [dbo].[TB_ITEM] ([id]),
    CONSTRAINT [FK_TB_STORE_CUSTOMCATEGORY_ITEM_TB_STORE_CUSTOM_CATEGORY] FOREIGN KEY ([pk_fk_custom_category_id]) REFERENCES [dbo].[TB_STORE_CUSTOM_CATEGORY] ([id])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این قسمت مشخص میشود که کدام کالا ها در دسته بندی های اختصاصی  کاربر فروشگاهی فرار گرفته است ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_CUSTOMCATEGORY_ITEM';
