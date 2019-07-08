CREATE TABLE [dbo].[TB_STORE_EMPLOYEE] (
    [id]                BIGINT           IDENTITY (1, 1) NOT NULL,
    [fk_store_id]       BIGINT           NOT NULL,
    [fk_document_id]    UNIQUEIDENTIFIER NULL,
    [fullname]          NVARCHAR (50)    NOT NULL,
    [mobile]            VARCHAR (20)     NULL,
    [staff]             NVARCHAR (50)    NULL,
    [description]       NVARCHAR (500)   NULL,
    [fk_usr_saveUserId] BIGINT           NOT NULL,
    [saveDatetime]      DATETIME         NOT NULL,
    CONSTRAINT [PK_TB_STORE_EMPLOYEE] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_EMPLOYEE_TB_DOCUMENT] FOREIGN KEY ([fk_document_id]) REFERENCES [dbo].[TB_DOCUMENT] ([id]),
    CONSTRAINT [FK_TB_STORE_EMPLOYEE_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_STORE_EMPLOYEE_TB_USR] FOREIGN KEY ([fk_usr_saveUserId]) REFERENCES [dbo].[TB_USR] ([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'کارکنان یک فروشگاه را مشخص میکند و در عین حال مشخص میکند که کدام کارمند در چه وضعیتی از سیسنم اداری را شامل میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_EMPLOYEE';


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'رتبه بندی یک کارمند',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE_EMPLOYEE',
    @level2type = N'COLUMN',
    @level2name = N'staff'