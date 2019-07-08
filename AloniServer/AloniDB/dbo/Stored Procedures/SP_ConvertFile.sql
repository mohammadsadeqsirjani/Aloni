
CREATE PROCEDURE [dbo].[SP_ConvertFile]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@groupId as bigint,
	@techStr as varchar(max) = NULL,
	@title varchar(250),
	@technicalTitle varchar(250) = null,
	@localBarcode varchar(250) = null,
	@provinceId varchar(10),
	@cityId varchar(10),
	@tb_name varchar(150),
	@barcode varchar(250),
	@sex varchar(250) = null,
	@unitName nvarchar(250),
	@categoryId bigint = 0,
	@type as smallint = NULL
AS
BEGIN
	SET NOCOUNT ON;
	declare @Itemtitle varchar(250)
	declare @ItemtechnicalTitle varchar(250)
	declare @ItemlocalBarcode varchar(250)
	declare @ItemBarcode varchar(250)
	declare @Itemsex varchar(2)
	declare @ItemprovinceId int
	declare @ItemcityId int
	declare @techId bigint
	declare @tbId int
	declare @ItemUnitName nvarchar(250)
	create table #tech([value] bigint,id int identity)
	insert into #tech([value]) select [value] from string_split(@techStr,',')
	create table #tt (title nvarchar(250),technicalTitle nvarchar(250),barcode nvarchar(250),sex bit,localBarcode nvarchar(250),unitName nvarchar(250),provinceId nvarchar(500),cityId nvarchar(500),id int)
	declare @itemId bigint
	 DECLARE @SQLString nvarchar(500)
	 if(@localBarcode is not null and @sex is not null)
	 begin
		 set @SQLString = N'insert into #tt (title,technicalTitle,barcode,sex,localBarcode,unitName,provinceId,cityId,id) SELECT  ' + quotename(@title) + ',' + quotename(@technicalTitle) + ','  +  quotename(@barcode) + ',' +  quotename(@sex) + ',' +  quotename(@localBarcode) + ',' +   quotename(@unitName) + ',' + quotename(@provinceId) + ','   +  quotename(@cityId) + ','   + 'id FROM ' + quotename(@tb_name)+ ' where [isOk] is null';
	 end
	 else if @localBarcode is not null
	 begin
		set @SQLString = N'insert into #tt (title,technicalTitle,barcode,localBarcode,unitName,provinceId,cityId,id) SELECT  ' + quotename(@title) + ',' + quotename(@technicalTitle) + ','  +  quotename(@barcode) + ',' +  quotename(@localBarcode) + ','  +   quotename(@unitName) + ',' +  quotename(@provinceId) + ','   +  quotename(@cityId) + ','   + 'id FROM ' + quotename(@tb_name)+ ' where [isOk] is null';
	 end
	 else if @sex is not null
	 begin
		set @SQLString = N'insert into #tt (title,technicalTitle,barcode,sex,unitName,provinceId,cityId,id) SELECT  ' + quotename(@title) + ',' + quotename(@technicalTitle) + ','  +  quotename(@barcode) + ',' +  quotename(@sex)  + ',' +   quotename(@unitName) + ',' +  quotename(@provinceId) + ','   +  quotename(@cityId) + ','   + 'id FROM ' + quotename(@tb_name)+ ' where [isOk] is null';
	 end
	
	 else
	 begin
		set @SQLString = N'insert into #tt (title,technicalTitle,barcode,unitName,provinceId,cityId,id) SELECT  ' + quotename(@title) + ',' + quotename(@technicalTitle) + ','  +  quotename(@barcode) + ',' + quotename(@unitName) + ',' + quotename(@provinceId) + ','   +  quotename(@cityId) + ','   + 'id FROM ' + quotename(@tb_name)+ ' where [isOk] is null';
	 end
    EXEC sp_executesql @SQLString
	
	declare cr cursor for
	select * from #tt
	open cr
	fetch next from cr into @itemTitle,@ItemtechnicalTitle,@ItemBarcode,@Itemsex,@ItemlocalBarcode,@ItemUnitName,@ItemprovinceId,@ItemcityId,@tbId
	while @@FETCH_STATUS = 0
	begin
	set @ItemBarcode = ISNULL(@ItemBarcode,'')
	set @ItemlocalBarcode = ISNULL(@ItemlocalBarcode,'')
		if(@title is null  or @barcode is null)
		begin
			set @rCode = 0
			set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,'ستون های مربوط به عنوان و بارکد باید مشخص شده باشد')
			return
		end
		begin try
			declare @message nvarchar(100) 
		    if @ItemBarcode <> '' and exists(select id from TB_ITEM where barcode = @ItemBarcode) -- کالا قبلا ادد شده است
			begin
				if (not exists(select pk_fk_item_id from TB_STORE_ITEM_QTY where pk_fk_store_id = @storeId) and exists(select top 1 id from TB_ITEM where barcode = @ItemBarcode))
				begin
					insert into TB_STORE_ITEM_QTY([pk_fk_store_id],[pk_fk_item_id],[qty],[inventoryControl],[price],[isNotForSelling],[prepaymentPercent],[cancellationPenaltyPercent],[canBePurchasedWithoutWarranty],[dontShowinginStoreItem],fk_status_id,localBarcode)
					select top 1 @storeId,id,0,0,0,0,0,0,0,0,15,@ItemlocalBarcode from TB_ITEM where barcode = @ItemBarcode
					set @itemId = (select id from TB_ITEM where barcode = @ItemBarcode)
					if(@categoryId is not null and @categoryId > 0)
					begin
						insert into TB_STORE_CUSTOMCATEGORY_ITEM(pk_fk_custom_category_id,pk_fk_item_id) values(@categoryId,@itemId)
					end
					set @message= 'کالا از قبل موجود بوده و تنها به فروشگاه اختصاص داده شد'
			    set @SQLString = N'update '+ quotename(@tb_name) + ' set [result] =@message , [isOk] = 1,itemId = @itemId where [id] = @tbId'
				EXEC sp_executesql @SQLString,N'@message nvarchar(100), @tbId int,@itemId bigint',@message=@message,@tbId=@tbId,@itemId = @itemId
					
				end
				else
				begin
					set @itemId = (select id from TB_ITEM where barcode = @ItemBarcode)
					if(@categoryId is not null and @categoryId > 0)
					begin
						if(not exists(select top 1 * from TB_STORE_CUSTOMCATEGORY_ITEM where pk_fk_custom_category_id = @categoryId and pk_fk_item_id = @itemId))
						begin
							insert into TB_STORE_CUSTOMCATEGORY_ITEM(pk_fk_custom_category_id,pk_fk_item_id) values(@categoryId,@itemId)
						end
					end
					set @message= 'کالا در فروشگاه شما موجود می باشد'
			    set @SQLString = N'update '+ quotename(@tb_name) + ' set [result] =@message , [isOk] = 0,itemId = isnull(@itemId,0) where [id] = @tbId'
				EXEC sp_executesql @SQLString,N'@message nvarchar(100), @tbId int,@itemId bigint',@message=@message,@tbId=@tbId,@itemId = @itemId
				end
			end
			else
			begin
				if(@ItemBarcode = '' and exists(select top 1 * from TB_ITEM where title = @Itemtitle and fk_savestore_id = @storeId))
				begin
					set @itemId = (select top 1 id from TB_ITEM where title = @Itemtitle and fk_savestore_id = @storeId)
					if(@categoryId is not null and @categoryId > 0)
					begin
						if(not exists(select top 1 * from TB_STORE_CUSTOMCATEGORY_ITEM where pk_fk_custom_category_id = @categoryId and pk_fk_item_id = @itemId))
						begin
							insert into TB_STORE_CUSTOMCATEGORY_ITEM(pk_fk_custom_category_id,pk_fk_item_id) values(@categoryId,@itemId)
						end
					end
					set @message= 'کالا در فروشگاه شما موجود می باشد'
					set @SQLString = N'update '+ quotename(@tb_name) + ' set [result] =@message , [isOk] = 0,itemId = isnull(@itemId,0) where [id] = @tbId'
					EXEC sp_executesql @SQLString,N'@message nvarchar(100), @tbId int,@itemId bigint',@message=@message,@tbId=@tbId,@itemId = @itemId
				end
				else
				begin
					insert into TB_ITEM(title,barcode,fk_unit_id,fk_itemGrp_id,isTemplate,fk_savestore_id,fk_usr_saveUser,fk_status_id,fk_country_Manufacturer,technicalTitle,fk_city_id,fk_state_id,sex,unitName,modifyDateTime,itemType) 
							values(@Itemtitle,case when @ItemBarcode is null or @ItemBarcode = '' then SUBSTRING(cast (rand() as varchar(20)),3,20) else @ItemBarcode end,0,@groupId,0,@storeId,1,20,1,@ItemtechnicalTitle,isNULL(@ItemcityId,2),isNULL(@ItemprovinceId,2),try_cast(@Itemsex as bit),@ItemUnitName,getdate(),@type)
					set @itemId = SCOPE_IDENTITY()
					if(@barcode is null)
					begin
						update TB_ITEM set barcode = dbo.func_getUniqueBarcodeItem(@itemId) where id = @itemId
					end
					insert into TB_STORE_ITEM_QTY([pk_fk_store_id],[pk_fk_item_id],[qty],[inventoryControl],[price],[isNotForSelling],[prepaymentPercent],[cancellationPenaltyPercent],[canBePurchasedWithoutWarranty],[dontShowinginStoreItem],fk_status_id,localBarcode,[uniqueBarcode])
					values(@storeId,@itemId,0,0,0,0,0,0,0,0,15,case when @ItemlocalBarcode is null or @ItemlocalBarcode = '' then SUBSTRING(cast (rand() as varchar(20)),3,20) else @ItemlocalBarcode end,dbo.func_getUniqueBarcodeItem(@itemId))
					if(@categoryId is not null and @categoryId > 0)
					begin
						insert into TB_STORE_CUSTOMCATEGORY_ITEM(pk_fk_custom_category_id,pk_fk_item_id) values(@categoryId,@itemId)
					end
					set @message= 'کالا با موفقیت اضافه شد'
					set @SQLString = N'update '+ quotename(@tb_name) + ' set [result] =@message , [isOk] = 1,itemId = @itemId where [id] = @tbId'
					EXEC sp_executesql @SQLString,N'@message nvarchar(100), @tbId int,@itemId bigint',@message=@message,@tbId=@tbId,@itemId=@itemId
				end
			end

			-- تکنیکال اینفو
			declare @techCnt int = (select COUNT(id) from #tech)
			declare @counter int = 1
			while @counter <= @techCnt
			begin
				if @itemId = 0 or @itemId is null break;
				set @techId = (select [value] from #tech where id = @counter)
				set @SQLString = N'insert into TB_ITEM_TECHNICALINFO(pk_fk_item_id, pk_fk_technicalInfo_id, strValue) values(@itemId,@techId,'+'(select '+ QUOTENAME('M_'+cast(@techId as nvarchar(100))) +'  from '+ QUOTENAME(@tb_name) + ' where id = @tbId))'
				exec sp_executesql @SQLString,N'@itemId bigint,@techId bigint,@tbId int',@itemId=@itemId,@techId=@techId,@tbId=@tbId
				set @counter += 1
			end
		end try
		begin catch
				set @message = error_message()
				--set @message= 'خطای نامشخص'
			    set @SQLString = N'update '+ quotename(@tb_name) + ' set [result] =@message , [isOk] = 0,itemId = 0 where [id] = @tbId'
				EXEC sp_executesql @SQLString,N'@message nvarchar(100), @tbId int',@message=@message,@tbId=@tbId
		end catch
	fetch next from cr into @itemTitle,@ItemtechnicalTitle,@ItemBarcode,@Itemsex,@ItemlocalBarcode,@ItemUnitName,@ItemprovinceId,@ItemcityId,@tbId
	end
	close cr
	deallocate cr
	
END