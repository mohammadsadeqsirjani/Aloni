CREATE TABLE [dbo].[TB_TYP_PAYMENT_METHODE]
(
	[id] TINYINT NOT NULL PRIMARY KEY, 
    [title] VARCHAR(50) NOT NULL
)

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'راه های پرداخت را مشخص کرده است ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_PAYMENT_METHODE';


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'پرداخت نقدی پرداخت اعتباری  پرداخت آنلاین  ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_TYP_PAYMENT_METHODE',
    @level2type = N'COLUMN',
    @level2name = N'id'