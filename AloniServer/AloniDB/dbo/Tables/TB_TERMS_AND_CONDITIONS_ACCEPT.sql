CREATE TABLE [dbo].[TB_TERMS_AND_CONDITIONS_ACCEPT] (
    [pk_fk_app_id]  TINYINT NOT NULL,
    [pk_fk_version] MONEY   NOT NULL,
    [fk_store_id]   BIGINT  NOT NULL,
    [fk_user_id]    BIGINT  NOT NULL,
    CONSTRAINT [PK_TB_TERMS_AND_CONDITIONS_ACCEPT] PRIMARY KEY CLUSTERED ([pk_fk_app_id] ASC, [pk_fk_version] ASC, [fk_store_id] ASC),
    CONSTRAINT [FK_TB_TERMS_AND_CONDITIONS_ACCEPT_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_TERMS_AND_CONDITIONS_ACCEPT_TB_TERMS_AND_CONDITIONS] FOREIGN KEY ([pk_fk_app_id], [pk_fk_version]) REFERENCES [dbo].[TB_TERMS_AND_CONDITIONS] ([pk_fk_app_id], [pk_version]),
    CONSTRAINT [FK_TB_TERMS_AND_CONDITIONS_ACCEPT_TB_USR] FOREIGN KEY ([fk_user_id]) REFERENCES [dbo].[TB_USR] ([id])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'هر فروشگاهی دارای شرایط و ضوابطی می باشند برای این که کاربران بتوانند از امکانات فروشگاه ها استفاده کنند بایستی این قوانین را بپذیرند این جدول کاربرانی این قوانین را پذیرفته اند را در خود ثبت میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TERMS_AND_CONDITIONS_ACCEPT';


