CREATE TABLE [dbo].[TB_ITEM] (
    [id]                      BIGINT        IDENTITY (1, 1) NOT NULL,
    [title]                   VARCHAR (150) NOT NULL,
    [fk_itemGrp_id]           BIGINT        NOT NULL,
    [saveDateTime]            DATETIME      CONSTRAINT [DF_TB_ITEM_saveDateTime] DEFAULT (getdate()) NOT NULL,
    [fk_usr_saveUser]         BIGINT        NOT NULL,
    [barcode]                 VARCHAR (150) NULL,
    [fk_status_id]            INT           NOT NULL,
    [fk_country_Manufacturer] INT           NOT NULL,
    [fk_unit_id]              INT           NOT NULL,
    [manufacturerCo]          VARCHAR (150) NULL,
    [technicalTitle]          VARCHAR (250) NULL,
    [importerCo]              NVARCHAR (50) NULL,
    [isTemplate]              BIT           CONSTRAINT [DF__TB_ITEM__isTempl__621B6E8C] DEFAULT ((1)) NOT NULL,
    [fk_savestore_id]         BIGINT        NULL,
    [review]                  TEXT          NULL,
    [modifyDateTime]          DATETIME      NULL,
    [fk_modify_usr_id]        BIGINT        NULL,
    [sex]                     BIT           NULL,
    [fk_state_id]             INT           NULL,
    [fk_city_id]              INT           NULL,
    [village]                 VARCHAR (50)  NULL,
    [unitName]                VARCHAR (150) NULL,
    [displayMode]             BIT           CONSTRAINT [DF_TB_ITEM_displayMode] DEFAULT ((0)) NULL,
    [fk_objectGrp_id]         BIGINT        NULL,
    [itemType]                SMALLINT      NULL,
    [findJustBarcode]         BIT           NULL,
    [fk_education_id]         SMALLINT      NULL,
    [uniqueBarcode]           NVARCHAR (50) NULL,
    [isLocked]                BIT           NULL,
    CONSTRAINT [PK_TB_ITEM] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_ITEM_TB_CITY] FOREIGN KEY ([fk_city_id]) REFERENCES [dbo].[TB_CITY] ([id]),
    CONSTRAINT [FK_TB_ITEM_TB_COUNTRY] FOREIGN KEY ([fk_country_Manufacturer]) REFERENCES [dbo].[TB_COUNTRY] ([id]),
    CONSTRAINT [FK_TB_ITEM_TB_STATE] FOREIGN KEY ([fk_state_id]) REFERENCES [dbo].[TB_STATE] ([Id]),
    CONSTRAINT [FK_TB_ITEM_TB_STATUS] FOREIGN KEY ([fk_status_id]) REFERENCES [dbo].[TB_STATUS] ([id]),
    CONSTRAINT [FK_TB_ITEM_TB_STORE] FOREIGN KEY ([fk_savestore_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_ITEM_TB_TYP_EDUCATION] FOREIGN KEY ([fk_education_id]) REFERENCES [dbo].[TB_TYP_EDUCATION] ([id]),
    CONSTRAINT [FK_TB_ITEM_TB_TYP_ITEM_GRP] FOREIGN KEY ([fk_itemGrp_id]) REFERENCES [dbo].[TB_TYP_ITEM_GRP] ([id]),
    CONSTRAINT [FK_TB_ITEM_TB_TYP_Object_Grp] FOREIGN KEY ([fk_objectGrp_id]) REFERENCES [dbo].[TB_TYP_OBJECT_GRP] ([id]),
    CONSTRAINT [FK_TB_ITEM_TB_TYP_UNIT] FOREIGN KEY ([fk_unit_id]) REFERENCES [dbo].[TB_TYP_UNIT] ([id]),
    CONSTRAINT [FK_TB_ITEM_TB_USR] FOREIGN KEY ([fk_usr_saveUser]) REFERENCES [dbo].[TB_USR] ([id]),
    CONSTRAINT [FK_TB_ITEM_TB_USR1] FOREIGN KEY ([fk_modify_usr_id]) REFERENCES [dbo].[TB_USR] ([id])
);



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول اطلاعات مربوط به تمامی کالاها ذخبره میشود ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'';




























GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'نقد و بررسی',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ITEM',
    @level2type = N'COLUMN',
    @level2name = N'review'
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0 : female 1: male', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_ITEM', @level2type = N'COLUMN', @level2name = N'sex';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0 : kala ,1 : personel', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_ITEM', @level2type = N'COLUMN', @level2name = N'displayMode';


GO
CREATE NONCLUSTERED INDEX [TB_ITEM_NON_CLUSTERED_DISPLAY_MODE3_SG]
    ON [dbo].[TB_ITEM]([displayMode] ASC)
    INCLUDE([id], [title], [fk_itemGrp_id]);


GO
CREATE NONCLUSTERED INDEX [TB_ITEM_NON_CLUSTERED_DISPLAY_MODE2_SG]
    ON [dbo].[TB_ITEM]([fk_itemGrp_id] ASC, [displayMode] ASC)
    INCLUDE([id]);


GO
CREATE NONCLUSTERED INDEX [TB_ITEM_NON_CLUSTERED_DISPLAY_MODE_SG]
    ON [dbo].[TB_ITEM]([displayMode] ASC)
    INCLUDE([id], [fk_itemGrp_id]);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'دسته بندی کالا',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ITEM',
    @level2type = N'COLUMN',
    @level2name = N'fk_itemGrp_id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'مشخصات فنی',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ITEM',
    @level2type = N'COLUMN',
    @level2name = N'technicalTitle'