CREATE FUNCTION [dbo].[func_getAvgOfOpinionsOfOption]
(
	@opinionOptionId as bigint
)
RETURNS money
AS
BEGIN
	return (select avg(score) from TB_STORE_ITEM_OPINIONPOLL_OPINIONS with(nolock) where pk_fk_opinionOption_id = @opinionOptionId)
END
