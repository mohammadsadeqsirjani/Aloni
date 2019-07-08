 CREATE TYPE [dbo].[TechnicalInfoItemType] AS TABLE (
    [technicalInfoId]                     INT            NULL,
    [technicalInfoTitle]                  NVARCHAR (MAX) NULL,
    [type]                                INT            NULL,
    [childTechnicalInfoId]                BIGINT         NULL,
    [childTechnicalInfoTitle]             VARCHAR (MAX)  NULL,
    [c_fk_technicalinfo_table_id]         INT            NULL,
    [technicalTableValueId]               BIGINT         NULL,
    [strValue]                            VARCHAR (MAX)  NULL,
    [fk_technicalInfoValues_tblValue_dsc] VARCHAR (MAX)  NULL,
    [isPublic]                            BIT            NULL);




  