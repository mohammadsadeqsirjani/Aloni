CREATE TABLE [dbo].[TB_TYP_ITEM_GRP] (
    [id]                       BIGINT           IDENTITY (1, 1) NOT NULL,
    [title]                    VARCHAR (150)    NULL,
    [fk_item_grp_ref]          BIGINT           NULL,
    [fk_document_id]           UNIQUEIDENTIFIER NULL,
    [fk_technicalinfo_page_id] SMALLINT         NULL,
    [keywords]                 VARCHAR (MAX)    NULL,
    [isActive]                 BIT              CONSTRAINT [DF_TB_TYP_ITEM_GRP_isActive] DEFAULT ((1)) NOT NULL,
    [type]                     SMALLINT         DEFAULT ((1)) NULL,
    CONSTRAINT [PK_TB_TYP_ITEM_GRP] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_ITEM_TB_TECHNICALINFO_PAGE] FOREIGN KEY ([fk_technicalinfo_page_id]) REFERENCES [dbo].[TB_TECHNICALINFO_PAGE] ([Id]),
    CONSTRAINT [FK_TB_TYP_ITEM_GRP_TB_DOCUMENT] FOREIGN KEY ([fk_document_id]) REFERENCES [dbo].[TB_DOCUMENT] ([id]),
    CONSTRAINT [FK_TB_TYP_ITEM_GRP_TB_TYP_ITEM_GRP] FOREIGN KEY ([fk_item_grp_ref]) REFERENCES [dbo].[TB_TYP_ITEM_GRP] ([id])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'تمام دسته بندی های اختصاصی فروشگاه ها در این جدول ذخیره میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_ITEM_GRP';







GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'kala = 1 , personel = 2 , job = 3 , shey = 4,sazman = 5 , shoab = 6', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_ITEM_GRP', @level2type = N'COLUMN', @level2name = N'type';

