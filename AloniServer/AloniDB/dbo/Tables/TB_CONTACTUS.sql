CREATE TABLE [dbo].[TB_CONTACTUS] (
    [id]                 BIGINT       IDENTITY (1, 1) NOT NULL,
    [subject]            VARCHAR (50) NOT NULL,
    [mobile]             VARCHAR (50) NOT NULL,
    [email]              VARCHAR (20) NULL,
    [message]            TEXT         NOT NULL,
    [answer]             TEXT         NULL,
    [trackingCode]       VARCHAR (6)  NULL,
    [saveDateTime]       DATETIME     NOT NULL,
    [answerDateTime]     DATETIME     NULL,
    [saveIp]             VARCHAR (50) NULL,
    [fk_usr_answeredId]  BIGINT       NULL,
    [fk_deprtmentTypeId] INT          NOT NULL,
    CONSTRAINT [PK_TB_CONTACTUS] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_CONTACTUS_TB_TYP_CONTACTUS_DEPARTMENT] FOREIGN KEY ([fk_deprtmentTypeId]) REFERENCES [dbo].[TB_TYP_CONTACTUS_DEPARTMENT] ([id]),
    CONSTRAINT [FK_TB_CONTACTUS_TB_USR] FOREIGN KEY ([fk_usr_answeredId]) REFERENCES [dbo].[TB_USR] ([id])
);



GO

CREATE UNIQUE INDEX [IX_TB_UNQ_trackingCode] ON [dbo].[TB_CONTACTUS] ([trackingCode])

EXEC sys.sp_addextendedproperty @name=N'MS_Description',@value=N'این جدول مربوط به ارتباط با ماست' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TB_CONTACT'