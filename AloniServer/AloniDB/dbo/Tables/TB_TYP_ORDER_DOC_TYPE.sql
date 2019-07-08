CREATE TABLE [dbo].[TB_TYP_ORDER_DOC_TYPE]
(
	[id] SMALLINT NOT NULL PRIMARY KEY, 
    [title] VARCHAR(50) NOT NULL
)

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول تمام حالت های ثبت سفارش را شامل میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_ORDER_DOC_TYPE';

