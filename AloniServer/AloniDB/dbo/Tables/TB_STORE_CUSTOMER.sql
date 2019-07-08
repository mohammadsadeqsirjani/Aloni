CREATE TABLE [dbo].[TB_STORE_CUSTOMER] (
    [pk_fk_store_id]    BIGINT   NOT NULL,
    [pk_fk_usr_cstmrId] BIGINT   NOT NULL,
    [fk_status_id]      INT      NOT NULL,
    [requestTime]       DATETIME NOT NULL,
    [fk_usr_requester]  BIGINT   NULL,
    [fk_usr_actionator] BIGINT   NULL,
    [actionTime]        DATETIME NULL,
    [notification] BIT NOT NULL DEFAULT 1, 
    [fk_customerGroup_id] BIGINT NULL, 
    CONSTRAINT [PK_TB_STORE_CUSTOMER] PRIMARY KEY CLUSTERED ([pk_fk_store_id] ASC, [pk_fk_usr_cstmrId] ASC),
    CONSTRAINT [FK_TB_STORE_CUSTOMER_TB_STATUS] FOREIGN KEY ([fk_status_id]) REFERENCES [dbo].[TB_STATUS] ([id]),
    CONSTRAINT [FK_TB_STORE_CUSTOMER_TB_STORE] FOREIGN KEY ([pk_fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_STORE_CUSTOMER_TB_USR] FOREIGN KEY ([pk_fk_usr_cstmrId]) REFERENCES [dbo].[TB_USR] ([id]),
    CONSTRAINT [FK_TB_STORE_CUSTOMER_TB_USR1] FOREIGN KEY ([fk_usr_requester]) REFERENCES [dbo].[TB_USR] ([id]),
    CONSTRAINT [FK_TB_STORE_CUSTOMER_TB_USR2] FOREIGN KEY ([fk_usr_actionator]) REFERENCES [dbo].[TB_USR] ([id]), 
    CONSTRAINT [FK_TB_STORE_CUSTOMER_TB_STORE_CUSTOMER_GROUP] FOREIGN KEY ([fk_customerGroup_id]) REFERENCES [TB_STORE_CUSTOMER_GROUP]([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'کاربرانی مه در یک فروشگاه عضو هستند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_CUSTOMER';

