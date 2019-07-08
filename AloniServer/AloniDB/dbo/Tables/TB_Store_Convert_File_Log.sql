CREATE TABLE [dbo].[TB_Store_Convert_File_Log] (
    [id]          BIGINT         IDENTITY (1, 1) NOT NULL,
    [fk_store_id] BIGINT         NOT NULL,
    [fk_groupId]  BIGINT         NOT NULL,
    [datetime]    DATETIME       CONSTRAINT [DF_TB_Store_Convert_File_Log_datetime] DEFAULT (getdate()) NOT NULL,
    [totalRecord] INT            NOT NULL,
    [isCompleted] BIT            NULL,
    [document]    NVARCHAR (350) NULL,
    [dsc]         NVARCHAR (350) NULL,
    CONSTRAINT [PK_TB_Store_Convert_File_Log] PRIMARY KEY CLUSTERED ([id] ASC)
);


