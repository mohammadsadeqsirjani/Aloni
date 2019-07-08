CREATE TYPE StoreDeliveryType_Type as table
(
	    title  nvarchar(100) not null,
        cost  money not null,
        effectiveDeliveryCostOnInvoce  bit not null,
        maxSupportedDistancForDelivery  int not null,
        minPriceForActiveDeliveryType  money not null,
		isActive bit null default null,
		lat float null,
		lng float null,
		id bigint null
);