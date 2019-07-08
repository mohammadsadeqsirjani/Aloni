create PROCEDURE [dbo].[SP_order_addressGetList]
		@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20),
	@userId as bigint = null
AS
	


	select distinct oh.id, oa.postalAddress as deliveryAddress from TB_ORDER_HDR as oh with(nolock)
	join TB_ORDER as o on oh.fk_order_orderId = o.id
	join TB_ORDER_ADDRESS as oa on oh.fk_address_id = oa.id
	where o.fk_usr_customerId = @userId and oh.fk_address_id is not null and 
	(@search is null or oa.postalAddress like '%'+@search+'%')
		ORDER BY oh.id
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;
