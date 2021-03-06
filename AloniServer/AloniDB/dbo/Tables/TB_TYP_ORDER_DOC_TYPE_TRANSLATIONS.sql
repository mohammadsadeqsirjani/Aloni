﻿CREATE TABLE [dbo].[TB_TYP_ORDER_DOC_TYPE_TRANSLATIONS]
(
	[id] SMALLINT NOT NULL , 
    [lan] CHAR(2) NOT NULL, 
    [title] NVARCHAR(50) NOT NULL, 
    CONSTRAINT [FK_TB_TYP_ORDER_DOC_TYPE_TRANSLATIONS_TB_TYP_ORDER_EVENT_TYPE] FOREIGN KEY ([id]) REFERENCES [TB_TYP_ORDER_DOC_TYPE]([id]) ON UPDATE CASCADE ON DELETE CASCADE, 
    CONSTRAINT [FK_TB_TYP_ORDER_DOC_TYPE_TRANSLATIONS_TB_LANGUAGE] FOREIGN KEY ([lan]) REFERENCES [TB_LANGUAGE]([id])
)


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در این جدول ترجمه تمام حالت های ثیت سفارش ثبت میشود', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_ORDER_DOC_TYPE_TRANSLATIONS';
