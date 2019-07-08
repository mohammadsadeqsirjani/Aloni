CREATE TABLE [dbo].[TB_TYP_DELIVERY_METHOD_TRANSLATION] (
    [id]    SMALLINT      NOT NULL,
    [title] VARCHAR (150) NOT NULL,
    [lan]   CHAR (2)      NOT NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ترجمه راه های ارسال مرسوله', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_DELIVERY_METHOD_TRANSLATION';
