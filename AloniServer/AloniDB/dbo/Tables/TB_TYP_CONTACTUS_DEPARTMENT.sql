CREATE TABLE [dbo].[TB_TYP_CONTACTUS_DEPARTMENT]
(
	[id]            INT           IDENTITY (1, 1) NOT NULL, 
    [title] VARCHAR(50) NOT NULL, 
    [isActive] BIT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_TB_TYP_CONTACTUS_DEPARTMENT] PRIMARY KEY ([id]) 
)

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'راه های ارتباطی را با فروشگاه ها  مشخص میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_CONTACTUS_DEPARTMENT';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'مدیریت امور مالی و حسابداری و .... ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_TYP_CONTACTUS_DEPARTMENT',
    @level2type = N'COLUMN',
    @level2name = N'id'