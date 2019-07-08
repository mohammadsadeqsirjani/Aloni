

CREATE PROCEDURE [dbo].[SP_UpdatePriceQtyFile]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@barcode varchar(250) = null,
	@price varchar(10),
	@qty varchar(10),
	@tb_name varchar(150)

AS
BEGIN
	SET NOCOUNT ON;
	
	declare @ItemBarcode varchar(250)
	declare @ItemPrice money
	declare @ItemQty money
	declare @ItemId bigint
	declare @tbId int

	
	create table #tt (barcode nvarchar(250),price nvarchar(500),qty nvarchar(500),id int)
	 DECLARE @SQLString nvarchar(500)
	 set @SQLString = N'insert into #tt (barcode,price,qty,id) SELECT  ' + quotename(@barcode) + ',' + quotename(@price) + ','  +  quotename(@qty) + ',' + 'id FROM ' + quotename(@tb_name)+ ' where [isOk] is null';
	 
    EXEC sp_executesql @SQLString
	
	declare cr cursor for
	select barcode,price,qty,id from #tt
	open cr
	fetch next from cr into @itemBarcode,@ItemPrice,@ItemQty,@tbId
	while @@FETCH_STATUS = 0
	begin
	   
		begin try
			declare @message nvarchar(100) 
		    if @ItemBarcode is null
			begin
					set @message= 'کالایی با بارکد وارد شده یافت نشد'
			        set @SQLString = N'update '+ quotename(@tb_name) + ' set [result] =@message , [isOk] = 0 where [id] = @tbId'
				    EXEC sp_executesql @SQLString,N'@message nvarchar(100), @tbId int',@message=@message,@tbId=@tbId
			end
			else
			begin
					set @itemId = (select top 1 id from TB_ITEM where barcode = @ItemBarcode and (fk_savestore_id = @storeId or (isTemplate = 1 and id in(select pk_fk_item_id from tb_store_item_qty where pk_fk_store_id = @storeId))))
					update TB_STORE_ITEM_QTY set price = ISNULL(TRY_CAST(@itemPrice as money),0),qty = ISNULL(TRY_CAST(@ItemQty as money),0) where pk_fk_store_id = @storeId and pk_fk_item_id = @ItemId
					if @@ROWCOUNT > 0
					begin
						set @message= 'تعداد و موجودی با موفقیت بروزرسانی شد'
						set @SQLString = N'update '+ quotename(@tb_name) + ' set [result] =@message , [isOk] = 1 where [id] = @tbId'
						EXEC sp_executesql @SQLString,N'@message nvarchar(100), @tbId int',@message=@message,@tbId=@tbId
					end
					else
					begin
						set @message= 'کالایی با بارکد وارد شده یافت نشد'
					    set @SQLString = N'update '+ quotename(@tb_name) + ' set [result] =@message , [isOk] = 0 where [id] = @tbId'
						EXEC sp_executesql @SQLString,N'@message nvarchar(100), @tbId int',@message=@message,@tbId=@tbId
					end
			end
			
		end try
		begin catch
				set @message = error_message()
			    set @SQLString = N'update '+ quotename(@tb_name) + ' set [result] =@message , [isOk] = 0 where [id] = @tbId'
				EXEC sp_executesql @SQLString,N'@message nvarchar(100), @tbId int',@message=@message,@tbId=@tbId
		end catch
	fetch next from cr into @itemBarcode,@ItemPrice,@ItemQty,@tbId
	end
	close cr
	deallocate cr
	
END