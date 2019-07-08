CREATE TABLE [dbo].[TB_STORE_ITEM_FAVORITE] (
    [pk_fk_store_id] BIGINT NOT NULL,
    [pk_fk_item_id]  BIGINT NOT NULL,
    [pk_fk_usr_id]   BIGINT NOT NULL,
    CONSTRAINT [PK_TB_STORE_ITEM_FAVORITE_1] PRIMARY KEY CLUSTERED ([pk_fk_store_id] ASC, [pk_fk_item_id] ASC, [pk_fk_usr_id] ASC),
    CONSTRAINT [FK_TB_STORE_ITEM_FAVORITE_TB_ITEM] FOREIGN KEY ([pk_fk_item_id]) REFERENCES [dbo].[TB_ITEM] ([id]),
    CONSTRAINT [FK_TB_STORE_ITEM_FAVORITE_TB_STORE] FOREIGN KEY ([pk_fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_STORE_ITEM_FAVORITE_TB_USR] FOREIGN KEY ([pk_fk_usr_id]) REFERENCES [dbo].[TB_USR] ([id])
);



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'کالا های برگزیده در هر فروشگاه ک هتوسط هر کاربر انتخاب میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_ITEM_FAVORITE';


