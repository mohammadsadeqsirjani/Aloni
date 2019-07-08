CREATE FUNCTION [dbo].[func_getCurrencyTitleByLanguage]
(
	@clientLanguage as char(2),
	@storeId as bigint
	
)
RETURNS varchar(50)
AS
BEGIN
	
	DECLARE @RESULT VARCHAR(50)
	declare @currencyId as int = (select C.fk_currency_id from TB_STORE S inner join TB_COUNTRY C on S.fk_country_id = c.id  where S.id = @storeId)
	
	select @RESULT = ISNULL(CT.title , C.Symbol )
	from TB_CURRENCY C 
	left join TB_CURRENCY_TRANSLATIONS CT
	on C.id = CT.id and CT.lan = @clientLanguage
	where C.id = @currencyId

	RETURN @RESULT
END
