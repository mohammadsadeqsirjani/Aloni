CREATE TABLE [dbo].[TB_STORE_FAVORITE_LOCATION] (
    [id]          BIGINT            IDENTITY (1, 1) NOT NULL,
    [title]       NVARCHAR (100)    NOT NULL,
    [fk_store_id] BIGINT            NOT NULL,
    [location]    [sys].[geography] NOT NULL,
    [address]     NVARCHAR (250)    NOT NULL,
    CONSTRAINT [PK_TB_STORE_ITEM_LOCATION_1] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_ITEM_LOCATION_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N' فروشگاه های منتخب هر کاربر', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_FAVORITE_LOCATION';

