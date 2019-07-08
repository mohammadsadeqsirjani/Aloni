CREATE TABLE [dbo].[TB_CURRENCY] (
    [id]     INT          NOT NULL,
    [title]  NCHAR (10)   NOT NULL,
    [Symbol] VARCHAR (20) NOT NULL,
    CONSTRAINT [PK__TB_CURRE__3213E83FF2DCC512] PRIMARY KEY CLUSTERED ([id] ASC)
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول واحد پول هر کشوری نگه داری میشود به همراه سمبل نمایانگر ان', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_CURRENCY';
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول واحد پول هر کشوری نگه داری میشود به همراه سمبل نمایانگر ان', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_CURRENCY';




