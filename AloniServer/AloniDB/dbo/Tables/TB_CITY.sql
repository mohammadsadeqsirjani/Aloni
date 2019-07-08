CREATE TABLE [dbo].[TB_CITY] (
    [id]            INT               IDENTITY (1, 1) NOT NULL,
    [title]         VARCHAR (50)      NOT NULL,
    [fk_country_id] INT               NOT NULL,
    [fk_state_id]   INT               NOT NULL,
    [isActive]      BIT               NOT NULL,
    [centerLoc]     [sys].[geography] NULL,
    CONSTRAINT [PK_TB_CITY] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_CITY_TB_COUNTRY] FOREIGN KEY ([fk_country_id]) REFERENCES [dbo].[TB_COUNTRY] ([id]),
    CONSTRAINT [FK_TB_CITY_TB_STATE] FOREIGN KEY ([fk_state_id]) REFERENCES [dbo].[TB_STATE] ([Id])
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'کشور انتخابی',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_CITY',
    @level2type = N'COLUMN',
    @level2name = N'fk_country_id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شهر انتخابی',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_CITY',
    @level2type = N'COLUMN',
    @level2name = N'fk_state_id'

	EXEC sys.sp_addextendedproperty @name=N'MS_Description',@value=N'شهر انتخابی با توجه به کشور انتخابی تعین میشود ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TB_CITY'