CREATE TABLE [dbo].[TB_STORE_MARKETING_MEMBER] (
    [id]                    BIGINT IDENTITY (1, 1) NOT NULL,
    [fk_parent_usr_id]      BIGINT NULL,
    [fk_usr_id]             BIGINT NOT NULL,
    [fk_store_marketing_id] BIGINT NOT NULL,
    CONSTRAINT [PK_TB_STORE_MARKETING_MEMBER] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_STORE_MARKETING_MEMBER_TB_STORE_MARKETING] FOREIGN KEY ([fk_store_marketing_id]) REFERENCES [dbo].[TB_STORE_MARKETING] ([id]),
    CONSTRAINT [FK_TB_STORE_MARKETING_MEMBER_TB_USR] FOREIGN KEY ([fk_parent_usr_id]) REFERENCES [dbo].[TB_USR] ([id]),
    CONSTRAINT [FK_TB_STORE_MARKETING_MEMBER_TB_USR1] FOREIGN KEY ([fk_usr_id]) REFERENCES [dbo].[TB_USR] ([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'چه کسانی در چه فروشگاهی بازاریاب میباشند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_MARKETING_MEMBER';

