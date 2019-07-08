CREATE TABLE [dbo].[TB_COUNTRY] (
    [id]          INT          NOT NULL IDENTITY,
    [title]       VARCHAR (50) NOT NULL,
    [callingCode] VARCHAR (5)  NULL,
    [isActive] BIT NOT NULL DEFAULT 1, 
    [fk_currency_id] INT NOT NULL, 
    [fk_language_officialLan] CHAR(2) NOT NULL, 
    CONSTRAINT [PK_TB_COUNTRY] PRIMARY KEY CLUSTERED ([id] ASC), 
    CONSTRAINT [FK_TB_COUNTRY_TB_CURRENCY] FOREIGN KEY ([fk_currency_id]) REFERENCES [TB_CURRENCY]([id]), 
    CONSTRAINT [FK_TB_COUNTRY_TB_LANGUAGE] FOREIGN KEY ([fk_language_officialLan]) REFERENCES [TB_LANGUAGE]([id])
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'پیش شماره مربوط به هر کشور در همین جدول تعیین میشود',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_COUNTRY',
    @level2type = N'COLUMN',
    @level2name = N'callingCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'واحد پول هر کشور تعیین مشود',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_COUNTRY',
    @level2type = N'COLUMN',
    @level2name = N'fk_currency_id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'زبان اپ با  توجه به کشور انتخابی تعیین میشود',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_COUNTRY',
    @level2type = N'COLUMN',
    @level2name = N'fk_language_officialLan'