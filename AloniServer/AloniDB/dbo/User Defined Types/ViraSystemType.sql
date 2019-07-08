CREATE TYPE [dbo].[ViraSystemType] AS TABLE (
    [isSelect] BIT           NULL,
    [title]    VARCHAR (MAX) NULL,
    [barcode]  VARCHAR (MAX) NULL,
    [price]    MONEY         NULL,
    [qty]      MONEY         NULL,
    [discount] MONEY         NULL);



