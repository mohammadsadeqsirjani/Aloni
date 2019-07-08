CREATE TABLE [dbo].[TB_COLOR_TRANSLATIONS]
(
	[id] VARCHAR(20) NOT NULL, 
    [lan] CHAR(2) NOT NULL, 
    [title] NVARCHAR(50) NOT NULL, 
    CONSTRAINT [PK_TB_COLOR_TRANSLATIONS] PRIMARY KEY ([lan], [id]) ,
    CONSTRAINT [FK_TB_COLOR_TRANSLATIONS_TB_COLOR] FOREIGN KEY ([id]) REFERENCES [TB_COLOR]([id]) ON UPDATE CASCADE ON DELETE CASCADE, 
    CONSTRAINT [FK_TB_COLOR_TRANSLATIONS_TB_LANGUAGE] FOREIGN KEY ([lan]) REFERENCES [TB_LANGUAGE]([id]), 
)
EXEC sys.sp_addextendedproperty @name=N'MS_Description',@value=N'با توجه به چند زبانه بودن اپ رنگها ترجمه میشوند و در این جدول ذخیره میشود' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TB_COLOR_TRANSLATIONS'
