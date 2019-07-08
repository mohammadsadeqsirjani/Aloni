CREATE PROCEDURE [dbo].[SP_deleteOrderAddress]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@id as bigint
AS
	--if(exists(select id from TB_ORDER_HDR where  fk_address_id = @id))
	--	begin
	--		set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,'این آدرس در سوابق سفارش شما موجود می باشد'); 
	--		set @rCode = 0
	--		return 0
	--	end
	update TB_ORDER_ADDRESS set isDeleted = 1 where id = @id
	if(@@ROWCOUNT > 0)
	begin
		
		set @rMsg = 'success'
	end
	else
	begin
		set @rMsg = dbo.func_getSysMsg('undefined id',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه آدرس در سیستم موجود نیست')
	end
	set @rCode = 1
RETURN 0
