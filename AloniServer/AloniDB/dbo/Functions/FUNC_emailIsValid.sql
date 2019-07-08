
-- =============================================
-- Author:		Abolfazl Kabiri
-- Create date: 2019/01/12
-- Description:	Check Email
-- =============================================
CREATE FUNCTION FUNC_emailIsValid
(
	@email_address as varchar(max)
)
RETURNS bit
AS
BEGIN
	declare @result as bit = 0
	IF (
		CHARINDEX(' ',LTRIM(RTRIM(@email_address))) = 0 
		AND  LEFT(LTRIM(@email_address),1) <> '@' 
		AND  RIGHT(RTRIM(@email_address),1) <> '.' 
		AND  CHARINDEX('.',@email_address ,CHARINDEX('@',@email_address)) - CHARINDEX('@',@email_address ) > 1 
		AND  LEN(LTRIM(RTRIM(@email_address ))) - LEN(REPLACE(LTRIM(RTRIM(@email_address)),'@','')) = 1 
		AND  CHARINDEX('.',REVERSE(LTRIM(RTRIM(@email_address)))) >= 3 
		AND  (CHARINDEX('.@',@email_address ) = 0 AND CHARINDEX('..',@email_address ) = 0)
	   )
   set @result = 1
	
   return @result

END