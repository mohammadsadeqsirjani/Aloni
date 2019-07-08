CREATE PROCEDURE [dbo].[SP_addSubscribe]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@parentUserId as bigint,
	@subscribeUserId as bigint,
    @planId as bigint,
	@storeId as bigint
	
AS
	
	begin try
		 if(not exists(select pk_fk_usr_cstmrId from TB_STORE_CUSTOMER where pk_fk_usr_cstmrId = @parentUserId and pk_fk_store_id = @storeId))
		 begin
			set @rMsg = dbo.func_getSysMsg('invalid user',OBJECT_NAME(@@PROCID),@clientLanguage,'parent user dont joined the store'); 
			set @rCode = 0
			return
		 end
		 if(not exists(select pk_fk_usr_cstmrId from TB_STORE_CUSTOMER where pk_fk_usr_cstmrId = @subscribeUserId and pk_fk_store_id = @storeId))
		 begin
			set @rMsg = dbo.func_getSysMsg('invalid user',OBJECT_NAME(@@PROCID),@clientLanguage,'subscribe user dont joined the store'); 
			set @rCode = 0
			return
		 end
		 insert into TB_STORE_MARKETING_MEMBER(fk_parent_usr_id,fk_usr_id,fk_store_marketing_id) values (@parentUserId,@subscribeUserId,@planId)
		 
		 set @rCode = 1
		 set @rMsg = 'success'		
	end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
	end catch
RETURN 0
