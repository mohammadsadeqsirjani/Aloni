CREATE TYPE [dbo].[UDT_order_dtl] AS TABLE
(
    --rowId int,
	itemId bigint,
	colorId varchar(20),
	sizeId varchar(500),
	warrantyId bigint,
	qty money
)
