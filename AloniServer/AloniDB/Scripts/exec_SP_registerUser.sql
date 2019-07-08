USE [AloniDB]
GO
--token generated with:      x*$)@SD#$^%+)R5~P(#*~J%S~F@*_#4%@!%@1329~7^|^3&%C.150000+989353753855
DECLARE	@return_value int,
		@unauthorized bit,
		@rCode tinyint,
		@rMessage nvarchar(max)

EXEC	@return_value = [dbo].[SP_registerUser]
		@lan = N'fa',
		@mobile = N'+989353753855',
		@countryId = 1,
		@appId = 1,
		@introducerUserId = NULL,
		@fname = N'سامان',
		@lname = N'ضیاالملکی',
		@authorization = N'17052DF635B3664B7EBBBD12F1827FCC11905B7050A082C2EC3F1F0431E5AA375026532335170B0DA1782000E0BF554AF407E96E06412551CFAF615BECAD4A71',
		@unauthorized = @unauthorized OUTPUT,
		@rCode = @rCode OUTPUT,
		@rMessage = @rMessage OUTPUT

SELECT	@unauthorized as N'@unauthorized',
		@rCode as N'@rCode',
		@rMessage as N'@rMessage'

SELECT	'Return Value' = @return_value

GO
