CREATE PROCEDURE [dbo].[SP_updateTaxStoreSettings]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@taxRate as money,
    @taxIncludedInPrices as bit,
    @calculateTax as bit
AS
	SET NOCOUNT ON

	if(@taxRate < 0 or @taxRate > 1)
	begin
	set @rMsg = 'tax rate is not valid.';
	goto fail;
	end


		UPDATE TB_STORE SET taxRate = @taxRate,taxIncludedInPrices = @taxIncludedInPrices,calculateTax = @calculateTax WHERE ID = @storeId;

		if(@@ROWCOUNT <> 1)
		begin
		set @rMsg = 'store id is not valid';
		goto fail;
		end


	success:

SET @rCode = 1;
SET @rMsg = 'success.';

RETURN 0;

fail:

--ROLLBACK TRAN t1;

SET @rCode = 0;

RETURN 0;