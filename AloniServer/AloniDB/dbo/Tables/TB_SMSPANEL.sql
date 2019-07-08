CREATE TABLE [dbo].[TB_SMSPANEL]
(
	[id] INT NOT NULL PRIMARY KEY, 
    [title] VARCHAR(50) NOT NULL, 
    [baseUrl] VARCHAR(255) NOT NULL, 
    [srcNo] VARCHAR(50) NOT NULL, 
    [userName] VARCHAR(50) NOT NULL, 
    [password] VARCHAR(50) NOT NULL, 
    [domain] VARCHAR(50) NOT NULL, 
    [fk_country_id] INT NOT NULL, 
    [isActive] BIT NOT NULL
)


	GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول سرویس های ارسال پیامک را در خود ذخیره میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_SMSPANEL';