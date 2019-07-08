CREATE PROCEDURE [dbo].[SP_authenticateUser]
	@sessionId as bigint,
	@authorization as char(128),
	@checkAccess as bit = 1,
	@funcId as varchar(50),
	@storeId as bigint,
	@orderId as bigint,
	@appVersion as varchar(60) out,
	@userId as bigint out,
	@osType as tinyint out,
	@staffId as smallint out,
	@appId as tinyint out,
	--@termsAndConditions_LastAccepted as bigint out,
	@unauthorized as bit out,
	@accessDenied as bit = 0 out,
	@clientIp as varchar(150) = null
AS
	set @unauthorized = 1;
	set @accessDenied = 1;
	--declare @UserStatus as int;
	--declare @stafId as int,


	--if(@checkAccess = 1 and @orderHdrId is not null)
	--begin
	--if(exists select )
	--end

	--declare @dbAppVersion as money;


	select
	@unauthorized = 0,
	@userId = u.id, --usession.fk_usr_id,
	--@stafId = st.id,
	@osType = usession.osType,
	@appId =usession.fk_app_id,
	@staffId = ust.fk_staff_id,
	@accessDenied = case when @checkAccess = 0 then 0 when fu.id is null then 1 else 0 end,
	--@dbAppVersion = usession.appVersion
	@appVersion = usession.appVersion
	--@termsAndConditions_LastAccepted = usession.fk_termsAndConditions_LastAccepted
	from TB_USR_SESSION as usession with (nolock)
	join TB_USR as u with (nolock)
	on usession.fk_usr_id = u.id
	left join TB_USR_STAFF as ust with (nolock) 
	on u.id = ust.fk_usr_id and (@appId <> 1 or (@storeId is not null and ust.fk_store_id = @storeId and ust.fk_status_id = 8))--TODO: برای اینکه یک کاربر در یک فروشگاه بیش از یک سمت نپذیرد ، حتما یونیک ایندکس ایجاد شود.
	--left join TB_STAFF as st with(nolock)
	--on ust.fk_staff_id = st.id	
	left join TB_APP_FUNC apf with (nolock)
	on apf.id = @funcId and apf.fk_app_id = @appId
	left join TB_APP_FUNC_USR fu with(nolock)
	on fu.fk_func_id = apf.id and fu.hasAccess = 1 and (fu.fk_staff_id = ust.fk_staff_id or fu.fk_usr_id = u.id)


	where
	usession.id = @sessionId
	and
	usession.token = HASHBYTES('SHA2_512', @authorization + CAST(@sessionId as varchar(20)))
	and
	usession.fk_status_id = 4--active
	and
	u.fk_status_id = 1--active
	and
	usession.fk_app_id = @appId;



	if(@checkAccess = 1 and @orderId is not null)
	begin
	    declare @orderCstmr as bigint,@orderStore as bigint;
	    select @orderCstmr = fk_usr_customerId, @orderStore = fk_store_storeId from TB_ORDER with(nolock) where id = @orderId;
		if(@orderCstmr is null or @orderStore is null or (@appId = 1 and @storeId <> @orderStore) or (@appId = 2 and @orderCstmr <> @userId))
			begin
			set @accessDenied = 1;
		end
	end

	if(@clientIp is not null)
	begin
		if(not exists(select top 1 id from TB_EXTERNAL_ACCESS_VALID where clientIp = @clientIp))
			set @unauthorized = 1
	end
	--and
	--((@appId <> 1 ) or (@appId = 1 and @storeId is null) or (@appId = 1 and @storeId is not null and @storeId = ust.fk_store_id ))
	--and
	--(@checkAccess = 0 or (fu.id is not null))


	--if(@unauthorized = 0 and @appVersion is not null and (@dbAppVersion is null or @dbAppVersion < @appVersion))
	--begin
	--   update TB_USR_SESSION set appVersion = @appVersion where id = @sessionId;
	--end




	set @accessDenied = 0;
	if(@checkAccess = 1)
	begin 
		select @accessDenied = fu.hasAccess
		from TB_APP_FUNC apf with (nolock) 
		inner  join TB_APP_FUNC_USR fu with(nolock) on apf.id = fu.fk_func_id
		where  
			apf.id = @funcId
			and
			dbo.func_GetUserStaffStore(@userId,@storeId) = fu.fk_staff_id
			--and
			--apf.fk_app_id = @appId
	end
RETURN 0
