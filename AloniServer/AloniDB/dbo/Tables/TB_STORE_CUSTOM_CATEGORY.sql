CREATE TABLE [dbo].[TB_STORE_CUSTOM_CATEGORY] (
    [id]             BIGINT           IDENTITY (1, 1) NOT NULL,
    [title]          VARCHAR (150)    NOT NULL,
    [fk_store_id]    BIGINT           NOT NULL,
    [fk_document_id] UNIQUEIDENTIFIER NULL,
    [isActive] BIT NOT NULL DEFAULT 1, 
    [type] SMALLINT NULL, 
    CONSTRAINT [PK_TB_STORE_CUSTOM_CATEGORY] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_CUSTOM_CATEGORY_TB_DOCUMENT] FOREIGN KEY ([fk_document_id]) REFERENCES [dbo].[TB_DOCUMENT] ([id]),
    CONSTRAINT [FK_TB_STORE_CUSTOM_CATEGORY_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id])
);



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N' دسته بندی های اختصاصی که هر فروشگاه ایجاد میکند در این جدول ذخیره میشمود البته با این تفاوت که حتی دیتا ی این دسته بندی نیز توسط کاربر ایجاد میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_CUSTOM_CATEGORY';
