CREATE TABLE [dbo].[TB_STATE]
(
	[id] INT NOT NULL PRIMARY KEY, 
    [title] VARCHAR(50) NOT NULL, 
    [fk_country_id] INT NOT NULL, 
    [isActive] BIT NOT NULL, 
    CONSTRAINT [FK_TB_STATE_COUNTRY] FOREIGN KEY ([fk_country_id]) REFERENCES [TB_COUNTRY]([id])
)

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'استان های کشور را مشخص میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STATE';

