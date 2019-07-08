CREATE PROCEDURE [dbo].[SP_updateStoreCustomerGrouping]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@id as bigint ,
	@title as varchar(50),
	@color as varchar(15),
	@discountPercent as money,
	@isActive as bit
AS
	if(@title is null or RTRIM(ltrim(@title)) is null)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid title',OBJECT_NAME(@@PROCID),@clientLanguage,'عنوان گروه وارد نشده است'); 
			set @rCode = 0
			return
		end
	
	if(@discountPercent is null)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid discount',OBJECT_NAME(@@PROCID),@clientLanguage,'درصد تخفیف وارد نشده است'); 
			set @rCode = 0
			return
		end
		if(@storeId is null)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid discount',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه فروشگاه وارد نشده است'); 
			set @rCode = 0
			return
		end
		if(@storeId != (select fk_store_id from TB_STORE_CUSTOMER_GROUP where id = @id))
		begin
			set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'عملیات غیر مجاز'); 
			set @rCode = 0
			return
		end
	begin try
		update TB_STORE_CUSTOMER_GROUP set title = @title,discountPercent =@discountPercent,isActive = @isActive,color = @color where id = @id
		if(@@ROWCOUNT > 0)
		begin
			set @rCode = 1
			set @rMsg = 'success'
		end
		else
		begin
			set @rCode = 0
			set @rMsg = 'faild'
		end
	end try
	begin catch
		set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,'با پشتیبانی تماس بگیرید'); 
			set @rCode = 0
			return
	end catch
RETURN 0