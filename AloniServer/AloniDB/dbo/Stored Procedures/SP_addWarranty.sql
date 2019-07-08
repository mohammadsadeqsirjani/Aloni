CREATE PROCEDURE [dbo].[SP_addWarranty]
  @clientLanguage as char(2),
  @appId as tinyint,
  @clientIp as varchar(50),
  @userId as bigint,
  @rCode as tinyint out,
  @rMsg as nvarchar(max) out,
  @itemId as bigint,
  @storeId as bigint,
  @warranty as [dbo].[WarantyType] readonly,
  @warrantyId as bigint out
AS
	set nocount on
	begin transaction T
	
		
		---- valid waranty 
		--if(@hasWaranty is not null and @hasWaranty = 1)
		--begin
		--	if((select count(*) from @waranty) = 0)
		--	begin
		--		set @rMsg = dbo.func_getSysMsg('invalid data',OBJECT_NAME(@@PROCID),@ClientLanguage, 'item has includes waranty but not defined any waranty for this!')
		--		goto faild
		--	end
		--end
		
		
		begin try
		-- insert into store waranti
				--if(@hasWaranty = 1)
				--begin
				    declare @tempWarranty as table([id] int not null identity, [WarantyCo] nvarchar(50) NULL,[warrantyDays] int NULL,[warrantyCost] money NULL)
					insert into @tempWarranty(WarantyCo,warrantyDays,warrantyCost) select WarantyCo,warrantyDays,warrantyCost from @warranty 
					declare @warantiCount int = (select count(WarantyCo) from @tempWarranty)
					declare @i int= 0;
					while(@i < @warantiCount)
					begin
						insert into TB_STORE_WARRANTY(fk_store_id,title) select @storeId,WarantyCo from @tempWarranty where id = @i + 1 
						declare @fkStoreWarantiId bigint = SCOPE_IDENTITY()
						insert into TB_STORE_ITEM_WARRANTY(pk_fk_store_id,pk_fk_item_id,pk_fk_storeWarranty_id,warrantyCost,warrantyDays)
									select @storeId,@itemId,@fkStoreWarantiId,warrantyCost,warrantyDays from @tempWarranty where id = @i + 1
						set @i+=1
					end -- wnd while
				--end
				set @warrantyId = @fkStoreWarantiId

		
		
				commit transaction T
				set @rCode = 1
				set @rMsg = 'success'
				return 
		end try
		begin catch
				set @rMsg = dbo.func_getSysMsg('Error',OBJECT_NAME(@@PROCID),@ClientLanguage,ERROR_MESSAGE())
				goto faild
		end catch
		faild:
				rollback transaction T
				set @rCode = 0
				return 0
RETURN 0