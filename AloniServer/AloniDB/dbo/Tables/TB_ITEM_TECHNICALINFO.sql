CREATE TABLE [dbo].[TB_ITEM_TECHNICALINFO] (
    [pk_fk_item_id]                   BIGINT         NOT NULL,
    [pk_fk_technicalInfo_id]          BIGINT         NOT NULL,
    [strValue]                        VARCHAR (8000) NULL,
    [fk_technicalInfoValues_tblValue] BIGINT         NULL,
    [isPublic]                        BIT            NULL,
    CONSTRAINT [PK_TB_ITEM_TECHNICALINFO] PRIMARY KEY CLUSTERED ([pk_fk_item_id] ASC, [pk_fk_technicalInfo_id] ASC),
    CONSTRAINT [FK_TB_ITEM_TECHNICALINFO_TB_ITEM] FOREIGN KEY ([pk_fk_item_id]) REFERENCES [dbo].[TB_ITEM] ([id]),
    CONSTRAINT [FK_TB_ITEM_TECHNICALINFO_TB_TECHNICALINFO_VALUES] FOREIGN KEY ([fk_technicalInfoValues_tblValue]) REFERENCES [dbo].[TB_TECHNICALINFO_VALUES] ([id]),
    CONSTRAINT [FK_TB_ITEM_TECHNICALINFO_TB_TYP_TECHNICALINFO] FOREIGN KEY ([pk_fk_technicalInfo_id]) REFERENCES [dbo].[TB_TYP_TECHNICALINFO] ([id])
);



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'دراین جدول اطلاعات مربوط به مشخصات فنی کالاها ذخیره میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_ITEM_TECHNICAL_INFO';