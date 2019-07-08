CREATE TABLE [dbo].[TB_TYP_STORE_PERSONALITY_TYPE]
(
	[id] INT NOT NULL PRIMARY KEY, 
    [title] VARCHAR(50) NOT NULL
)


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'نوع شخصیت هایی شرکتها و فروشگاه هایی که در آلونی حضور دارند  را مشخص میکنند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_STORE_PERSONALITY_TYPE';
