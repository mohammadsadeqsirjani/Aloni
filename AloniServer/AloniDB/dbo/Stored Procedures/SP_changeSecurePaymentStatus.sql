CREATE PROCEDURE [dbo].[SP_changeSecurePaymentStatus]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint
AS
	
	declare @fk_securePayment_StatusId as int
	select @fk_securePayment_StatusId = fk_securePayment_StatusId from TB_STORE where id = @storeId
	if(not exists(select id from TB_STORE_TEMPACCOUNTDATA where fk_store_id = @storeId and fk_bank_id is null and validationDateTime is not null))
	begin
		set @rCode = 0 
		set @rMsg = dbo.func_getSysMsg('invalid request',OBJECT_NAME(@@PROCID),@clientLanguage,'invalid request')
		return
	end
	update TB_STORE set fk_securePayment_StatusId = case when @fk_securePayment_StatusId = 12 or @fk_securePayment_StatusId = 13 then 14 when @fk_securePayment_StatusId = 14 then 12 else NULL end  where id = @storeId
	set @rCode = 1
	set @rMsg = 'success'
	return


RETURN 0