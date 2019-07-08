CREATE TABLE [dbo].[TB_STORE_ITEM_SCHEDULE]
(
    [id] BIGINT NOT NULL IDENTITY, 
	 [fk_store_id] BIGINT NOT NULL,
    [fk_item_id] BIGINT NOT NULL,
    [onDayOfWeek] TINYINT NOT NULL, 
    [isActiveFrom] TIME(0) NOT NULL, 
    [activeUntil] TIME(0) NOT NULL, 
    CONSTRAINT [TB_STORE_ITEM_SCHEDULE_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [TB_STORE]([id]), 
    CONSTRAINT [CK_TB_STORE_ITEM_SCHEDULE_onDayOfWeek] CHECK ([onDayOfWeek] >= 0 and [onDayOfWeek] < 7), 
    CONSTRAINT [PK_TB_STORE_ITEM_SCHEDULE] PRIMARY KEY ([id])
)


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'این کالا در این فروشگاه در چه روزهایی از هفته در چه ساعاتی فعال میباشد', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_ITEM_SCHEDULE';

