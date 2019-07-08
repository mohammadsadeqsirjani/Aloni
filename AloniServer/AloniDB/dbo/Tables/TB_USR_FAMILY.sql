CREATE TABLE [dbo].[TB_USR_FAMILY] (
    [id]                      BIGINT         IDENTITY (1, 1) NOT NULL,
    [title]                   NVARCHAR (150) NOT NULL,
    [fk_usr_requester_usr_id] BIGINT         NOT NULL,
    [fk_usr_id]               BIGINT         NOT NULL,
    [saveDateTime]            DATETIME       CONSTRAINT [DF_TB_USR_FAMILY_saveDateTime] DEFAULT (getdate()) NOT NULL,
    [fk_status_id]            INT            NOT NULL,
    [modifyDatetime]          DATETIME       NULL,
    [reqTitle]                NVARCHAR (150) NULL,
    CONSTRAINT [PK_TB_USR_FAMILY] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_USR_FAMILY_TB_STATUS] FOREIGN KEY ([fk_status_id]) REFERENCES [dbo].[TB_STATUS] ([id]),
    CONSTRAINT [FK_TB_USR_FAMILY_TB_USR] FOREIGN KEY ([fk_usr_requester_usr_id]) REFERENCES [dbo].[TB_USR] ([id]),
    CONSTRAINT [FK_TB_USR_FAMILY_TB_USR1] FOREIGN KEY ([fk_usr_id]) REFERENCES [dbo].[TB_USR] ([id])
);






GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'46.isFamily 45. noFamily  44.Pending to review',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_USR_FAMILY',
    @level2type = N'COLUMN',
    @level2name = N'fk_status_id'