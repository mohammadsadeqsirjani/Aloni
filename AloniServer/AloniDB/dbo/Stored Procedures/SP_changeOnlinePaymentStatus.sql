CREATE PROCEDURE [dbo].[SP_changeOnlinePaymentStatus]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@status as tinyint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint
AS
	
	declare @fk_OnlinePayment_StatusId as int
	select @fk_OnlinePayment_StatusId = fk_OnlinePayment_StatusId from TB_STORE where id = @storeId
	if(not exists(select id from TB_STORE_TEMPACCOUNTDATA where fk_store_id = @storeId and validationDateTime is not null))
	begin
		set @rCode = 0 
		set @rMsg = dbo.func_getSysMsg('invalid request',OBJECT_NAME(@@PROCID),@clientLanguage,'invalid request')
		return
	end
	update TB_STORE set fk_OnlinePayment_StatusId = 
	case when @status = 0 and fk_OnlinePayment_StatusId = 14 then 14 when @status = 1 and fk_OnlinePayment_StatusId = 14 then 13 else fk_OnlinePayment_StatusId end
	
	--case when @fk_OnlinePayment_StatusId = 12 or @fk_OnlinePayment_StatusId = 13 then 14 when @fk_OnlinePayment_StatusId = 14 then 12 else NULL end
	
    where id = @storeId
	set @rCode = 1
	set @rMsg = 'success'
	return


RETURN 0
