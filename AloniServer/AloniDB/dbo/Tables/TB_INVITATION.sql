CREATE TABLE [dbo].[TB_INVITATION] (
    [id]                   BIGINT       IDENTITY (1, 1) NOT NULL,
    [fk_usr_inviterUserId] BIGINT       NULL,
    [fk_store_id]          BIGINT       NULL,
    [fk_staff_id]          SMALLINT     NULL,
    [invitedUserMobile]    VARCHAR (50) NULL,
    [fk_status_id]         INT          NULL,
    CONSTRAINT [PK_TB_INVITATION] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_INVITATION_TB_STAFF] FOREIGN KEY ([fk_staff_id]) REFERENCES [dbo].[TB_STAFF] ([id]),
    CONSTRAINT [FK_TB_INVITATION_TB_STATUS] FOREIGN KEY ([fk_status_id]) REFERENCES [dbo].[TB_STATUS] ([id]),
    CONSTRAINT [FK_TB_INVITATION_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_INVITATION_TB_USR] FOREIGN KEY ([fk_usr_inviterUserId]) REFERENCES [dbo].[TB_USR] ([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول اطلاعات مربوط به دعوت کاربران از یکدیگر را شامل میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_INVITATION';
