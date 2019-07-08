CREATE TABLE [dbo].[TB_TECHNICALINFO_PAGE]
(
	[Id] SMALLINT NOT NULL PRIMARY KEY IDENTITY, 
    [fk_technicalinfo_page_id] SMALLINT NULL, 
    [title] VARCHAR(150) NOT NULL, 
    [isActive] BIT NOT NULL DEFAULT 0, 
    CONSTRAINT [FK_TB_TECHNICALINFO_PAGE_TB_TECHNICALINFO_PAGE] FOREIGN KEY ([fk_technicalinfo_page_id]) REFERENCES [TB_TECHNICALINFO_PAGE](id)
)

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'اطلاعات مربوط به صفحه مشخصات فنی در این جدول ذخیره میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TECHNICALINFO_PAGE';