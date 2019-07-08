CREATE TABLE [dbo].[TB_STATUS] (
    [id]         INT          NOT NULL,
    [title]      VARCHAR (50) NOT NULL,
    [entityType] VARCHAR (50) NOT NULL,
    [isRunning] BIT NULL, 
    CONSTRAINT [PK_TB_STATUS] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

CREATE UNIQUE INDEX [IX_TB_STATUS_title_entityType] ON [dbo].[TB_STATUS] ([title],[entityType])

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'تمام وضعیت های ممکن در اپ را مشخص میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STATUS';

