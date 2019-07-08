CREATE TABLE [dbo].[TB_STORE_ITEM_WARRANTY] (
    [pk_fk_store_id]         BIGINT NOT NULL,
    [pk_fk_item_id]          BIGINT NOT NULL,
    [pk_fk_storeWarranty_id] BIGINT NOT NULL,
    [warrantyDays]           INT    NOT NULL,
    [warrantyCost]           MONEY  CONSTRAINT [DF_TB_STORE_ITEM_WARRANTY_warrantyCost] DEFAULT 0 NOT NULL,
    [isActive]               BIT    CONSTRAINT [DF_TB_STORE_ITEM_WARRANTY_isActive] DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_TB_STORE_ITEM_WARRANTY] PRIMARY KEY CLUSTERED ([pk_fk_store_id] ASC, [pk_fk_item_id] ASC, [pk_fk_storeWarranty_id] ASC),
    CONSTRAINT [FK_TB_STORE_ITEM_WARRANTY_TB_STORE_ITEM_QTY] FOREIGN KEY ([pk_fk_store_id], [pk_fk_item_id]) REFERENCES [dbo].[TB_STORE_ITEM_QTY] ([pk_fk_store_id], [pk_fk_item_id]),
    CONSTRAINT [FK_TB_STORE_ITEM_WARRANTY_TB_STORE_WARRANTY] FOREIGN KEY ([pk_fk_storeWarranty_id]) REFERENCES [dbo].[TB_STORE_WARRANTY] ([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'مشخص میکند که چه کالایی در چه فروشگاهی دارای چه گارانتی میباشد و اینکه ایا فلان کالا شامل گارانتی مبشود و چه هزینه ای را در بر دارد', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_ITEM_WARRANTY';

