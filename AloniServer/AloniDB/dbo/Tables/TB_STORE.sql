CREATE TABLE [dbo].[TB_STORE] (
    [id]                             BIGINT            IDENTITY (1, 1) NOT NULL,
    [title]                          NVARCHAR (150)    NOT NULL,
    [fk_status_id]                   INT               NULL,
    [fk_store_type_id]               INT               NOT NULL,
    [fk_store_category_id]           INT               NULL,
    [description]                    NVARCHAR (MAX)    NOT NULL,
    [description_second]             NVARCHAR (MAX)    NULL,
    [title_second]                   NVARCHAR (150)    NULL,
    [location]                       [sys].[geography] NULL,
    [email]                          VARCHAR (50)      NULL,
    [address]                        NVARCHAR (500)    NULL,
    [address_full]                   NVARCHAR (500)    NULL,
    [fk_city_id]                     INT               NULL,
    [fk_country_id]                  INT               CONSTRAINT [DF__TB_STORE__fk_cou__2010E169] DEFAULT ((1)) NULL,
    [verifiedAsOriginal]             BIT               NULL,
    [shiftStartTime]                 TIME (7)          NULL,
    [shiftEndTime]                   TIME (7)          NULL,
    [fk_status_shiftStatus]          INT               NULL,
    [keyWords]                       NVARCHAR (MAX)    NULL,
    [id_str]                         VARCHAR (50)      NOT NULL,
    [score]                          MONEY             CONSTRAINT [DF__TB_STORE__score__43E1002F] DEFAULT ((5)) NOT NULL,
    [ordersNeedConfimBeforePayment]  BIT               CONSTRAINT [DF__TB_STORE__orders__44D52468] DEFAULT ((0)) NOT NULL,
    [customerJoinNeedsConfirm]       BIT               CONSTRAINT [DF__TB_STORE__custom__45C948A1] DEFAULT ((0)) NOT NULL,
    [onlyCustomersAreAbleToSeeItems] BIT               CONSTRAINT [DF__TB_STORE__onlyCu__46BD6CDA] DEFAULT ((0)) NOT NULL,
    [onlyCustomersAreAbleToSetOrder] BIT               CONSTRAINT [DF__TB_STORE__onlyCu__47B19113] DEFAULT ((0)) NOT NULL,
    [taxRate]                        MONEY             CONSTRAINT [DF__TB_STORE__taxRat__2A212E2C] DEFAULT ((0)) NOT NULL,
    [taxIncludedInPrices]            BIT               CONSTRAINT [DF__TB_STORE__taxInc__70B3A6A6] DEFAULT ((1)) NOT NULL,
    [calculateTax]                   BIT               CONSTRAINT [DF__TB_STORE__calcul__71A7CADF] DEFAULT ((0)) NOT NULL,
    [canOrderWhenClose]              BIT               CONSTRAINT [DF__TB_STORE__canOrd__3FDB6521] DEFAULT ((0)) NOT NULL,
    [account]                        VARCHAR (50)      NULL,
    [fk_bank_id]                     INT               NULL,
    [fk_securePayment_StatusId]      INT               NULL,
    [fk_OnlinePayment_StatusId]      INT               NULL,
    [GetwayPaymentValidationCode]    CHAR (5)          NULL,
    [saveDatetime]                   DATETIME          CONSTRAINT [DF_TB_STORE_saveDatetime] DEFAULT (getdate()) NOT NULL,
    [second_lan_title]               VARCHAR (250)     NULL,
    [second_lan_about]               VARCHAR (500)     NULL,
    [second_lan_manager]             VARCHAR (50)      NULL,
    [second_lan_address]             VARCHAR (100)     NULL,
    [fk_storePersonalityType_id]     INT               NULL,
    [accessLevel]                    TINYINT           CONSTRAINT [DF_TB_STORE_accessLevel] DEFAULT ((0)) NOT NULL,
    [canBeSalesNegative]             BIT               NULL,
    [itemEvaluationShowName]         BIT               CONSTRAINT [DF_TB_STORE_itemEvaluationShowName] DEFAULT ((1)) NULL,
    [itemEvaluationNeedConfirm]      BIT               CONSTRAINT [DF_TB_STORE_itemEvaluationNeedConfirm] DEFAULT ((1)) NULL,
    [instagramAccount]               VARCHAR (250)     NULL,
    [telegramAccount]                VARCHAR (250)     NULL,
    [twitterAccount]                 VARCHAR (250)     NULL,
    [emailAccount]                   VARCHAR (250)     NULL,
    [rialCurencyUnit]                BIT               CONSTRAINT [DF_TB_STORE_rialCurencyUnit] DEFAULT ((0)) NULL,
    [autoSyncTimePeriod]             INT               NULL,
    [reducedQtyPercent]              FLOAT (53)        NULL,
    [itemOpinionCommentNeedConfirm]  BIT               NULL,
    CONSTRAINT [PK_TB_STORE] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_TB_CITY] FOREIGN KEY ([fk_city_id]) REFERENCES [dbo].[TB_CITY] ([id]),
    CONSTRAINT [FK_TB_STORE_TB_COUNTRY] FOREIGN KEY ([fk_country_id]) REFERENCES [dbo].[TB_COUNTRY] ([id]),
    CONSTRAINT [FK_TB_STORE_TB_STATUS] FOREIGN KEY ([fk_status_id]) REFERENCES [dbo].[TB_STATUS] ([id]),
    CONSTRAINT [FK_TB_STORE_TB_STATUS1] FOREIGN KEY ([fk_status_shiftStatus]) REFERENCES [dbo].[TB_STATUS] ([id]),
    CONSTRAINT [FK_TB_STORE_TB_STATUS2] FOREIGN KEY ([fk_securePayment_StatusId]) REFERENCES [dbo].[TB_STATUS] ([id]),
    CONSTRAINT [FK_TB_STORE_TB_STATUS3] FOREIGN KEY ([fk_OnlinePayment_StatusId]) REFERENCES [dbo].[TB_STATUS] ([id]),
    CONSTRAINT [FK_TB_STORE_TB_STATUS4] FOREIGN KEY ([fk_bank_id]) REFERENCES [dbo].[TB_STATUS] ([id]),
    CONSTRAINT [FK_TB_STORE_TB_TYP_STORE_CATEGORY] FOREIGN KEY ([fk_store_category_id]) REFERENCES [dbo].[TB_TYP_STORE_CATEGORY] ([id]),
    CONSTRAINT [FK_TB_STORE_TB_TYP_STORE_PERSONALITY_TYPE] FOREIGN KEY ([fk_storePersonalityType_id]) REFERENCES [dbo].[TB_TYP_STORE_PERSONALITY_TYPE] ([id]),
    CONSTRAINT [FK_TB_STORE_TB_TYP_STORE_TYPE] FOREIGN KEY ([fk_store_type_id]) REFERENCES [dbo].[TB_TYP_STORE_TYPE] ([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'اطلاعات مربوط به هر فروشگاه', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE';



























GO



GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'orders Need Confim Before Payment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE',
    @level2type = N'COLUMN',
    @level2name = N'ordersNeedConfimBeforePayment'
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TB_STORE]
    ON [dbo].[TB_STORE]([id_str] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0 : no permit to edit 1: permit all items 3 : permit some itemGrp base TB_STORE_ACCESSLEVEL', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE', @level2type = N'COLUMN', @level2name = N'accessLevel';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'مشخص کننده تنظیمات مربوط به نمایش/عدم نمایش نام نظر دهنده', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE', @level2type = N'COLUMN', @level2name = N'itemEvaluationShowName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'آیا نظرات کاربران بعد از تایید نمایش داده شوند؟', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE', @level2type = N'COLUMN', @level2name = N'itemEvaluationNeedConfirm';


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'وضعیت فروشگاه',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE',
    @level2type = N'COLUMN',
    @level2name = N'fk_status_id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'نوع فروشگاه',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE',
    @level2type = N'COLUMN',
    @level2name = N'fk_store_type_id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'دسته بندی فروشگاه',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE',
    @level2type = N'COLUMN',
    @level2name = N'fk_store_category_id'