CREATE FUNCTION [dbo].[func_compare_versionCodes]
(
	@firstCode varchar(60),
	@secondCode varchar(60)
)
RETURNS smallint
AS
BEGIN
--بخاطر کدورژنهای قدیمی
if(LEN(@firstCode) - LEN(REPLACE(@firstCode, '.', '')) = 1)
set @firstCode = @firstCode + '.0'
if(LEN(@secondCode) - LEN(REPLACE(@secondCode, '.', '')) = 1)
set @secondCode = @secondCode + '.0'

	declare @diff as bigint,@done as tinyint;
	set @diff = 0;
	set @done = 3;
	while @diff = 0 and @done >= 1
	begin
	     set @diff =
		   cast(PARSENAME(REPLACE(@firstCode, ' ', '.'), @done) as bigint)
		 - cast(PARSENAME(REPLACE(@secondCode, ' ', '.'), @done) as bigint);
		 set @done = @done - 1;
	end
	return case when @diff < 0 then -1 when @diff = 0 then 0 when @diff > 0 then 1 end
END
