CREATE FUNCTION [dbo].[func_getCurrencyDscOfStore]
(
	@clientLanguage as char(2),
	@storeId as bigint
)
RETURNS varchar(20)
AS
BEGIN

return(select
				  isnull(CR.title, cu.Symbol)
			from  
				TB_STORE as s with(nolock) 
				inner join TB_COUNTRY as c  with(nolock)  on s.fk_country_id = c.id
				inner join TB_CURRENCY as cu  with(nolock)  on c.fk_currency_id = cu.id
				left join TB_CURRENCY_TRANSLATIONS CR  with(nolock)  on cu.id = CR.id and cr.lan = @clientLanguage
			where
				s.id = @storeId)
END