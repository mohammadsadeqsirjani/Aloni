CREATE PROCEDURE [dbo].[SP_updateReducedQty]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@percent as float
AS
	begin try
			UPDATE
				TB_STORE
			SET
				reducedQtyPercent = @percent / 100
			WHERE
				id = @storeId
		declare @rowCount as int = @@ROWCOUNT
		if(@rowCount > 0)
		Begin
			set @rMsg = 'success'
			set @rCode = 1
			
		END
		
	end try 
	begin catch
		set @rMsg = ERROR_MESSAGE()
		set @rCode = 0
		
	end catch
RETURN 0