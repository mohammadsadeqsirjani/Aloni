CREATE PROCEDURE [dbo].[SP_PT_disableUserSession]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),

	@targetSessionId as bigint,
	--@authorization as char(128) out,
	--@sessionId as bigint out,
	--@unauthorized as bit out,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out
AS


			--declare @userId as bigint,@osType as tinyint;


			--exec [dbo].[SP_authenticateUser]
			--@sessionId = @sessionId,
			--@authorization = @authorization,
			--@userId = @userId OUTPUT,
			--@osType = @osType OUTPUT,
			--@appId = @appId,
			--@unauthorized = @unauthorized OUTPUT

			--if(@unauthorized = 1)
			--goto fail;



			update TB_USR_SESSION
			set fk_status_id = 5
			where 
			id = @targetSessionId
			

			 if(@@ROWCOUNT <> 1)
			 begin
			 set @rMsg = 'جلسه مورد نظر موجود نیست';
			 goto fail;
			 end


			 success:
			 set @rCode = 1;
			  set @rMsg = 'ردیف با موفقیت غیر فعال گردید .';
  					return 0;
				fail:
						set @rCode = 0;
						return 0;
