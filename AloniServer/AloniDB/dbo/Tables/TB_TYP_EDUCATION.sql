CREATE TABLE [dbo].[TB_TYP_EDUCATION] (
    [id]    SMALLINT     IDENTITY (1, 1) NOT NULL,
    [title] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_TB_TYP_EDUCATION] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'مدارک تحصیلی', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_EDUCATION';



