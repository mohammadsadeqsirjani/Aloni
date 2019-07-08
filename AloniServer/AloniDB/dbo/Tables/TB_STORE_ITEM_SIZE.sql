CREATE TABLE [dbo].[TB_STORE_ITEM_SIZE]
(
	[pk_fk_store_id] BIGINT NOT NULL , 
    [pk_fk_item_id] BIGINT NOT NULL,



	 [pk_sizeInfo] VARCHAR(500) NOT NULL, 
    [isActive] BIT NOT NULL DEFAULT 1, 
    [sizeCost] MONEY NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_TB_STORE_ITEM_SIZE] PRIMARY KEY ([pk_fk_store_id], [pk_fk_item_id], [pk_sizeInfo]) 
)


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'انواع سایز بندی هر کالا در هر دسته ای از  کالا ها ر ا شامل میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_ITEM_SIZE';

