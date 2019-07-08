create TABLE [dbo].[TB_APP_FUNC] (
    [id]          VARCHAR (100) NOT NULL,
    [description] VARCHAR (500) NULL,
    [area]        VARCHAR (100) NOT NULL,
    [fk_app_id]   TINYINT       NOT NULL,
    CONSTRAINT [PK_TB_APP_FUNC] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_APP_FUNC_TB_APP] FOREIGN KEY ([fk_app_id]) REFERENCES [dbo].[TB_APP] ([id])
);

go
EXEC sys.sp_addextendedproperty @name=N'MS_Description',@value=N'این جدول مشخص می کند که در یک اپ چه ماژول هایی به کار رفته است' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TB_APP_FUNC'

