CREATE TABLE [dbo].[TB_TYP_STORE_EXPERTISE] (
    [id]    INT          NOT NULL IDENTITY,
    [title] VARCHAR (50) NOT NULL,
    [isActive] BIT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_TB_TYP_STORE_EXPERTISE] PRIMARY KEY CLUSTERED ([id] ASC)
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'دسته بندی کالاها', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_STORE_EXPERTISE';

