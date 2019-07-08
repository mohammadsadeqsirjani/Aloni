CREATE PROCEDURE [dbo].[SP_socialNetworkAddUpdate]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@userId as bigint,
	@storeId as bigint,
	@id as bigint out,
	@socialType as varchar(50),
	@socialId as varchar(150)
AS
	SET NOCOUNT ON
	if(not exists(select top 1 * from TB_STORE where id = @storeId))
		begin
			set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه فروشگاه نامعتبر است'); 
			set @rCode = 0
			return 0
		end
	if(@socialType is null)
		begin
			set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,'نوع حساب مشخص نشده است.'); 
			set @rCode = 0
			return 0
		end
		if(@socialId is null)
		begin
			set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,' حساب مشخص نشده است.'); 
			set @rCode = 0
			return 0
		end
		begin try
		if(@id > 0 )
		begin
			update TB_STORE_SOCIALNETWORK set socialNetworkAccount = @socialId,socialNetworkType = @socialType where id = @id
			if(@@ROWCOUNT > 0)
			begin
				set @rMsg = 'success'
				set @rCode = 1
				return 0
			end
		end
		else
		begin
			insert into TB_STORE_SOCIALNETWORK(fk_store_id,socialNetworkType,socialNetworkAccount) values(@storeId,@socialType,@socialId)
				set @id = scope_identity()
				set @rMsg = 'success'
				set @rCode = 1
				return 0
		
		end
		end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,ERROR_MESSAGE())
	end catch
RETURN 0
