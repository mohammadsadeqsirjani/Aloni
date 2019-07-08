CREATE TABLE [dbo].[TB_USR_STAFF] (
    [id]             BIGINT   IDENTITY (1, 1) NOT NULL,
    [fk_usr_id]      BIGINT   NOT NULL,
    [fk_staff_id]    SMALLINT NOT NULL,
    [fk_store_id]    BIGINT   NULL,
    [fk_status_id]   INT      NOT NULL,
    [saveTime]       DATETIME DEFAULT (getdate()) NOT NULL,
    [save_fk_usr_id] BIGINT   NULL,
    [description] NVARCHAR(150) NULL, 
    CONSTRAINT [PK_TB_USR_STAFF] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_USR_STAFF_TB_STAFF] FOREIGN KEY ([fk_staff_id]) REFERENCES [dbo].[TB_STAFF] ([id]),
    CONSTRAINT [FK_TB_USR_STAFF_TB_STATUS] FOREIGN KEY ([fk_status_id]) REFERENCES [dbo].[TB_STATUS] ([id]),
    CONSTRAINT [FK_TB_USR_STAFF_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_USR_STAFF_TB_USR] FOREIGN KEY ([fk_usr_id]) REFERENCES [dbo].[TB_USR] ([id]),
    CONSTRAINT [FK_TB_USR_STAFF_TB_USR1] FOREIGN KEY ([save_fk_usr_id]) REFERENCES [dbo].[TB_USR] ([id])
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شناسه کاربر',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_USR_STAFF',
    @level2type = N'COLUMN',
    @level2name = N'fk_usr_id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شناسه کارمند',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_USR_STAFF',
    @level2type = N'COLUMN',
    @level2name = N'fk_staff_id'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'شناسه فروشگاه',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_USR_STAFF',
    @level2type = N'COLUMN',
    @level2name = N'fk_store_id'

	GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول اطلاعات مربوط به کارمندانی است مه کاربر اپ کاستومر نیز هستندرا ثبت میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_USR_STAFF';