CREATE TABLE [dbo].[TB_TYP_UNIT] (
    [id]       INT          NOT NULL,
    [title]    VARCHAR (50) NOT NULL,
    [isActive] BIT          CONSTRAINT [DF_TB_TYP_UNIT_isActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_TB_TYP_UNIT] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شناسه واحد اندازه گیری',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_TYP_UNIT',
    @level2type = N'COLUMN',
    @level2name = N'id'

	
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'واحد های اندازه گیری در این جدول ذخیره میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_UNIT';

