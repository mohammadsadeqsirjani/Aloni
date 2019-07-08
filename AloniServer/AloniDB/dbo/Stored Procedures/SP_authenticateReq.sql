CREATE PROCEDURE [dbo].[SP_authenticateReq]
		@mobile as varchar(25),
		@sessionId as bigint,
		@otpCode as varchar(5),
		@authorization as char(128),
		@unauthorized as bit out,
		@clientIp as varchar(150) = null

AS
	
	declare @secKey as char(50),@salt as int;
set @secKey = 'x*$)@SD#$^%+)R5~P(#*~J%S~F@*_#4%@!%@1329~7^|^3&%C.';
set @salt = 150000;
set @unauthorized = 1;
if(@clientIp is not null)
begin
	if(not exists(select top 1 id from TB_EXTERNAL_ACCESS_VALID where clientIp = @clientIp))
		set @unauthorized = 1
	else
		set @unauthorized = 0
end
else
begin
while ( @salt <= 150500 and @unauthorized = 1)
begin
if(@authorization = CONVERT(VARCHAR(128), HASHBYTES('SHA2_512', @secKey + 
CAST(@salt as varchar(10)) + 
isnull(@mobile,'') + 
isnull(cast(@sessionId as varchar(20)),'') +
isnull(@otpCode,'')), 2))
set @unauthorized = 0;
else
set @salt = @salt + 5;
end
end



RETURN 0
