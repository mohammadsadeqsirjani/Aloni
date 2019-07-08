CREATE TABLE [dbo].[TB_STORE_EVALUATION_VOTE]
(
	[Id] BIGINT NOT NULL PRIMARY KEY IDENTITY, 
    [fk_store_evaluation_id] BIGINT NOT NULL, 
    [fk_usr_voteUsrId] BIGINT NOT NULL, 
    [like] BIT NOT NULL, 
    [dislike] BIT NOT NULL, 
    [saveDatetime] DATETIME NOT NULL DEFAULT getdate(), 
    CONSTRAINT [FK_TB_STORE_EVALUATION_VOTE_TB_STORE_EVALUATION] FOREIGN KEY (fk_store_evaluation_id) REFERENCES [dbo].[TB_STORE_EVALUATION](id), 
    CONSTRAINT [FK_TB_STORE_EVALUATION_VOTE_TB_USR] FOREIGN KEY (fk_usr_voteUsrId) REFERENCES [dbo].[TB_USR](id)
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'0',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE_EVALUATION_VOTE',
    @level2type = N'COLUMN',
    @level2name = N'like'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'0',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_STORE_EVALUATION_VOTE',
    @level2type = N'COLUMN',
    @level2name = N'dislike'
	
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'پاسخ دادن به نظرسنجی ها ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_EVALUATION_VOTE';

