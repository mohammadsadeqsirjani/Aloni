CREATE PROCEDURE [dbo].[SP_addStoreEvaluation]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@comment as text,
	@rate as float
	
AS
	if((select fk_store_type_id from TB_STORE where id = @storeId) = 2 and (not exists(select pk_fk_usr_cstmrId from TB_STORE_CUSTOMER where pk_fk_usr_cstmrId = @userId and pk_fk_store_id = @storeId and fk_status_id = 32) or dbo.func_GetUserStaffStore(@userId,@storeId) not in(11,12,13,14)))
	begin
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'برای ثبت نظر باید پنل را دنبال کنید'); 
		set @rCode = 0
		return
			
	end
	--if(not exists(select fk_usr_customerId from TB_ORDER where fk_usr_customerId = @userId and fk_store_storeId = @storeId and [dbo].[func_getOrderStatus](id,fk_status_statusId,lastDeliveryDateTime) = 105))
	--begin
	--	set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'فقط کاربرانی قادر به ارسال نظر درباره پنل می باشند که سابقه خرید از پنل داشته باشند'); 
	--	set @rCode = 0
	--	return
	--end
	if(not exists(select id from TB_STORE where id = @storeId))
	begin
		set @rMsg = dbo.func_getSysMsg('invalid store',OBJECT_NAME(@@PROCID),@clientLanguage,'پنل معتبر نمی باشد'); 
		set @rCode = 0
		return
	end
	begin try
		declare @pricePurchese as money =isnull((select sum(credit) from TB_FINANCIAL_ACCOUNTING where fk_orderHdr_id in (select id from TB_ORDER where fk_usr_customerId = @userId and fk_store_storeId = @storeId and dbo.func_getOrderStatus(id,fk_status_statusId,lastDeliveryDateTime) = 105)),0)
		insert TB_STORE_EVALUATION(fk_store_id,fk_usr_id,rate,saveIp,comment,sumPurchese) values(@storeId,@userId,@rate,@clientIp,@comment,isnull(@pricePurchese,0))
		set @rMsg = dbo.func_getSysMsg('ok',OBJECT_NAME(@@PROCID),@clientLanguage,'success!'); 
		set @rCode = 1
	end try
	begin catch
		set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
		set @rCode = 1
	end catch
	
RETURN 0

