CREATE FULLTEXT INDEX ON [dbo].[TB_ITEM]
    ([title] LANGUAGE 1033, [barcode] LANGUAGE 1033, [technicalTitle] LANGUAGE 1033, [uniqueBarcode] LANGUAGE 1033)
    KEY INDEX [PK_TB_ITEM]
    ON [SearchItemCatalog];





