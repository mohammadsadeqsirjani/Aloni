CREATE TABLE [dbo].[TB_TYP_TECHNICALINFO] (
    [id]     BIGINT       IDENTITY (1, 1) NOT NULL,
    [title]  VARCHAR (50) NULL,
    [fk_ref] BIGINT       NULL,
    [type]   TINYINT      NULL,
    [fk_technicalinfo_page_id] SMALLINT NULL, 
    [fk_technicalinfo_table_id] INT NULL, 
    [order] SMALLINT NULL, 
    CONSTRAINT [PK_TB_TYP_TECHNICALINFO] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_TYP_TECHNICALINFO_TB_TYP_TECHNICALINFO] FOREIGN KEY ([fk_ref]) REFERENCES [dbo].[TB_TYP_TECHNICALINFO] ([id]), 
    CONSTRAINT [FK_TB_TYP_TECHNICALINFO_TB_TECHNICALINFO_PAGE] FOREIGN KEY ([fk_technicalinfo_page_id]) REFERENCES [TB_TECHNICALINFO_PAGE]([id]), 
    CONSTRAINT [FK_TB_TYP_TECHNICALINFO_TB_TECHNICALINFO_TABLE] FOREIGN KEY ([fk_technicalinfo_table_id]) REFERENCES [TB_TECHNICALINFO_TABLE]([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'دسته بندی های مشخصات فنی را شامل میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_TECHNICALINFO';


