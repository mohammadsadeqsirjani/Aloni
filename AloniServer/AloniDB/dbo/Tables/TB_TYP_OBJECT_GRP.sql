CREATE TABLE [dbo].[TB_TYP_OBJECT_GRP] (
    [id]       BIGINT        IDENTITY (1, 1) NOT NULL,
    [title]    VARCHAR (150) NOT NULL,
    [type]     SMALLINT      CONSTRAINT [DF_TB_TYP_Object_Grp_type] DEFAULT ((1)) NOT NULL,
    [isActive] BIT           CONSTRAINT [DF_TB_TYP_Object_Grp_isActive] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TB_TYP_Object_Grp] PRIMARY KEY CLUSTERED ([id] ASC)
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'نوع زیر گروه فروشگاه را مشخص میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_OBJECT_GRP';



GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شعبه نمایندگی شرکت تابعه  اداره سازمان ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_TYP_OBJECT_GRP',
    @level2type = N'COLUMN',
    @level2name = N'id'