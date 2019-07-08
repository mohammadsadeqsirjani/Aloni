CREATE TABLE [dbo].[TB_STORE_EXPERTISE] (
    [pk_fk_store_id]     BIGINT NOT NULL,
    [pk_fk_expertise_id] INT    NOT NULL,
    CONSTRAINT [PK_TB_STORE_EXPERTISE] PRIMARY KEY CLUSTERED ([pk_fk_store_id] ASC, [pk_fk_expertise_id] ASC),
    CONSTRAINT [FK_TB_STORE_EXPERTISE_TB_STORE] FOREIGN KEY ([pk_fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_STORE_EXPERTISE_TB_TYP_STORE_EXPERTISE] FOREIGN KEY ([pk_fk_expertise_id]) REFERENCES [dbo].[TB_TYP_STORE_EXPERTISE] ([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'حوزه های فعالیت  هر فروشگاه ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_EXPERTISE';

