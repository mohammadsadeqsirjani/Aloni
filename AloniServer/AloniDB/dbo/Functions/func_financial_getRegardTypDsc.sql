CREATE FUNCTION [dbo].[func_financial_getRegardTypDsc]
(
	@regardTypeId int,
	@clientLanguage char(2)
)
RETURNS varchar(150)
AS
BEGIN
	declare @o as varchar(150);

	select @o = isnull(frt_trn.title,frt.title)
	from TB_TYP_FINANCIAL_REGARD_TYPE as frt with(nolock)
	left join TB_TYP_FINANCIAL_REGARD_TYPE_TRANSLATIONS as frt_trn with(nolock)
    on frt.id = frt_trn.id and frt_trn.lan = @clientLanguage
	where frt.id = @regardTypeId;

	return @o;

END
