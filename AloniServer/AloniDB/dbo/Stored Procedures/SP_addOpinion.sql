CREATE PROCEDURE [dbo].[SP_addOpinion]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@itemId	as bigint,
	@comment as text,
	@rate as decimal,
	@saveIp as varchar(50)
AS
	-- در صورتی که شناسه فروشگاه به تنهایی مقدار داشت (یعنی نظرسنجی برای فروشگاه انجام شده است) کاربر ارزیاب حتما باید : 1- مشتری عضو مشتریان فروشگاه باشد 2- مشتری حداقل یک خرید انجام داده باشد
	if(@storeId is not null and @itemId is null)
	begin
		declare @customerInStore int = (select count(id) from TB_USR_STAFF where fk_usr_id = @userId and fk_store_id = @storeId)
		declare @purcheseFromStore int = (select count(id) from TB_ORDER where fk_usr_customerId = @userId and fk_store_storeId = @storeId and [dbo].[func_getOrderStatus](id,fk_status_statusId,lastDeliveryDateTime) = 105)--خاتمه یافته
		if(@customerInStore = 0) -- not folow store
		begin
			if(@purcheseFromStore = 0) -- not purchese from store
			begin
				set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'you dont permit to do this action!'); 
				set @rCode = 0
				return
			end
		end
		if((select count(id) from TB_STORE where id = @storeId) = 0)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid store',OBJECT_NAME(@@PROCID),@clientLanguage,'store not exist!'); 
			set @rCode = 0
			return
		end
		set @rCode = 1
		insert TB_STORE_ITEM_EVALUATION(fk_store_id,fk_usr_id,rate,saveIp,saveDateTime) values(@storeId,@userId,@rate,@saveIp,GETDATE())
		set @rMsg = dbo.func_getSysMsg('ok',OBJECT_NAME(@@PROCID),@clientLanguage,'success!'); 

	end -- end store
	if(@itemId is not null)
	begin
		declare @commentCntPerUser as int 
		declare @commentCntPerDayPerUser as int
		select @commentCntPerUser = commentCntPerUser,@commentCntPerDayPerUser = commentCntPerDayPerUser  from TB_STORE_ITEM_QTY where pk_fk_item_id = @itemId and pk_fk_store_id = @storeId
		if((select COUNT(id) from TB_ITEM where id = @itemId) = 0)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid item',OBJECT_NAME(@@PROCID),@clientLanguage,'کالایی با شناسه مورد نظر در فروشگاه موجود نمی باشد'); 
				set @rCode = 0
				return
		end
		if((select count(id) from TB_STORE_ITEM_EVALUATION where fk_item_id = @itemId and fk_store_id = @storeId and fk_usr_id = @userId) >= @commentCntPerUser and @commentCntPerUser > 0)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid item',OBJECT_NAME(@@PROCID),@clientLanguage,'تعداد نظرات شما برای این محصول به حداکثر مجاز رسیده است'); 
			set @rCode = 0
			return
		end
		if((select count(id) from TB_STORE_ITEM_EVALUATION where fk_item_id = @itemId and fk_store_id = @storeId and fk_usr_id = @userId and saveDateTime = GETDATE()) >= @commentCntPerDayPerUser  and @commentCntPerDayPerUser > 0)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid item',OBJECT_NAME(@@PROCID),@clientLanguage,'تعداد نظرات شما برای این محصول در یک روز به حداکثر مجاز رسیده است'); 
			set @rCode = 0
			return
		end
	end
	begin try
		declare @state int = (select ISNULL(itemEvaluationNeedConfirm,1) from TB_STORE where id = @storeId)
		insert TB_STORE_ITEM_EVALUATION(fk_item_id,fk_store_id,fk_usr_id,rate,saveIp,saveDateTime,comment,fk_status_id,fk_confirmUsr_id,confirmDate) values(@itemId,@storeId,@userId,@rate,@clientIp,GETDATE(),@comment,case when @state = 1 then 107 when (@state = 0 or @comment is null) then 106 END,case when @state = 1 then NULL else @userId END,case when @state = 1 then NULL else GETDATE() END)
		set @rCode = 1
		set @rMsg = 'success'
	end try
	begin catch
		set @rCode = 0
		set @rMsg = ERROR_MESSAGE()
	end catch
RETURN 0
