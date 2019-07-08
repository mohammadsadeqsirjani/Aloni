CREATE TABLE [dbo].[TB_TYP_FINANCIAL_ACCOUNT_TYPE]
(
	[id] SMALLINT NOT NULL, 
    [title] VARCHAR(50) NOT NULL, 
    CONSTRAINT [PK_TB_TYP_FINANCIAL_ACCOUNT_TYPE] PRIMARY KEY ([id]) 
)

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'انواع پرداخت ها و امور مالی', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_FINANCIAL_ACCOUNT_TYPE';