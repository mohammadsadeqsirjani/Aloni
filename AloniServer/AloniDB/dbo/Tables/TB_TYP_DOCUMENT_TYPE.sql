CREATE TABLE [dbo].[TB_TYP_DOCUMENT_TYPE] (
    [id]    SMALLINT     NOT NULL,
    [title] VARCHAR (50) NULL,
    [isActive] BIT NULL DEFAULT 1, 
    CONSTRAINT [PK_TB_TYP_DOCUMENT_TYPE] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'انواع دسته بندی عناوین تصاویر', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_DOCUMENT_TYPE';


