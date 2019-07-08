CREATE PROCEDURE [dbo].[SP_getStoreCurrencyUnit]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint, 
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20) = null, 
	@storeId as bigint
AS
	set nocount on
	SELECT
		 cu.id,ISNULL(CR.title,cu.title) title,cu.Symbol
	from  
		TB_STORE as s with(nolock) inner join TB_COUNTRY as c  with(nolock)  on s.fk_country_id = c.id
		inner join TB_CURRENCY as cu  with(nolock)  on c.fk_currency_id = cu.id
		left join TB_CURRENCY_TRANSLATIONS as CR  with(nolock) on cu.id = CR.id and cr.lan = @clientLanguage
	where
		s.id = @storeId 
		and (@search is null or @search = '' or cu.title like '%'+@search+'%')

RETURN 0
