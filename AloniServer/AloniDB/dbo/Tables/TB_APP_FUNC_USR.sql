CREATE TABLE [dbo].[TB_APP_FUNC_USR] (
    [id]          BIGINT        IDENTITY (1, 1) NOT NULL,
    [fk_func_id]  VARCHAR (100) NOT NULL,
    [fk_usr_id]   BIGINT        NULL,
    [fk_staff_id] SMALLINT      NULL,
    [fk_store_id] BIGINT        NULL,
    [hasAccess]   BIT           NOT NULL,
    CONSTRAINT [PK_TB_APP_FUNC_USR] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_APP_FUNC_USR_TB_APP_FUNC] FOREIGN KEY ([fk_func_id]) REFERENCES [dbo].[TB_APP_FUNC] ([id]) ON UPDATE CASCADE,
    CONSTRAINT [FK_TB_APP_FUNC_USR_TB_APP_FUNC_USR1] FOREIGN KEY ([fk_usr_id]) REFERENCES [dbo].[TB_APP_FUNC_USR] ([id]),
    CONSTRAINT [FK_TB_APP_FUNC_USR_TB_STAFF] FOREIGN KEY ([fk_staff_id]) REFERENCES [dbo].[TB_STAFF] ([id]),
    CONSTRAINT [FK_TB_APP_FUNC_USR_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [IX_TB_APP_FUNC_USR_UNQCHECK] UNIQUE NONCLUSTERED ([fk_func_id] ASC, [fk_usr_id] ASC, [fk_staff_id] ASC, [fk_store_id] ASC)
);

