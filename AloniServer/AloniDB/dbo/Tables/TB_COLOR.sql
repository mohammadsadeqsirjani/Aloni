CREATE TABLE [dbo].[TB_COLOR]
(
	[id] VARCHAR(20) NOT NULL PRIMARY KEY, 
    [title] VARCHAR(50) NOT NULL, 
    [isActive] BIT NOT NULL DEFAULT 1
)

EXEC sys.sp_addextendedproperty @name=N'MS_Description',@value=N'جدول حاضر مربوط به رنکهاست' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TB_COLOR'