CREATE PROCEDURE [dbo].[SP_addStorePromotion]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@id as bigint out,
	@promotionDsc	as nvarchar(150),
	@promotionPercent as money,
	@isActive as bit
AS
	
	if(@promotionDsc is null or @promotionPercent is null  or @storeId is null)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'لطفا همه مقادیر را وارد نمایید'); 
		set @rCode = 0
		return
	end
	if(@promotionPercent > 100)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'درصد تخفیف وارد شده بیش از حد مجاز می باشد'); 
		set @rCode = 0
		return
	end
	
	begin try
		declare @valPercent as money = @promotionPercent / 100
		if(@id > 0 or exists(select id from TB_STORE_PROMOTION where fk_store_id = @storeId))
		begin
		    set @id = case when @id > 0 then @id else (select id from TB_STORE_PROMOTION where fk_store_id = @storeId) END
			UPDATE TB_STORE_PROMOTION
			SET
				fk_store_id = @storeId,
				promotionPercent = @valPercent,
				promotionDsc = @promotionDsc,
				isActive = @isActive
			WHERE
				 @id = id
			SET @rCode = 1
			SET @rMsg = 'success'
		end
		else
		begin
			
			insert TB_STORE_PROMOTION(fk_store_id,promotionPercent,promotionDsc) values (@storeId,@valPercent,@promotionDsc)
			set @id = SCOPE_IDENTITY()
			set @rCode = 1
			set @rMsg = dbo.func_getSysMsg('ok',OBJECT_NAME(@@PROCID),@clientLanguage,'success!'); 
		end
	end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('ok',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
	end catch
	

RETURN 0

