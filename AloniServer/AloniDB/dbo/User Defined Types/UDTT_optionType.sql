CREATE TYPE [dbo].[UDTT_optionType] AS TABLE (
    [existingOpinionPoolOptionId] BIGINT        NULL,
    [title]                       VARCHAR (MAX) NULL,
    [opinionpollId]               BIGINT        NULL,
    [isActive]                    BIT           NULL,
    [orderingNo]                  INT           NULL);


