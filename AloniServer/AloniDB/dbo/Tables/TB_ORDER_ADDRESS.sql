CREATE TABLE [dbo].[TB_ORDER_ADDRESS] (
    [id]               BIGINT            IDENTITY (1, 1) NOT NULL,
    [transfereeName]   NVARCHAR (250)    NULL,
    [transfereeMobile] NVARCHAR (20)     NOT NULL,
    [transfereeTell]   NVARCHAR (20)     NOT NULL,
    [fk_state_id]      INT               NOT NULL,
    [fk_city_id]       INT               NOT NULL,
    [postalCode]       NVARCHAR (20)     NULL,
    [postalAddress]    NVARCHAR (250)    NOT NULL,
    [location]         [sys].[geography] NOT NULL,
    [fk_usr_id]        BIGINT            NOT NULL,
    [nationalCode]     VARCHAR (11)      NULL,
    [countryCode]      VARCHAR (8)       NULL,
    [isDeleted]        BIT               NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_ORDER_ADDRESS_TB_CITY] FOREIGN KEY ([fk_city_id]) REFERENCES [dbo].[TB_CITY] ([id]),
    CONSTRAINT [FK_TB_ORDER_ADDRESS_TB_STATE] FOREIGN KEY ([fk_state_id]) REFERENCES [dbo].[TB_STATE] ([Id]),
    CONSTRAINT [FK_TB_ORDER_ADDRESS_TB_USR] FOREIGN KEY ([fk_usr_id]) REFERENCES [dbo].[TB_USR] ([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'کاربر سفارش دهنده را مشخص میکند و ادرس ارسال کالا را مشخص میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_ORDER_ADDRESS';
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'ادرس',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_ORDER_ADDRESS',
    @level2type = N'COLUMN',
    @level2name = N'location'