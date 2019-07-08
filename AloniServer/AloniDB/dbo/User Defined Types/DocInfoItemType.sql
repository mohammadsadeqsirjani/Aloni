CREATE TYPE [dbo].[DocInfoItemType] AS TABLE (
    [uid]           UNIQUEIDENTIFIER NULL,
    [id]            UNIQUEIDENTIFIER NULL,
    [isDefault]     BIT              NULL,
    [downloadLink]  NVARCHAR (500)   NULL,
    [thumbImageUrl] VARCHAR (500)    NULL);

