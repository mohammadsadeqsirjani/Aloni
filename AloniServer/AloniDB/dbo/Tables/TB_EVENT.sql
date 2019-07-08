CREATE TABLE [dbo].[TB_EVENT] (
    [id]    INT           IDENTITY (1, 1) NOT NULL,
    [title] VARCHAR (250) NOT NULL,
    CONSTRAINT [PK_TB_EVENT] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'اطلاعات مربوط به هر رویدادی را در خود ذخیره میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_EVENT';
