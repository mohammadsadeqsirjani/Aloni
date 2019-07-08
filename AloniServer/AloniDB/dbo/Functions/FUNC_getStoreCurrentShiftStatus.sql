
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION FUNC_getStoreCurrentShiftStatus
(
	@storeId as bigint,
	@itemId as bigint
)
RETURNS bit
AS
BEGIN
	declare @result as bit
	;with scheduleInfo as (select * from TB_STORE_ITEM_SCHEDULE with(nolock) where fk_item_id = @itemId and fk_store_id = @storeId)
	select
			@result =
					case 
						when s.fk_status_shiftStatus = 17 then 1 when s.fk_status_shiftStatus = 18 then 0 
						when exists(
									select 
										1 
									from 
										scheduleInfo 
									where 
										onDayOfWeek = 
														case 
															 when DATEPART(dw,getdate()) = 7 then 0 
															 else DATEPART(dw,getdate()) 
														end
										AND 
											cast(GETDATE() as time(0)) >= isActiveFrom 
										AND 
											cast(GETDATE() as time(0)) < activeUntil 
									) then 1
						 else 0 
					end
	from
		tb_store s
	where
		s.id = @storeId
	return @result
END