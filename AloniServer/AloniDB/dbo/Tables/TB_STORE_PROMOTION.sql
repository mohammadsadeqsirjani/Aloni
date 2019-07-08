CREATE TABLE [dbo].[TB_STORE_PROMOTION] (
    [id]               BIGINT         IDENTITY (1, 1) NOT NULL,
    [fk_store_id]      BIGINT         NOT NULL,
    [promotionPercent] MONEY          NOT NULL,
    [promotionDsc]     VARCHAR(MAX) NOT NULL,
    [isActive]         BIT     CONSTRAINT [DF_TB_STORE_PROMOTION_isActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_TB_STORE_PROMOTION] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_PROMOTION_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در چه فروشکاهی  از تخیف های ویژه برخوردار میباشند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB-STORE_PROMOTION';