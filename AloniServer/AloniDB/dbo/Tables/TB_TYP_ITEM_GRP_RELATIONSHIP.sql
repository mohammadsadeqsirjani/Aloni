CREATE TABLE [dbo].[TB_TYP_ITEM_GRP_RELATIONSHIP] (
    [pk_fk_item_grp_id]      BIGINT NOT NULL,
    [pk_fk_item_grp_id_link] BIGINT NOT NULL,
    CONSTRAINT [PK_TB_TYP_ITEM_GRP_RELATIONSHIP] PRIMARY KEY CLUSTERED ([pk_fk_item_grp_id] ASC, [pk_fk_item_grp_id_link] ASC),
    CONSTRAINT [FK_TB_TYP_ITEM_GRP_RELATIONSHIP_TB_TYP_ITEM_GRP] FOREIGN KEY ([pk_fk_item_grp_id]) REFERENCES [dbo].[TB_TYP_ITEM_GRP] ([id]),
    CONSTRAINT [FK_TB_TYP_ITEM_GRP_RELATIONSHIP_TB_TYP_ITEM_GRP1] FOREIGN KEY ([pk_fk_item_grp_id_link]) REFERENCES [dbo].[TB_TYP_ITEM_GRP] ([id])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'هر کالایی ممکن است به یک سری کالا ها ارتباط داشته باشد در این جدول این ارتباط ایجاد می شود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_ITEM_GRP_RELATIONSHIP';

