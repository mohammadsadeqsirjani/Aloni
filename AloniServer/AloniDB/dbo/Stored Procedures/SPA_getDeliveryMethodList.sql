CREATE PROCEDURE [dbo].[SPA_getDeliveryMethodList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = NULL,
	@search as nvarchar(100),
	@parent as varchar(20) = null,
	@userId as bigint
AS
	set nocount on
	select
		d.id,
		isnull(sdr.title,d.title) title
	from
		
		 TB_TYP_DELIVERY_METHOD d
		 left join
		 TB_TYP_DELIVERY_METHOD_TRANSLATION sdr
		 on sdr.id = d.id and lan = @clientLanguage
	where
		d.isActive = 1
	
RETURN 0
