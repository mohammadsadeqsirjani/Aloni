Go
CREATE TABLE [dbo].[TB_APP] (
    [id]    TINYINT      NOT NULL,
    [title] VARCHAR (50) NULL,
    CONSTRAINT [PK_TB_APP] PRIMARY KEY CLUSTERED ([id] ASC)
);

EXEC sys.sp_addextendedproperty @name=N'MS_Description',@value=N'1.customer 2.marketer 3.portal' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TB_APP'
