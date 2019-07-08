CREATE TABLE [dbo].[TB_SYSTEMMESSAGE] (
    [msgKey]     VARCHAR (50)   NOT NULL,
    [objectName] VARCHAR (60)   NOT NULL,
    [lan]        CHAR (2)       NOT NULL,
    [title]      NVARCHAR (250) NULL,
    [body]       NVARCHAR(MAX)           NOT NULL,
    [isSms] BIT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_TB_SYSTEMMESSAGE] PRIMARY KEY CLUSTERED ([msgKey] ASC, [objectName] ASC, [lan] ASC),
    CONSTRAINT [FK_TB_SYSTEMMESSAGE_TB_LANGUAGE] FOREIGN KEY ([lan]) REFERENCES [dbo].[TB_LANGUAGE] ([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'پیام های ارسال شده به  سمت کاربر را در خود ذخیره میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_SYSTEMMESSAGE';

