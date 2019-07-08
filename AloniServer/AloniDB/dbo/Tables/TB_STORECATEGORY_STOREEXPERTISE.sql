CREATE TABLE [dbo].[TB_STORECATEGORY_STOREEXPERTISE]
(
	[pk_fk_storeCategory_id] INT NOT NULL , 
    [pk_fk_storeExpertise_id] INT NOT NULL, 
    CONSTRAINT [PK_TB_STORECATEGORY_STOREEXPERTISE] PRIMARY KEY ([pk_fk_storeCategory_id], [pk_fk_storeExpertise_id]), 
    CONSTRAINT [FK_TB_STORECATEGORY_STOREEXPERTISE_TB_TYP_STORE_EXPERTISE] FOREIGN KEY ([pk_fk_storeExpertise_id]) REFERENCES [TB_TYP_STORE_EXPERTISE]([id]), 
    CONSTRAINT [FK_TB_STORECATEGORY_STOREEXPERTISE_TB_TYP_STORE_CATEGORY] FOREIGN KEY ([pk_fk_storeCategory_id]) REFERENCES [TB_TYP_STORE_CATEGORY]([id])
)

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ین جدول دیگر استفاده نمیشود و با ابن حال مشخص میکند که هر فروشگاه در چه زمینه ای از  زمینه های کلی تر مشغول فعالیت میباشند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORECATEGOTY_STOREEXPERTISE';