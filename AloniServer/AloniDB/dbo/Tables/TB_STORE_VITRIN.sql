CREATE TABLE [dbo].[TB_STORE_VITRIN] (
    [id]            BIGINT         IDENTITY (1, 1) NOT NULL,
    [fk_store_id]   BIGINT         NOT NULL,
    [fk_item_id]    BIGINT         NULL,
    [fk_itemGrp_id] BIGINT         NULL,
    [title]         NVARCHAR (100) NOT NULL,
    [description]   NVARCHAR (MAX) NULL,
    [fk_usr_id]     BIGINT         NOT NULL,
    [saveDatetime]  DATETIME       NOT NULL,
    [isDeleted]     BIT            CONSTRAINT [DF__TB_STORE___isDel__4890A6B3] DEFAULT ((0)) NOT NULL,
    [type]          SMALLINT       CONSTRAINT [DF__TB_STORE_V__type__3ADAB195] DEFAULT ((1)) NOT NULL,
    [isHighlight]   BIT            NOT NULL,
    CONSTRAINT [PK_TB_STORE_VITRIN] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_VITRIN_TB_ITEM] FOREIGN KEY ([fk_item_id]) REFERENCES [dbo].[TB_ITEM] ([id]),
    CONSTRAINT [FK_TB_STORE_VITRIN_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_STORE_VITRIN_TB_TYP_ITEM_GRP] FOREIGN KEY ([fk_itemGrp_id]) REFERENCES [dbo].[TB_TYP_ITEM_GRP] ([id]),
    CONSTRAINT [FK_TB_STORE_VITRIN_TB_USR] FOREIGN KEY ([fk_usr_id]) REFERENCES [dbo].[TB_USR] ([id])
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'kala = 1 , personel = 2 , job = 3 , shey = 4',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE_VITRIN',
    @level2type = N'COLUMN',
    @level2name = N'type'

	GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ویترین هر فروشگاه که شامل گروه کالا ها   کالاها  و عنوانی مریوط به انها را شامل میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_VITRIN';