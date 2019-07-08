CREATE TABLE [dbo].[TB_REQUEST_CORRECTION_TEMPLATE_INFORMATION] (
    [id]                BIGINT        IDENTITY (1, 1) NOT NULL,
    [fk_item_id]        BIGINT        NOT NULL,
    [fk_usr_id]         BIGINT        NOT NULL,
    [fk_store_id]       BIGINT        NOT NULL,
    [requestDate]       DATETIME      CONSTRAINT [DF_TB_REQUEST_CORRECTION_TEMPLATE_INFORMATION_requestDate] DEFAULT (getdate()) NOT NULL,
    [suggestedTitle]    VARCHAR (150) NULL,
    [suggestedBarcode]  VARCHAR (150) NULL,
    [fk_status_id]      INT           CONSTRAINT [DF_TB_REQUEST_CORRECTION_TEMPLATE_INFORMATION_fk_status_id] DEFAULT ((401)) NULL,
    [reviewDateTime]    DATETIME      NULL,
    [fk_review_usr_id]  BIGINT        NULL,
    [reviewDescription] VARCHAR (500) NULL,
    [description]       VARCHAR (350) NULL,
    CONSTRAINT [PK_TB_REQUEST_CORRECTION_TEMPLATE_INFORMATION] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_TB_REQUEST_CORRECTION_TEMPLATE_INFORMATION_TB_ITEM] FOREIGN KEY ([fk_item_id]) REFERENCES [dbo].[TB_ITEM] ([id]),
    CONSTRAINT [FK_TB_REQUEST_CORRECTION_TEMPLATE_INFORMATION_TB_STATUS] FOREIGN KEY ([fk_status_id]) REFERENCES [dbo].[TB_STATUS] ([id]),
    CONSTRAINT [FK_TB_REQUEST_CORRECTION_TEMPLATE_INFORMATION_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id]),
    CONSTRAINT [FK_TB_REQUEST_CORRECTION_TEMPLATE_INFORMATION_TB_USR] FOREIGN KEY ([fk_usr_id]) REFERENCES [dbo].[TB_USR] ([id]),
    CONSTRAINT [FK_TB_REQUEST_CORRECTION_TEMPLATE_INFORMATION_TB_USR1] FOREIGN KEY ([fk_review_usr_id]) REFERENCES [dbo].[TB_USR] ([id])
);



	GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'در مورادی پیش می آید که برخی از اطلاعات مربوط به هر ایتم بااصل آن متفاوت است در این حالت کاربر با گزارش این موارد امکان ایین را فراهم می کنند که این اشکال را مرتفع کنند', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_REQUEST_CORRECTION_TEMPLATE_INFORMATION';