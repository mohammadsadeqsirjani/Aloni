CREATE TABLE [dbo].[TB_BANK] (
    [id]            INT           IDENTITY (1, 1) NOT NULL,
    [title]         NVARCHAR (50) NOT NULL,
    [fk_country_id] INT           NOT NULL,
    CONSTRAINT [PK_TB_BANK] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_BANK_TB_COUNTRY] FOREIGN KEY ([fk_country_id]) REFERENCES [dbo].[TB_COUNTRY] ([id])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'عنوان',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_BANK',
    @level2type = N'COLUMN',
    @level2name = N'title'

	EXEC sys.sp_addextendedproperty @name=N'MS_Description',@value=N'اطلاعات مربوط به تراکنش های مالی در این جدول ذخیره میشود' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TB_BANK'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'با توجه به کشور انتخابی که در پیش شماره موبایل هنگام ثبت نام توسط کاربر وارد میشود واحد پول تعییت میشود',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_BANK',
    @level2type = N'COLUMN',
    @level2name = N'fk_country_id'