CREATE FUNCTION [dbo].[func_getPriceAsDisplayValue_v2]
(
	@val money,
	@clientLanguage as char(2),
	@storeId as bigint,
	@currencyDsc as varchar(20)
)
RETURNS varchar(100)
AS
BEGIN

--declare @currencyDsc as varchar(20);
if(@currencyDsc is null)
begin
SELECT
				 @currencyDsc = isnull(CR.title, cu.Symbol)
			from  
				TB_STORE as s with(nolock) 
				inner join TB_COUNTRY as c  with(nolock)  on s.fk_country_id = c.id
				inner join TB_CURRENCY as cu  with(nolock)  on c.fk_currency_id = cu.id
				left join TB_CURRENCY_TRANSLATIONS CR  with(nolock)  on cu.id = CR.id and cr.lan = @clientLanguage
			where
				s.id = @storeId;
		end
	RETURN [dbo].[func_addThousandsSeperator](isnull(@val,0)) + ' ' + isnull(@currencyDsc,'');
END