CREATE FUNCTION [dbo].[func_getOrderStatusList]
(
	 @orderId as bigint
	,@clientLanguage as char(2)
)
RETURNS @returntable TABLE
(
	ord smallint,
	title varchar(50),
	stat tinyint,--0:pass,1:on it,2: not reached yet
	orderId bigint
)
AS
BEGIN
	--INSERT @returntable
	--SELECT @param1, @param2
	--RETURN

	declare @orderStatusId as int,@reviewDateTime as datetime,@totalsent as money,@totalDelivered as money;


	--select @orderStatusId = os.id ,@reviewDateTime = o.reviewDateTime
 --   from TB_ORDER as o
	--join TB_STATUS as os on dbo.func_getOrderStatus(o.id,fk_status_statusId,o.lastDeliveryDateTime) = os.id
	--where o.id = @orderId;


	select 
	@orderStatusId = dbo.func_getOrderStatus(o.id,fk_status_statusId,o.lastDeliveryDateTime) ,
	@reviewDateTime = o.reviewDateTime
    from TB_ORDER as o
	where o.id = @orderId;

	select @totalsent = sum(d.sum_sent) , @totalDelivered = sum(d.sum_delivered)
	from dbo.func_getOrderDtls(@orderId,null) as d
	group by d.orderId;



	
	if(@orderStatusId in(101,102,105))
	begin

		declare @stateOneStatus as tinyint,@stateTwoStatus as tinyint,@stateThreeStatus as tinyint,@stateForStatus as tinyint;
		set @stateOneStatus = case when @orderStatusId = 100 then 2 when @orderStatusId = 101 and @reviewDateTime is null then 1 else 0 end;
		set @stateTwoStatus = case when @stateOneStatus = 0 and isnull(@totalsent,0) = 0 then 1 when @stateOneStatus = 0 and isnull(@totalsent,0) > 0  then 0 else 2 end;
		set @stateThreeStatus = case when @stateTwoStatus = 0 and isnull(@totalDelivered,0) = 0 then 1 when @stateTwoStatus = 0 and isnull(@totalDelivered,0) > 0 then 0 else 2 end;
		set @stateForStatus = case when @stateThreeStatus = 0 and @orderStatusId = 102 then 1 when @stateThreeStatus = 0 and @orderStatusId = 105 then 0 else 2 end;

		insert into @returntable values (1,'در انتظار بررسی', @stateOneStatus,@orderId);
		insert into @returntable values (2,'در انتظار ارسال',@stateTwoStatus,@orderId);
		insert into @returntable values (3,'در انتظار تحویل',@stateThreeStatus,@orderId);
		insert into @returntable values (4,'خاتمه',@stateForStatus,@orderId);

	end


	RETURN
END