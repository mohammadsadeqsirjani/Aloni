
CREATE PROCEDURE [dbo].[SP_bulkyUpdateQtyPrice]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@itemList	as dbo.ViraSystemType readonly
AS
	begin try
		begin transaction T
			
			UPDATE
				TB_STORE_ITEM_QTY
			SET
				price = Table_C.price,
				qty = Table_C.qty,
				discount_percent =ISNULL(Table_C.discount,discount_percent),
				canBeSalesNegative = case when Table_C.qty < 0 then 1 else 0 END
			FROM
				@itemList AS Table_C
				INNER JOIN TB_ITEM AS Table_A
				ON Table_C.barcode = Table_A.barcode
				INNER JOIN TB_STORE_ITEM_QTY AS Table_B
				ON Table_A.id = Table_B.pk_fk_item_id AND Table_B.pk_fk_store_id = @storeId
			WHERE
				pk_fk_store_id = @storeId
		declare @rowCount as int = @@ROWCOUNT
		if(@rowCount > 0)
		Begin
			set @rMsg = CAST(@rowCount as varchar(100))+'مورد بروزرسانی شد '
			set @rCode = 1
			commit transaction T
		END
		
	end try 
	begin catch
		set @rMsg = ERROR_MESSAGE()
		set @rCode = 0
		rollback Transaction T
	end catch
RETURN 0
