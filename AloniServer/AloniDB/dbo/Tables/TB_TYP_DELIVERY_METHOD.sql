CREATE TABLE [dbo].[TB_TYP_DELIVERY_METHOD] (
    [id]       SMALLINT      IDENTITY (1, 1) NOT NULL,
    [title]    VARCHAR (150) NOT NULL,
    [isActive] BIT           CONSTRAINT [DF_TB_TYP_DELIVERY_METHOD_isActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_TB_TYP_DELIVERY_METHOD] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'از طریق پیک ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'TB_TYP_DELIVERY_METHOD',
    @level2type = N'COLUMN',
    @level2name = N'id'

	
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'راه های ارسال مرسوله را مشخص میکند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_TYP_DELIVERY_METHOD';
