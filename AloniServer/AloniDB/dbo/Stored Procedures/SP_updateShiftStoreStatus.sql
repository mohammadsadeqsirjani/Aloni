CREATE PROCEDURE [dbo].[SP_updateShiftStoreStatus]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId bigint,
	@statusId tinyint
AS
	if((select fk_status_id from TB_STORE where id = @storeId) <> 13) -- store not active
	begin
		set @rMsg = 'Store status is not active' 
		set @rCode = 0
		goto fail
	end
	if(@statusId = 19) -- base on scheduling status
	begin
		if((select COUNT(id) from TB_STORE_SCHEDULE where fk_store_id = @storeId) = 0)
			begin
				set @rMsg = 'No time schedules are defined for the store.' 
				set @rCode = 0
				goto fail
			end
	end
	
	update TB_STORE set fk_status_shiftStatus = @statusId where id = @storeId
	set @rMsg = 'success'
	set @rCode = 1
	return 0
	fail:
		set @rCode = 0
RETURN 0

