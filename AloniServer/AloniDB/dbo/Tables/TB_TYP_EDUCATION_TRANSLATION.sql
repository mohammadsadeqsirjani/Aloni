CREATE TABLE [dbo].[TB_TYP_EDUCATION_TRANSLATION] (
    [id]    SMALLINT     NOT NULL,
    [title] VARCHAR (50) NOT NULL,
    [lan]   CHAR (2)     NOT NULL,
    CONSTRAINT [FK_TB_TYP_EDUCATION_TRANSLATION_TB_TYP_EDUCATION] FOREIGN KEY ([id]) REFERENCES [dbo].[TB_TYP_EDUCATION] ([id])
);



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ترجمه مدارک تحصیلی', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_EDUCATION_TRANSLATION';



