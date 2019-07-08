CREATE TABLE [dbo].[TB_STAFF] (
    [id]        SMALLINT     NOT NULL,
    [title]     VARCHAR (50) NULL,
    [fk_app_id] TINYINT      NULL,
    CONSTRAINT [PK_TB_STAFF] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STAFF_TB_APP] FOREIGN KEY ([fk_app_id]) REFERENCES [dbo].[TB_APP] ([id])
);



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'جدول رتبه بندی کارکنان', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STAFF';


