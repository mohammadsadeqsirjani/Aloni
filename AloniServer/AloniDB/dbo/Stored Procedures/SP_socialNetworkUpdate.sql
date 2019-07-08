CREATE PROCEDURE [dbo].[SP_socialNetworkUpdate]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@userId as bigint,
	@storeId as bigint,
	@instagramAccount as varchar(250),
	@telegramAccount as varchar(250),
	@twitterAccount as varchar(250),
	@emailAccount as varchar(250)
AS
	SET NOCOUNT ON
	
		begin try
			update TB_STORE 
			set
				 instagramAccount = @instagramAccount,
				 telegramAccount = @telegramAccount,
				 twitterAccount = @twitterAccount,
				 emailAccount = @emailAccount 
			where id = @storeId
			if(@@ROWCOUNT > 0)
			begin
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
