CREATE TABLE [dbo].[TB_STORE_REPORT] (
    [id]                      BIGINT         IDENTITY (1, 1) NOT NULL,
    [fk_store_id]             BIGINT         NULL,
    [fk_usr_id]               BIGINT         NOT NULL,
    [description]             VARCHAR (MAX)  NULL,
    [saveDateTime]            DATETIME       NOT NULL,
    [fk_reportType_id]        INT            NULL,
    [titleResponse]           NVARCHAR (100) NULL,
    [dscResponse]             VARCHAR (350)  NULL,
    [fk_conversation_id]      BIGINT         NULL,
    [fk_orderId]              BIGINT         NULL,
    [fk_order_correspondence] BIGINT         NULL,
    CONSTRAINT [PK_TB_STORE_REPORT] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_REPORT_TB_CONVERSATION] FOREIGN KEY ([fk_conversation_id]) REFERENCES [dbo].[TB_CONVERSATION] ([id]),
    CONSTRAINT [FK_TB_STORE_REPORT_TB_ORDER] FOREIGN KEY ([fk_orderId]) REFERENCES [dbo].[TB_ORDER] ([id]),
    CONSTRAINT [FK_TB_STORE_REPORT_TB_ORDER1] FOREIGN KEY ([fk_order_correspondence]) REFERENCES [dbo].[TB_ORDER] ([id]),
    CONSTRAINT [FK_TB_STORE_REPORT_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_STORE_REPORT_TB_TYP_STORE_REPORT_TYPE] FOREIGN KEY ([fk_reportType_id]) REFERENCES [dbo].[TB_TYP_STORE_REPORT_TYPE] ([id]),
    CONSTRAINT [FK_TB_STORE_REPORT_TB_USR] FOREIGN KEY ([fk_usr_id]) REFERENCES [dbo].[TB_USR] ([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'گزارشات مربوط به  هر فروشگاه اعم از گزارش یک شکایت و ... در این جدول ذخیره میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_REPORT';






