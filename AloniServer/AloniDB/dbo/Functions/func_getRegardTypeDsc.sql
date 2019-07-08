CREATE FUNCTION [dbo].[func_getRegardTypeDsc]
(
	@regardTypeId as int
)
RETURNS varchar(500)
AS
BEGIN
	RETURN (select top (1) title from TB_TYP_FINANCIAL_REGARD_TYPE with(nolock) where id = @regardTypeId);
END
