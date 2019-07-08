CREATE TABLE [dbo].[TB_TYP_STORE_CATEGORY] (
    [id]    INT          NOT NULL,
    [title] VARCHAR (150) NOT NULL,
    [isActive] BIT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_TB_TYP_STORE_CATEGORY] PRIMARY KEY CLUSTERED ([id] ASC)
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'دسته بندی تمام کالا ها به مانند جدول TB-_TYP_STORE_EXPERTISE_TYPE میباشد', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_STORE_CATEGORY';
