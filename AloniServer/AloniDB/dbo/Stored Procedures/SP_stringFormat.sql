CREATE PROCEDURE  [dbo].[SP_stringFormat]
(
	@value as nvarchar(max) =  '',
	@arg1 as nvarchar(max) = '',
	@arg2 as nvarchar(max) = '',
	@arg3 as nvarchar(max) = '',
	@arg4 as nvarchar(max) = '',
	@arg5 as nvarchar(max) = '',
	@arg6 as nvarchar(max) = '',
	@arg7 as nvarchar(max) = '',
	@arg8 as nvarchar(max) = '',
	@result as nvarchar(max) OUTPUT
)
AS
BEGIN
	SET @result = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@value,'{0}',@arg1),'{1}',@arg2),'{2}',@arg3),'{3}',@arg4),'{4}',@arg5),'{5}',@arg6),'{6}',@arg7),'{7}',@arg8);
END

