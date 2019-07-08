CREATE TABLE [dbo].[TB_ADVERTISING] (
    [id]                   BIGINT            IDENTITY (1, 1) NOT NULL,
    [dsc]                  NVARCHAR (500)    NULL,
    [fk_store_id]          BIGINT            NULL,
    [fk_item_id]           BIGINT            NULL,
    [url]                  VARCHAR (500)     NULL,
    [fk_city_id]           INT               NULL,
    [location]             [sys].[geography] NULL,
    [radius]               INT               NULL,
    [isActive]             BIT               CONSTRAINT [DF__TB_ADVERT__isAct__5A3A55A2] DEFAULT ((1)) NOT NULL,
    [fk_document_bannerId] UNIQUEIDENTIFIER  NULL,
    [selectEvent]          TINYINT           NOT NULL,
    [type]                 TINYINT           NOT NULL,
    CONSTRAINT [PK__TB_ADVER__3213E83F3674C73F] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_ADVERTISING_TB_CITY] FOREIGN KEY ([fk_city_id]) REFERENCES [dbo].[TB_CITY] ([id]),
    CONSTRAINT [FK_TB_ADVERTISING_TB_DOCUMENT] FOREIGN KEY ([fk_document_bannerId]) REFERENCES [dbo].[TB_DOCUMENT] ([id]),
    CONSTRAINT [FK_TB_ADVERTISING_TB_ITEM] FOREIGN KEY ([fk_item_id]) REFERENCES [dbo].[TB_ITEM] ([id]),
    CONSTRAINT [FK_TB_ADVERTISING_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id])
);



GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'رخدادی که درصورت انتخاب یا لمس تبلیغ اتفاق می افتد: 0 باز کردن آدرس لینک ، 1 باز کردن صفحه فروشگاه ، 2: باز کردن صفحه اطلاعات کالا',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ADVERTISING',
    @level2type = N'COLUMN',
    @level2name = N'selectEvent'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'نوع تبلیغات : 0 بنر ، 1 : فروشگاه برگزیده ، 2 : کالای برگزیده (پیشنهادی)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ADVERTISING',
    @level2type = N'COLUMN',
    @level2name = N'type'

	GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description',@value=N'
جدول مربوط به تبلیغات در سطح 
APP 
می  باشد 
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TB_ADVERTISING'
GO



GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شعاع نمایش تبلیغ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ADVERTISING',
    @level2type = N'COLUMN',
    @level2name = N'radius'