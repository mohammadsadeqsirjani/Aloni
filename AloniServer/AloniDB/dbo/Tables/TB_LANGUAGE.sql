CREATE TABLE [dbo].[TB_LANGUAGE] (
    [id] CHAR (2) NOT NULL,
    [title] NVARCHAR(50) NOT NULL, 
    [isRTL] BIT NOT NULL, 
    CONSTRAINT [PK_TB_LANGUAGE] PRIMARY KEY CLUSTERED ([id] ASC)
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'جدول نگه داری از زبان های موجود در اپ 1_فارسی 2_غربی 3_انگلیسی 4_ ترکی', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_LANGUAGE';
