CREATE TABLE [dbo].[TB_TYP_STORE_REPORT_TYPE] (
    [id]        INT           IDENTITY (1, 1) NOT NULL,
    [title]     VARCHAR (50)  NOT NULL,
    [usageInfo] VARCHAR (MAX) NULL,
    [isActive]  BIT           CONSTRAINT [DF__TB_TYP_ST__isAct__044996BA] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK__TB_TYP_S__3213E83FE5DECA0C] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'';





GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'نوع گزارش ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_TYP_STORE_REPORT_TYPE',
    @level2type = N'COLUMN',
    @level2name = N'usageInfo'

	
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'جدول دسته بندی گزارش ها', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_REPORT_TYPE';

