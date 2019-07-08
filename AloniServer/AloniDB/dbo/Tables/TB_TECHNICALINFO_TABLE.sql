CREATE TABLE [dbo].[TB_TECHNICALINFO_TABLE]
(
	[id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [title] VARCHAR(100) NOT NULL, 
	[description] VARCHAR(250) NULL,
    [isActive] BIT NOT NULL DEFAULT 1
    
)


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'هر دسته بندی از کالا ها خود دارای مشخصات فنی میباشند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TECHNICALINFO_TABLE';