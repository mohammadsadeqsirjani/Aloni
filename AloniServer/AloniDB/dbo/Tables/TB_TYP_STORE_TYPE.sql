CREATE TABLE [dbo].[TB_TYP_STORE_TYPE] (
    [id]    INT          NOT NULL,
    [title] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_TB_TYP_STORE_TYPE] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول اطلاعات مربوط به دسته بندی های فروشگاه ها را شامل میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_STORE_TYPE';


