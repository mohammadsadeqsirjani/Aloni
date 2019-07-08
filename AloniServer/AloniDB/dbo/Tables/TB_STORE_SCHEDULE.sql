CREATE TABLE [dbo].[TB_STORE_SCHEDULE] (
    [id]           BIGINT   IDENTITY (1, 1) NOT NULL,
    [fk_store_id]  BIGINT   NOT NULL,
    [onDayOfWeek]  TINYINT  NOT NULL,
    [isActiveFrom] TIME (0) NOT NULL,
    [activeUntil]  TIME (0) NOT NULL,
    CONSTRAINT [PK__TB_STORE__3213E83F1219E94F] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [CK_TB_STORE_SCHEDULE_onDayOfWeek] CHECK ([onDayOfWeek]>=(0) AND [onDayOfWeek]<(7)),
    CONSTRAINT [FK_TB_STORE_SCHEDULE_TB_STORE] FOREIGN KEY ([fk_store_id]) REFERENCES [dbo].[TB_STORE] ([id])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'هر فروشکاه در چه روش هایی از هفته از چه ساعتی تا چه ساعتی فعال میباشد', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TB_STORE_SCHEDULE';