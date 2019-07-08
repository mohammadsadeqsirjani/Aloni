CREATE PROCEDURE [dbo].[SP_addStoreCustomerGrouping]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@id as bigint out,
	@title as varchar(50),
	@color as varchar(15),
	@discountPercent as money
AS
	if(@title is null or RTRIM(ltrim(@title)) is null)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid title',OBJECT_NAME(@@PROCID),@clientLanguage,'عنوان گروه وارد نشده است'); 
			set @rCode = 0
			return
		end
	if(@storeId is null)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid store',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه فروشگاه وارد نشده است'); 
			set @rCode = 0
			return
		end
	if(@discountPercent is null)
		begin
			set @rMsg = dbo.func_getSysMsg('invalid discount',OBJECT_NAME(@@PROCID),@clientLanguage,'درصد تخفیف وارد نشده است'); 
			set @rCode = 0
			return
		end
	begin try
		insert into TB_STORE_CUSTOMER_GROUP(fk_store_id,title,discountPercent,saveIp,color) values (@storeId,@title,@discountPercent,@clientIp,@color)
		set @id = SCOPE_IDENTITY()
		set @rCode = 1
	end try
	begin catch
		set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
			set @rCode = 0
			return
	end catch
RETURN 0
