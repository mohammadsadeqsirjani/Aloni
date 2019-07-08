CREATE TABLE [dbo].[TB_TECHNICALINFO_VALUES] (
    [id]                        BIGINT         IDENTITY (1, 1) NOT NULL,
    [fk_technicalinfo_table_id] INT            NOT NULL,
    [key]                       VARCHAR (8000) NOT NULL,
    [val]                       VARCHAR (8000) NOT NULL,
    [isActive]                  BIT            CONSTRAINT [DF__TB_TECHNI__isAct__386F4D83] DEFAULT ((1)) NOT NULL,
    [info1]                     VARCHAR (500)  NULL,
    [info2]                     VARCHAR (500)  NULL,
    CONSTRAINT [PK_TB_TECHNICALINFO_VALUES] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_TECHNICALINFO_VALUES_TB_TECHNICALINFO_TABLE] FOREIGN KEY ([fk_technicalinfo_table_id]) REFERENCES [dbo].[TB_TECHNICALINFO_TABLE] ([id])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'حال که عناوین مشخصات فنی کالاها مشخص شده است هر کالا خود دارای یک توضیحی از مشخصات فنی  می باشد', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TECHNICALINFO_VALUES';



