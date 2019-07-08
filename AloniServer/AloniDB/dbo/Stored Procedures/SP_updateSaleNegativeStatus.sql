CREATE PROCEDURE [dbo].[SP_updateSaleNegativeStatus]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@canSalesNegative as bit
AS
	SET NOCOUNT ON
	begin try
		UPDATE TB_STORE
		SET canBeSalesNegative = @canSalesNegative
		WHERE
			id = @storeId
		UPDATE TB_STORE_ITEM_QTY
		SET canBeSalesNegative = @canSalesNegative
		WHERE
			pk_fk_store_id = @storeId
		set @rCode = 1
		set @rMsg = 'success' 
			
	end try
	begin catch
		set @rCode = 0
		set @rMsg =dbo.func_getSysMsg('errore',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
	end catch
RETURN 0
