CREATE TABLE [dbo].[TB_STORE_ITEM_OPINIONPOLL_OPINIONS]
(
	[pk_fk_usr_id] BIGINT NOT NULL , 
    [pk_fk_opinionOption_id] BIGINT NOT NULL, 
    [score] MONEY NOT NULL, 
    [saveDateTime] DATETIME NOT NULL DEFAULT getdate(), 
    [saveIp] VARCHAR(50) NULL, 
  
    [fk_opinionPollId] BIGINT NOT NULL, 
    CONSTRAINT [PK_TB_STORE_ITEM_OPINIONPOLL_OPINIONS] PRIMARY KEY ([pk_fk_usr_id], [pk_fk_opinionOption_id]), 
    CONSTRAINT [FK_TB_STORE_ITEM_OPINIONPOLL_OPINIONS_TB_USR] FOREIGN KEY ([pk_fk_usr_id]) REFERENCES [TB_USR]([id]), 
    CONSTRAINT [FK_TB_STORE_ITEM_OPINIONPOLL_OPINIONS_TB_STORE_ITEM_OPINIONPOLL_OPTIONS] FOREIGN KEY ([pk_fk_opinionOption_id]) REFERENCES [TB_STORE_ITEM_OPINIONPOLL_OPTIONS]([id]), 
    CONSTRAINT [FK_TB_STORE_ITEM_OPINIONPOLL_OPINIONS_TB_STORE_ITEM_OPINIONPOLL] FOREIGN KEY ([fk_opinionPollId]) REFERENCES [TB_STORE_ITEM_OPINIONPOLL]([id])
)



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ممکن است هر نظرسنجی طراحی شده از سوی فروشگاه ها خود شامل  چندین زیر گروه باشد که کاربر با شرکت کردن انها اطلاعاتش در این جدول ذخیره میشود ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_ITEM_OPINIONPOLL_OPINIONS';

