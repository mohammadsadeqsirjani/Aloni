CREATE FUNCTION [dbo].[func_languageIsRTL]
(
	@lanId as char(2)
)
RETURNS INT
AS
BEGIN
	return (select isRTL from TB_LANGUAGE with(nolock) where id = @lanId);
END
