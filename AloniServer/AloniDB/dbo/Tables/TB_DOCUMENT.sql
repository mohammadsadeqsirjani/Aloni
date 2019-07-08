CREATE TABLE [dbo].[TB_DOCUMENT] (
    [id]                 UNIQUEIDENTIFIER NOT NULL,
    [fileName]           NVARCHAR (MAX)   NOT NULL,
    [caption]            NVARCHAR (250)   NULL,
    [fk_documentType_id] SMALLINT         NOT NULL,
    [description]        NVARCHAR (500)   NULL,
    [creationDate]       DATETIME         NULL,
    [linkUrl]            NVARCHAR (500)   NULL,
    [isDeleted]          BIT              CONSTRAINT [DF_TB_DOCUMENT_isDeleted] DEFAULT ((0)) NULL,
    [fk_usr_saveUserId]  BIGINT           NULL,
    [fk_usr_deletedId]   BIGINT           NULL,
    [type]               NVARCHAR (10)    NULL,
    [modifyDatetime]     DATETIME         NULL,
    [completeLink]       AS               ((([linkUrl]+CONVERT([varchar](36),[id]))+'.')+[type]),
    [thumbcompeleteLink] AS               (((([linkUrl]+'Thumb/')+CONVERT([varchar](36),[id]))+'.')+[type]) PERSISTED,
    CONSTRAINT [PK_TB_DOCUMENT] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_DOCUMENT_TB_TYP_DOCUMENT_TYPE] FOREIGN KEY ([fk_documentType_id]) REFERENCES [dbo].[TB_TYP_DOCUMENT_TYPE] ([id]),
    CONSTRAINT [FK_TB_DOCUMENT_TB_USR] FOREIGN KEY ([fk_usr_saveUserId]) REFERENCES [dbo].[TB_USR] ([id]),
    CONSTRAINT [FK_TB_DOCUMENT_TB_USR1] FOREIGN KEY ([fk_usr_deletedId]) REFERENCES [dbo].[TB_USR] ([id])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول اطلاعات مربوز به تصاویر تمام اپ ذخیره میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_DOCUMENT';














GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20181027-091943]
    ON [dbo].[TB_DOCUMENT]([fk_documentType_id] ASC, [completeLink] ASC, [thumbcompeleteLink] ASC);

