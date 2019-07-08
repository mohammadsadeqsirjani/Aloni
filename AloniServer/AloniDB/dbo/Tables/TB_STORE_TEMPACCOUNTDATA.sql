CREATE TABLE [dbo].[TB_STORE_TEMPACCOUNTDATA] (
    [id]                 BIGINT       IDENTITY (1, 1) NOT NULL,
    [fk_usr_session_id]  BIGINT       NOT NULL,
    [fk_store_id]        BIGINT       NOT NULL,
    [account]            VARCHAR (50) NOT NULL,
    [fk_bank_id]         INT          NULL,
    [saveDateTime]       DATETIME     NOT NULL,
    [validationCode]     CHAR (5)     NOT NULL,
    [validationDateTime] DATETIME     NULL,
    CONSTRAINT [PK_TB_STORE_TEMPACCOUNTDATA] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_TEMPACCOUNTDATA_TB_BANK] FOREIGN KEY ([fk_bank_id]) REFERENCES [dbo].[TB_BANK] ([id]),
    CONSTRAINT [FK_TB_STORE_TEMPACCOUNTDATA_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_STORE_TEMPACCOUNTDATA_TB_USR_SESSION] FOREIGN KEY ([fk_usr_session_id]) REFERENCES [dbo].[TB_USR_SESSION] ([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N' در این جدول درخواست های بانکی مربوط به هر فروشگاهی ثبت میشود از جمله درخواست تغییر شماره حساب یا درخواست پرداخت امن', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_TEMPACCOUNTDATA';