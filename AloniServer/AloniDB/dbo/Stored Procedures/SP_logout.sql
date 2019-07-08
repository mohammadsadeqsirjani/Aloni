CREATE PROCEDURE [dbo].[SP_logout]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),

	@userId as bigint,
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
			and
			fk_usr_id = @userId
			and
			fk_status_id = 4
			and
			 fk_app_id = @appId;

			 if(@@ROWCOUNT <> 1)
			 begin
			 set @rMsg = 'invalid targetSessionId';
			 goto fail;
			 end


			 success:
			 set @rCode = 1;
			  set @rMsg = 'success';
  					return 0;
				fail:
						set @rCode = 0;
						return 0;




