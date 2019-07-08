CREATE FUNCTION [dbo].[func_getCntOfOpinionsOfOption]
(
	@opinionOptionId as bigint
)
RETURNS int
AS
BEGIN
	return (select count(score) from TB_STORE_ITEM_OPINIONPOLL_OPINIONS with(nolock) where pk_fk_opinionOption_id = @opinionOptionId)
END