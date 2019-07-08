CREATE TYPE [dbo].[WarantyType] AS TABLE (
	[warrantyId] bigint not null,
    [WarantyCo] nvarchar(50) NULL,
	[warrantyDays] int NULL,
	[warrantyCost] money NULL,
	[WarantyPrice_dsc] nvarchar(max) NULL
);